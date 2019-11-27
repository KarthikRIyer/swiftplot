import Foundation

// class defining a lineGraph and all its logic
public class LineGraph<T:FloatConvertible,U:FloatConvertible>: Plot {

    let MAX_DIV: Float = 50

    public var xOffset: Float = 0
    public var yOffset: Float = 0

    public var plotTitle: PlotTitle? = nil
    public var plotLabel: PlotLabel? = nil
    public var plotLegend: PlotLegend = PlotLegend()
    public var plotBorder: PlotBorder = PlotBorder()
    public var plotDimensions: PlotDimensions {
        didSet {
            Self.updatePlot(legend: &plotLegend,
                            border: &plotBorder,
                            fromDimensions: plotDimensions)
        }
    }
    public var plotLineThickness: Float = 1.5
    public var gridLineThickness: Float = 0.5
    public var markerTextSize: Float = 12
    public var enablePrimaryAxisGrid = false
    public var enableSecondaryAxisGrid = false
    public var gridColor: Color = .gray

    var primaryAxis = Axis<T,U>()
    var secondaryAxis: Axis<T,U>? = nil
    
    static func updatePlot(legend: inout PlotLegend, border: inout PlotBorder, fromDimensions dimensions: PlotDimensions) {
        border.rect.origin.x = dimensions.subWidth*0.1
        border.rect.origin.y = dimensions.subHeight*0.9
        border.rect.size.width = dimensions.subWidth*0.8
        border.rect.size.height = dimensions.subHeight * -0.8
        border.rect = border.rect.normalized
        
        legend.legendTopLeft = Point(border.rect.minX + Float(20),
                                     border.rect.maxY - Float(20))
    }

    public init(points : [Pair<T,U>],
                width: Float = 1000,
                height: Float = 660,
                enablePrimaryAxisGrid: Bool = false,
                enableSecondaryAxisGrid: Bool = false){
        plotDimensions = PlotDimensions(frameWidth: width, frameHeight: height)
        plotDimensions.calculateGraphDimensions()
        self.enablePrimaryAxisGrid = enablePrimaryAxisGrid
        self.enableSecondaryAxisGrid = enableSecondaryAxisGrid

        let s = Series<T,U>(values: points,label: "Plot")
        primaryAxis.series.append(s)
    }

    public init(width: Float = 1000,
                height: Float = 660,
                enablePrimaryAxisGrid: Bool = false,
                enableSecondaryAxisGrid: Bool = false){
        plotDimensions = PlotDimensions(frameWidth: width, frameHeight: height)
        self.enablePrimaryAxisGrid = enablePrimaryAxisGrid
        self.enableSecondaryAxisGrid = enableSecondaryAxisGrid
    }

    // functions to add series
    public func addSeries(_ s: Series<T,U>,
                          axisType: Axis<T,U>.Location = .primaryAxis){
        switch axisType {
        case .primaryAxis:
            primaryAxis.series.append(s)
        case .secondaryAxis:
            if secondaryAxis == nil {
                secondaryAxis = Axis()
            }
            secondaryAxis!.series.append(s)
        }
    }
    public func addSeries(points : [Pair<T,U>],
                          label: String, color: Color = Color.lightBlue,
                          axisType: Axis<T,U>.Location = .primaryAxis){
        let s = Series<T,U>(values: points,label: label, color: color)
        addSeries(s, axisType: axisType)
    }
    public func addSeries(_ y: [U],
                          label: String,
                          color: Color = Color.lightBlue,
                        axisType: Axis<T,U>.Location = .primaryAxis){
        var points = [Pair<T,U>]()
        for i in 0..<y.count {
            points.append(Pair<T,U>(T(i+1), y[i]))
        }
        let s = Series<T,U>(values: points, label: label, color: color)
        addSeries(s, axisType: axisType)
    }
    public func addSeries(_ x: [T],
                          _ y: [U],
                          label: String,
                          color: Color = .lightBlue,
                          axisType: Axis<T,U>.Location = .primaryAxis){
        var points = [Pair<T,U>]()
        for i in 0..<x.count {
            points.append(Pair<T,U>(x[i], y[i]))
        }
        let s = Series<T,U>(values: points, label: label, color: color)
        addSeries(s, axisType: axisType)
    }
    public func addFunction(_ function: (T)->U,
                            minX: T,
                            maxX: T,
                            numberOfSamples: Int = 400,
                            label: String,
                            color: Color = Color.lightBlue,
                            axisType: Axis<T,U>.Location = .primaryAxis) {
        var x = [T]()
        var y = [U]()
        let step = Float(maxX - minX)/Float(numberOfSamples)
        var r: Float = 0.0
        for i in stride(from: Float(minX), through: Float(maxX), by: step) {
            r = Float(function(T(i)))
            if (r.isNaN || r.isInfinite) {
                continue
            }
            x.append(T(i))
            y.append(clamp(U(r), minValue: U(-1.0/step), maxValue: U(1.0/step)))
            // y.append(r)
        }
        var points = [Pair<T,U>]()
        for i in 0..<x.count {
            points.append(Pair<T,U>(x[i], y[i]))
        }
        let s = Series<T,U>(values: points, label: label, color: color)
        addSeries(s, axisType: axisType)
    }
}

// extension containing drawing logic
extension LineGraph{

    // call functions to draw the graph
    public func drawGraphAndOutput(fileName name: String = "swift_plot_line_graph", renderer: Renderer){
        renderer.xOffset = xOffset
        renderer.yOffset = yOffset
        renderer.plotDimensions = plotDimensions
        Self.updatePlot(legend: &plotLegend,
                        border: &plotBorder,
                        fromDimensions: plotDimensions)
        calcLabelLocations(renderer: renderer)
        calcMarkerLocAndScalePts(renderer: renderer)
        drawGrid(renderer: renderer)
        drawBorder(renderer: renderer)
        drawMarkers(renderer: renderer)
        drawPlots(renderer: renderer)
        drawTitle(renderer: renderer)
        drawLabels(renderer: renderer)
        drawLegends(renderer: renderer)
        saveImage(fileName: name, renderer: renderer)
    }

    public func drawGraph(renderer: Renderer){
        renderer.xOffset = xOffset
        renderer.yOffset = yOffset
        Self.updatePlot(legend: &plotLegend,
                        border: &plotBorder,
                        fromDimensions: plotDimensions)
        calcLabelLocations(renderer: renderer)
        calcMarkerLocAndScalePts(renderer: renderer)
        drawGrid(renderer: renderer)
        drawBorder(renderer: renderer)
        drawMarkers(renderer: renderer)
        drawPlots(renderer: renderer)
        drawTitle(renderer: renderer)
        drawLabels(renderer: renderer)
        drawLegends(renderer: renderer)
    }

    public func drawGraphOutput(fileName name: String = "swift_plot_line_graph", renderer: Renderer){
        renderer.plotDimensions = plotDimensions
        renderer.drawOutput(fileName: name)
    }

    // functions implementing plotting logic
    func calcLabelLocations(renderer: Renderer){
        if (plotLabel != nil) {
            let xWidth   : Float = renderer.getTextWidth(text: plotLabel!.xLabel,
                                                         textSize: plotLabel!.labelSize)
            let yWidth    : Float = renderer.getTextWidth(text: plotLabel!.yLabel,
                                                          textSize: plotLabel!.labelSize)
            plotLabel!.xLabelLocation = Point(
                plotBorder.rect.midX - xWidth * 0.5,
                plotBorder.rect.minY - plotLabel!.labelSize - 0.05 * plotDimensions.graphHeight
            )
            plotLabel!.yLabelLocation = Point(
                plotBorder.rect.origin.x - plotLabel!.labelSize - 0.05 * plotDimensions.graphWidth,
                plotBorder.rect.midY - yWidth
            )
        }
        if (plotTitle != nil) {
            let titleWidth: Float = renderer.getTextWidth(text: plotTitle!.title,
                                                          textSize: plotTitle!.titleSize)
            plotTitle!.titleLocation = Point(
                plotBorder.rect.midX - titleWidth * 0.5,
                plotBorder.rect.maxY + plotTitle!.titleSize * 0.5
            )
        }
    }

    func calcMarkerLocAndScalePts(renderer: Renderer){

        primaryAxis.plotMarkers.xMarkers = [Point]()
        primaryAxis.plotMarkers.yMarkers = [Point]()
        primaryAxis.plotMarkers.xMarkersTextLocation = [Point]()
        primaryAxis.plotMarkers.yMarkersTextLocation = [Point]()
        primaryAxis.plotMarkers.xMarkersText = [String]()
        primaryAxis.plotMarkers.xMarkersText = [String]()
        primaryAxis.plotMarkers.markerTextSize = markerTextSize

        var maximumXPrimary: T = maxX(points: primaryAxis.series[0].values)
        var maximumYPrimary: U = maxY(points: primaryAxis.series[0].values)
        var minimumXPrimary: T = minX(points: primaryAxis.series[0].values)
        var minimumYPrimary: U = minY(points: primaryAxis.series[0].values)

        for index in 1..<primaryAxis.series.count {

            let s: Series<T,U> = primaryAxis.series[index]

            var x: T = maxX(points: s.values)
            var y: U = maxY(points: s.values)
            if (x > maximumXPrimary) {
                maximumXPrimary = x
            }
            if (y > maximumYPrimary) {
                maximumYPrimary = y
            }
            x = minX(points: s.values)
            y = minY(points: s.values)
            if (x < minimumXPrimary) {
                minimumXPrimary = x
            }
            if (y < minimumYPrimary) {
                minimumYPrimary = y
            }
        }

        var maximumXSecondary = T(0)
        var maximumYSecondary = U(0)
        var minimumXSecondary = T(0)
        var minimumYSecondary = U(0)

        if secondaryAxis != nil {
            secondaryAxis!.plotMarkers.xMarkers = [Point]()
            secondaryAxis!.plotMarkers.yMarkers = [Point]()
            secondaryAxis!.plotMarkers.xMarkersTextLocation = [Point]()
            secondaryAxis!.plotMarkers.yMarkersTextLocation = [Point]()
            secondaryAxis!.plotMarkers.xMarkersText = [String]()
            secondaryAxis!.plotMarkers.xMarkersText = [String]()
            secondaryAxis!.plotMarkers.markerTextSize = markerTextSize

            maximumXSecondary = maxX(points: secondaryAxis!.series[0].values)
            maximumYSecondary = maxY(points: secondaryAxis!.series[0].values)
            minimumXSecondary = minX(points: secondaryAxis!.series[0].values)
            minimumYSecondary = minY(points: secondaryAxis!.series[0].values)
            for index in 1..<secondaryAxis!.series.count {
                let s: Series<T,U> = secondaryAxis!.series[index]

                var x: T = maxX(points: s.values)
                var y: U = maxY(points: s.values)
                if (x > maximumXSecondary) {
                    maximumXSecondary = x
                }
                if (y > maximumYSecondary) {
                    maximumYSecondary = y
                }
                x = minX(points: s.values)
                y = minY(points: s.values)
                if (x < minimumXSecondary) {
                    minimumXSecondary = x
                }
                if (y < minimumYSecondary) {
                    minimumYSecondary = y
                }
            }
            maximumXPrimary = max(maximumXPrimary, maximumXSecondary)
            minimumXPrimary = min(minimumXPrimary, minimumXSecondary)
        }

        let rightScaleMargin: Float = (plotDimensions.subWidth - plotDimensions.graphWidth)*Float(0.2) - 10.0;
        let topScaleMargin: Float = (plotDimensions.subHeight - plotDimensions.graphHeight)*Float(0.2) - 10.0;
        var originPrimaryX: Float = (plotDimensions.graphWidth/Float(maximumXPrimary-minimumXPrimary))*Float(T(-1)*minimumXPrimary)
        var originPrimaryY: Float = (plotDimensions.graphHeight/Float(maximumYPrimary-minimumYPrimary))*Float(U(-1)*minimumYPrimary)
        if(minimumXPrimary >= T(0)) {
            originPrimaryX+=rightScaleMargin
        }
        if(minimumYPrimary >= U(0)) {
            originPrimaryY+=topScaleMargin
        }
        let originPrimary = Point(originPrimaryX, originPrimaryY)
        primaryAxis.scaleX = Float(maximumXPrimary - minimumXPrimary) / (plotDimensions.graphWidth - 2*rightScaleMargin);
        primaryAxis.scaleY = Float(maximumYPrimary - minimumYPrimary) / (plotDimensions.graphHeight - 2*topScaleMargin);

        var originSecondary: Point? = nil
        if (secondaryAxis != nil) {
            var originSecondaryX: Float = (plotDimensions.graphWidth/Float(maximumXSecondary-minimumXSecondary))*Float(T(-1)*minimumXSecondary)
            var originSecondaryY: Float = (plotDimensions.graphHeight/Float(maximumYSecondary-minimumYSecondary))*Float(U(-1)*minimumYSecondary)
            if(minimumXSecondary >= T(0)) {
                originSecondaryX+=rightScaleMargin
            }
            if(minimumYSecondary >= U(0)) {
                originSecondaryY+=topScaleMargin
            }
            originSecondary = Point(originSecondaryX, originSecondaryY)
            secondaryAxis!.scaleX = Float(maximumXSecondary - minimumXSecondary) / (plotDimensions.graphWidth - 2*rightScaleMargin);
            secondaryAxis!.scaleY = Float(maximumYSecondary - minimumYSecondary) / (plotDimensions.graphHeight - 2*topScaleMargin);
        }

        //calculations for primary axis
        var inc1Primary: Float = -1
        var inc2Primary: Float = -1
        var xIncRound: Int   = 1
        var yIncRoundPrimary: Int = 1
        var yIncRoundSecondary: Int = 1
        // var inc2Primary: Float
        if(Float(maximumYPrimary-minimumYPrimary)<=2.0 && Float(maximumYPrimary-minimumYPrimary)>=1.0) {
          let differenceY = Float(maximumYPrimary-minimumYPrimary)
          inc1Primary = 0.5*(1.0/differenceY)
          var c = 0
          while(abs(inc1Primary)*pow(10.0,Float(c))<1.0) {
            c+=1
          }
          inc1Primary = inc1Primary/primaryAxis.scaleY
          yIncRoundPrimary = c+1
        }
        else if(Float(maximumYPrimary-minimumYPrimary)<1.0) {
          let differenceY = Float(maximumYPrimary-minimumYPrimary)
          inc1Primary = differenceY/10.0
          var c = 0
          while(abs(inc1Primary)*pow(10.0,Float(c))<1.0) {
            c+=1
          }
          inc1Primary = inc1Primary/primaryAxis.scaleY
          yIncRoundPrimary = c+1
        }
        if(Float(maximumXPrimary-minimumXPrimary)<=2.0 && Float(maximumXPrimary-minimumXPrimary)>=1.0) {
          let differenceX = Float(maximumXPrimary-minimumXPrimary)
          inc2Primary = 0.5*(1.0/differenceX)
          var c = 0
          while(abs(inc2Primary)*pow(10.0,Float(c))<1.0) {
            c+=1
          }
          inc2Primary = inc1Primary/primaryAxis.scaleX
          xIncRound = c+1
        }
        if(Float(maximumXPrimary-minimumXPrimary)<1.0) {
          let differenceX = Float(maximumXPrimary-minimumXPrimary)
          inc2Primary = differenceX/10
          var c = 0
          while(abs(inc2Primary)*pow(10.0,Float(c))<1.0) {
            c+=1
          }
          inc2Primary = inc1Primary/primaryAxis.scaleX
          xIncRound = c+1
        }
        var nD1: Int = max(getNumberOfDigits(Float(maximumYPrimary)), getNumberOfDigits(Float(minimumYPrimary)))
        var v1: Float
        if (nD1 > 1 && maximumYPrimary <= U(pow(Float(10), Float(nD1 - 1)))) {
            v1 = Float(pow(Float(10), Float(nD1 - 2)))
        } else if (nD1 > 1) {
            v1 = Float(pow(Float(10), Float(nD1 - 1)))
        } else {
            v1 = Float(pow(Float(10), Float(0)))
        }
        var nY: Float = v1/primaryAxis.scaleY
        if(inc1Primary == -1) {
            inc1Primary = nY
            if(plotDimensions.graphHeight/nY > MAX_DIV){
                inc1Primary = (plotDimensions.graphHeight/nY)*inc1Primary/MAX_DIV
            }
        }

        let nD2: Int = max(getNumberOfDigits(Float(maximumXPrimary)), getNumberOfDigits(Float(minimumXPrimary)))
        var v2: Float
        if (nD2 > 1 && maximumXPrimary <= T(pow(Float(10), Float(nD2 - 1)))) {
            v2 = Float(pow(Float(10), Float(nD2 - 2)))
        } else if (nD2 > 1) {
            v2 = Float(pow(Float(10), Float(nD2 - 1)))
        } else {
            v2 = Float(pow(Float(10), Float(0)))
        }

        let nX: Float = v2/primaryAxis.scaleX
        if(inc2Primary == -1) {
            inc2Primary = nX
            var noXD: Float = plotDimensions.graphWidth/nX
            if(noXD > MAX_DIV){
                inc2Primary = (plotDimensions.graphWidth/nX)*inc2Primary/MAX_DIV
                noXD = MAX_DIV
            }
        }

        var xM = originPrimary.x
        while xM<=plotDimensions.graphWidth {
            if(xM+inc2Primary<0.0 || xM<0.0) {
                xM = xM+inc2Primary
                continue
            }
            let p = Point(xM, 0)
            primaryAxis.plotMarkers.xMarkers.append(p)
            let text_p = Point(xM - (renderer.getTextWidth(text: "\(roundToN(primaryAxis.scaleX*(xM-originPrimary.x), xIncRound))",
                                                           textSize: primaryAxis.plotMarkers.markerTextSize)/2.0) + 5,
                               -20)
            primaryAxis.plotMarkers.xMarkersTextLocation.append(text_p)
            primaryAxis.plotMarkers.xMarkersText.append("\(roundToN(primaryAxis.scaleX*(xM-originPrimary.x), xIncRound))")
            xM = xM + inc2Primary
        }

        xM = originPrimary.x - inc2Primary
        while xM>0.0 {
            if (xM > plotDimensions.graphWidth) {
                xM = xM - inc2Primary
                continue
            }
            let p = Point(xM, 0)
            primaryAxis.plotMarkers.xMarkers.append(p)
            let text_p = Point(xM - (renderer.getTextWidth(text: "\(roundToN(primaryAxis.scaleX*(xM-originPrimary.x), xIncRound))",
                                                           textSize: primaryAxis.plotMarkers.markerTextSize)/2.0) + 5,
                               -20)
            primaryAxis.plotMarkers.xMarkersTextLocation.append(text_p)
            primaryAxis.plotMarkers.xMarkersText.append("\(roundToN(primaryAxis.scaleX*(xM-originPrimary.x), xIncRound))")
            xM = xM - inc2Primary
        }

        var yM = originPrimary.y
        while yM<=plotDimensions.graphHeight {
            if(yM+inc1Primary<0.0 || yM<0.0){
                yM = yM + inc1Primary
                continue
            }
            let p = Point(0, yM)
            primaryAxis.plotMarkers.yMarkers.append(p)
            let text_p = Point(-(renderer.getTextWidth(text: "\(roundToN(primaryAxis.scaleY*(yM-originPrimary.y), yIncRoundPrimary))",
                                                       textSize: primaryAxis.plotMarkers.markerTextSize)+8),
                               yM - 4)
            primaryAxis.plotMarkers.yMarkersTextLocation.append(text_p)
            primaryAxis.plotMarkers.yMarkersText.append("\(roundToN(primaryAxis.scaleY*(yM-originPrimary.y), yIncRoundPrimary))")
            yM = yM + inc1Primary
        }
        yM = originPrimary.y - inc1Primary
        while yM>0.0 {
            let p = Point(0, yM)
            primaryAxis.plotMarkers.yMarkers.append(p)
            let text_p = Point(-(renderer.getTextWidth(text: "\(roundToN(primaryAxis.scaleY*(yM-originPrimary.y), yIncRoundPrimary))",
                                                       textSize: primaryAxis.plotMarkers.markerTextSize)+8),
                               yM - 4)
            primaryAxis.plotMarkers.yMarkersTextLocation.append(text_p)
            primaryAxis.plotMarkers.yMarkersText.append("\(roundToN(primaryAxis.scaleY*(yM-originPrimary.y), yIncRoundPrimary))")
            yM = yM - inc1Primary
        }



        // scale points to be plotted according to plot size
        let scaleXInvPrimary: Float = 1.0/primaryAxis.scaleX;
        let scaleYInvPrimary: Float = 1.0/primaryAxis.scaleY
        for i in 0..<primaryAxis.series.count {
            primaryAxis.series[i].scaledValues.removeAll();
            for j in 0..<primaryAxis.series[i].count {
                let scaledPair = Pair<T,U>(((primaryAxis.series[i])[j].x)*T(scaleXInvPrimary) + T(originPrimary.x),
                                           ((primaryAxis.series[i])[j].y)*U(scaleYInvPrimary) + U(originPrimary.y))
                if (Float(scaledPair.x) >= 0.0 && Float(scaledPair.x) <= plotDimensions.graphWidth && Float(scaledPair.y) >= 0.0 && Float(scaledPair.y) <= plotDimensions.graphHeight) {
                    primaryAxis.series[i].scaledValues.append(scaledPair)
                }
            }
        }

        //calculations for secondary axis
        if (secondaryAxis != nil) {
            var inc1Secondary: Float = -1
            if(Float(maximumYSecondary-minimumYSecondary)<=2.0){
              let differenceY = Float(maximumYSecondary-minimumYSecondary)
              inc1Secondary = 0.5*(1.0/differenceY)
              var c = 0
              while(abs(inc1Secondary)*pow(10.0,Float(c))<1.0){
                c+=1
              }
              inc1Secondary = inc1Secondary/secondaryAxis!.scaleY
              yIncRoundSecondary = c+1
            }

            nD1 = max(getNumberOfDigits(Float(maximumYSecondary)), getNumberOfDigits(Float(minimumYSecondary)))
            if (nD1 > 1 && maximumYSecondary <= U(pow(Float(10), Float(nD1 - 1)))) {
                v1 = Float(pow(Float(10), Float(nD1 - 2)))
            } else if (nD1 > 1) {
                v1 = Float(pow(Float(10), Float(nD1 - 1)))
            } else {
                v1 = Float(pow(Float(10), Float(0)))
            }

            nY = v1/secondaryAxis!.scaleY
            if(inc1Secondary == -1) {
                inc1Secondary = nY
                if(plotDimensions.graphHeight/nY > MAX_DIV){
                    inc1Secondary = (plotDimensions.graphHeight/nY)*inc1Secondary/MAX_DIV
                }
            }
            yM = originSecondary!.y

            while yM<=plotDimensions.graphHeight {
                if(yM+inc1Secondary<0.0 || yM<0.0){
                    yM = yM + inc1Secondary
                    continue
                }
                let p = Point(0, yM)
                secondaryAxis!.plotMarkers.yMarkers.append(p)
                let text_p = Point(plotDimensions.graphWidth + (renderer.getTextWidth(text: "\(roundToN(secondaryAxis!.scaleY*(yM-originSecondary!.y), yIncRoundSecondary))",
                                                                                      textSize: secondaryAxis!.plotMarkers.markerTextSize)*Float(0.5) - 8),
                                   yM - 4)
                secondaryAxis!.plotMarkers.yMarkersTextLocation.append(text_p)
                secondaryAxis!.plotMarkers.yMarkersText.append("\(roundToN(secondaryAxis!.scaleY*(yM-originSecondary!.y), yIncRoundSecondary))")
                yM = yM + inc1Secondary
            }
            yM = originSecondary!.y - inc1Secondary
            while yM>0.0 {
                let p = Point(0, yM)
                secondaryAxis!.plotMarkers.yMarkers.append(p)
                let text_p = Point(plotDimensions.graphWidth + (renderer.getTextWidth(text: "\(roundToN(secondaryAxis!.scaleY*(yM-originSecondary!.y), yIncRoundSecondary))",
                                                                                      textSize: secondaryAxis!.plotMarkers.markerTextSize)*Float(0.5) - 8),
                                   yM - 4)
                secondaryAxis!.plotMarkers.yMarkersTextLocation.append(text_p)
                secondaryAxis!.plotMarkers.yMarkersText.append("\(roundToN(secondaryAxis!.scaleY*(yM-originSecondary!.y), yIncRoundSecondary))")
                yM = yM - inc1Secondary
            }



            // scale points to be plotted according to plot size
            let scaleYInvSecondary: Float = 1.0/secondaryAxis!.scaleY
            for i in 0..<secondaryAxis!.series.count {
                // let pairs = secondaryAxis!.series[i].pairs
                secondaryAxis!.series[i].scaledValues.removeAll();
                for j in 0..<secondaryAxis!.series[i].count {
                    let scaledPair = Pair<T,U>(((secondaryAxis!.series[i])[j].x)*T(scaleXInvPrimary) + T(originPrimary.x),
                                               ((secondaryAxis!.series[i])[j].y)*U(scaleYInvSecondary) + U(originSecondary!.y))
                    if (Float(scaledPair.x) >= 0.0 && Float(scaledPair.x) <= plotDimensions.graphWidth && Float(scaledPair.y) >= 0.0 && Float(scaledPair.y) <= plotDimensions.graphHeight) {
                        secondaryAxis!.series[i].scaledValues.append(scaledPair)
                    }
                }
            }
        }
    }

    //functions to draw the plot
    func drawBorder(renderer: Renderer){
        renderer.drawRect(plotBorder.rect,
                          strokeWidth: plotBorder.borderThickness,
                          strokeColor: Color.black,
                          isOriginShifted: false)
    }

    func drawGrid(renderer: Renderer) {
        if (enablePrimaryAxisGrid || enableSecondaryAxisGrid) {
            for index in 0..<primaryAxis.plotMarkers.xMarkers.count {
                let p1 = Point(primaryAxis.plotMarkers.xMarkers[index].x, 0)
                let p2 = Point(primaryAxis.plotMarkers.xMarkers[index].x, plotDimensions.graphHeight)
                renderer.drawLine(startPoint: p1,
                                  endPoint: p2,
                                  strokeWidth: gridLineThickness,
                                  strokeColor: gridColor,
                                  isDashed: false,
                                  isOriginShifted: true)
            }
        }
        if (enablePrimaryAxisGrid) {
            for index in 0..<primaryAxis.plotMarkers.yMarkers.count {
                let p1 = Point(0, primaryAxis.plotMarkers.yMarkers[index].y)
                let p2 = Point(plotDimensions.graphWidth, primaryAxis.plotMarkers.yMarkers[index].y)
                renderer.drawLine(startPoint: p1,
                                  endPoint: p2,
                                  strokeWidth: gridLineThickness,
                                  strokeColor: gridColor,
                                  isDashed: false,
                                  isOriginShifted: true)
            }
        }
        if (enableSecondaryAxisGrid) {
            if (secondaryAxis != nil) {
                for index in 0..<secondaryAxis!.plotMarkers.yMarkers.count {
                    let p1 = Point(0, secondaryAxis!.plotMarkers.yMarkers[index].y)
                    let p2 = Point(plotDimensions.graphWidth, secondaryAxis!.plotMarkers.yMarkers[index].y)
                    renderer.drawLine(startPoint: p1,
                                      endPoint: p2,
                                      strokeWidth: gridLineThickness,
                                      strokeColor: gridColor,
                                      isDashed: false,
                                      isOriginShifted: true)
                }
            }
        }
    }

    func drawMarkers(renderer: Renderer) {
        for index in 0..<primaryAxis.plotMarkers.xMarkers.count {
            let p1 = Point(primaryAxis.plotMarkers.xMarkers[index].x, -6)
            let p2 = Point(primaryAxis.plotMarkers.xMarkers[index].x, 0)
            renderer.drawLine(startPoint: p1,
                              endPoint: p2,
                              strokeWidth: plotBorder.borderThickness,
                              strokeColor: Color.black,
                              isDashed: false,
                              isOriginShifted: true)
            renderer.drawText(text: primaryAxis.plotMarkers.xMarkersText[index],
                              location: primaryAxis.plotMarkers.xMarkersTextLocation[index],
                              textSize: primaryAxis.plotMarkers.markerTextSize,
                              strokeWidth: 0.7,
                              angle: 0,
                              isOriginShifted: true)
        }

        for index in 0..<primaryAxis.plotMarkers.yMarkers.count {
            let p1 = Point(-6, primaryAxis.plotMarkers.yMarkers[index].y)
            let p2 = Point(0, primaryAxis.plotMarkers.yMarkers[index].y)
            renderer.drawLine(startPoint: p1,
                              endPoint: p2,
                              strokeWidth: plotBorder.borderThickness,
                              strokeColor: Color.black,
                              isDashed: false,
                              isOriginShifted: true)
            renderer.drawText(text: primaryAxis.plotMarkers.yMarkersText[index],
                              location: primaryAxis.plotMarkers.yMarkersTextLocation[index],
                              textSize: primaryAxis.plotMarkers.markerTextSize,
                              strokeWidth: 0.7,
                              angle: 0,
                              isOriginShifted: true)
        }

        if (secondaryAxis != nil) {
            for index in 0..<secondaryAxis!.plotMarkers.yMarkers.count {
                let p1 = Point(plotDimensions.graphWidth,
                              (secondaryAxis!.plotMarkers.yMarkers[index].y))
                let p2 = Point(plotDimensions.graphWidth + 6,
                              (secondaryAxis!.plotMarkers.yMarkers[index].y))
                renderer.drawLine(startPoint: p1,
                                  endPoint: p2,
                                  strokeWidth: plotBorder.borderThickness,
                                  strokeColor: Color.black,
                                  isDashed: false,
                                  isOriginShifted: true)
                renderer.drawText(text: secondaryAxis!.plotMarkers.yMarkersText[index],
                                  location: secondaryAxis!.plotMarkers.yMarkersTextLocation[index],
                                  textSize: secondaryAxis!.plotMarkers.markerTextSize,
                                  strokeWidth: 0.7,
                                  angle: 0,
                                  isOriginShifted: true)
            }
        }

    }

    func drawPlots(renderer: Renderer) {
        for s in primaryAxis.series {
            var points = [Point]()
            for p in s.scaledValues {
                points.append(Point(Float(p.x),Float(p.y)))
            }
            renderer.drawPlotLines(points: points,
                                   strokeWidth: plotLineThickness,
                                   strokeColor: s.color,
                                   isDashed: false)
        }
        if (secondaryAxis != nil) {
            for s in secondaryAxis!.series {
                var points = [Point]()
                for p in s.scaledValues {
                    points.append(Point(Float(p.x),Float(p.y)))
                }
                renderer.drawPlotLines(points: points,
                                       strokeWidth: plotLineThickness,
                                       strokeColor: s.color,
                                       isDashed: true)
            }
        }
    }

    func drawTitle(renderer: Renderer) {
        guard let plotTitle = self.plotTitle else { return }
        renderer.drawText(text: plotTitle.title,
                          location: plotTitle.titleLocation,
                          textSize: plotTitle.titleSize,
                          strokeWidth: 1.2,
                          angle: 0,
                          isOriginShifted: false)
    }

    func drawLabels(renderer: Renderer) {
        guard let plotLabel = self.plotLabel else { return }
        renderer.drawText(text: plotLabel.xLabel,
                          location: plotLabel.xLabelLocation,
                          textSize: plotLabel.labelSize,
                          strokeWidth: 1.2,
                          angle: 0,
                          isOriginShifted: false)
        renderer.drawText(text: plotLabel.yLabel,
                          location: plotLabel.yLabelLocation,
                          textSize: plotLabel.labelSize,
                          strokeWidth: 1.2,
                          angle: 90,
                          isOriginShifted: false)
    }

    func drawLegends(renderer: Renderer) {
        var maxWidth: Float = 0
        var allSeries: [Series] = primaryAxis.series
        if (secondaryAxis != nil) {
            allSeries = allSeries + secondaryAxis!.series
        }
        for s in allSeries {
            let w: Float = renderer.getTextWidth(text: s.label, textSize: plotLegend.legendTextSize)
            if (w > maxWidth) {
                maxWidth = w
            }
        }
        plotLegend.legendWidth  = maxWidth + 3.5*plotLegend.legendTextSize
        plotLegend.legendHeight = (Float(allSeries.count)*2.0 + 1.0)*plotLegend.legendTextSize

        let legendRect = Rect(
            origin: plotLegend.legendTopLeft,
            size: Size(width: plotLegend.legendWidth, height: -plotLegend.legendHeight)
        ).normalized
        renderer.drawSolidRectWithBorder(legendRect,
                                         strokeWidth: plotBorder.borderThickness,
                                         fillColor: Color.transluscentWhite,
                                         borderColor: Color.black,
                                         isOriginShifted: false)

        for i in 0..<allSeries.count {
            let seriesIcon = Rect(
                origin: Point(legendRect.origin.x + plotLegend.legendTextSize,
                              legendRect.maxY - (2.0*Float(i) + 1.0)*plotLegend.legendTextSize),
                size: Size(width: plotLegend.legendTextSize, height: -plotLegend.legendTextSize)
            )
            renderer.drawSolidRect(seriesIcon,
                                   fillColor: allSeries[i].color,
                                   hatchPattern: .none,
                                   isOriginShifted: false)
            let p = Point(seriesIcon.maxX + plotLegend.legendTextSize, seriesIcon.minY)
            renderer.drawText(text: allSeries[i].label,
                              location: p,
                              textSize: plotLegend.legendTextSize,
                              strokeWidth: 1.2,
                              angle: 0,
                              isOriginShifted: false)
        }

    }

    func saveImage(fileName name: String, renderer: Renderer) {
        renderer.drawOutput(fileName: name)
    }
}
