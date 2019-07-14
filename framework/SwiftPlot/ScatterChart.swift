import Foundation

// class defining a lineGraph and all its logic
public class ScatterPlot<T:FloatConvertible,U:FloatConvertible>: Plot {

    let MAX_DIV: Float = 50

    let sqrt3: Float = sqrt(3)

    public var xOffset: Float = 0
    public var yOffset: Float = 0

    public var plotTitle: PlotTitle? = nil
    public var plotLabel: PlotLabel? = nil
    public var plotLegend: PlotLegend = PlotLegend()
    public var plotBorder: PlotBorder = PlotBorder()
    public var plotDimensions: PlotDimensions {
        willSet{
            plotBorder.topLeft       = Point(newValue.subWidth*0.1,
                                             newValue.subHeight*0.9)
            plotBorder.topRight      = Point(newValue.subWidth*0.9,
                                             newValue.subHeight*0.9)
            plotBorder.bottomLeft    = Point(newValue.subWidth*0.1,
                                             newValue.subHeight*0.1)
            plotBorder.bottomRight   = Point(newValue.subWidth*0.9,
                                             newValue.subHeight*0.1)
            plotLegend.legendTopLeft = Point(plotBorder.topLeft.x + Float(20),
                                             plotBorder.topLeft.y - Float(20))
        }
    }
    public var plotLineThickness: Float = 3
    public var scatterPatternSize: Float = 10
    public var enableGrid = false
    public var gridColor: Color = .gray
    public var gridLineThickness: Float = 0.5

    var scaleX: Float = 1
    var scaleY: Float = 1
    var plotMarkers: PlotMarkers = PlotMarkers()
    var series = [Series<T,U>]()

    public init(points p: [Pair<T,U>],
                width: Float = 1000,
                height: Float = 660,
                enableGrid: Bool = false){
        plotDimensions = PlotDimensions(frameWidth: width, frameHeight: height)
        plotDimensions.calculateGraphDimensions()

        let s = Series<T,U>(values: p,label: "Plot")
        series.append(s)
        self.enableGrid = enableGrid
    }

    public init(width: Float = 1000,
                height: Float = 660,
                enableGrid: Bool = false){
        plotDimensions = PlotDimensions(frameWidth: width, frameHeight: height)
        self.enableGrid = enableGrid
    }

    // functions to add series
    public func addSeries(_ s: Series<T,U>){
        series.append(s)
    }
    public func addSeries(points: [Pair<T,U>],
                          label: String,
                          color: Color = .lightBlue,
                          scatterPattern: ScatterPlotSeriesOptions.ScatterPattern = .circle){
        let s = Series(values: points,label: label, color: color, scatterPattern: scatterPattern)
        addSeries(s)
    }
    public func addSeries(_ x: [T],
                          _ y: [U],
                          label: String,
                          color: Color = .lightBlue,
                          scatterPattern: ScatterPlotSeriesOptions.ScatterPattern = .circle){
        var points = [Pair<T,U>]()
        for i in 0..<x.count {
            points.append(Pair<T,U>(x[i], y[i]))
        }
        let s = Series(values: points,
                       label: label,
                       color: color,
                       scatterPattern: scatterPattern)
        addSeries(s)
    }
    public func addSeries(_ x: [T],
                          _ y: [U],
                          label: String,
                          startColor: Color = .lightBlue,
                          endColor: Color = .lightBlue,
                          scatterPattern: ScatterPlotSeriesOptions.ScatterPattern = .circle){
        var points = [Pair<T,U>]()
        for i in 0..<x.count {
            points.append(Pair<T,U>(x[i], y[i]))
        }
        let s = Series(values: points,
                       label: label,
                       startColor: startColor,
                       endColor: endColor,
                       scatterPattern: scatterPattern)
        addSeries(s)
    }
    public func addSeries(_ y: [U],
                          label: String,
                          color: Color = .lightBlue,
                          scatterPattern: ScatterPlotSeriesOptions.ScatterPattern = .circle){
        var points = [Pair<T,U>]()
        for i in 0..<y.count {
            points.append(Pair<T,U>(T(i+1), y[i]))
        }
        let s = Series(values: points,
                       label: label,
                       color: color,
                       scatterPattern: scatterPattern)
        addSeries(s)
    }
    public func addSeries(_ y: [U],
                          label: String,
                          startColor: Color = .lightBlue,
                          endColor: Color = .lightBlue,
                          scatterPattern: ScatterPlotSeriesOptions.ScatterPattern = .circle){
        var points = [Pair<T,U>]()
        for i in 0..<y.count {
            points.append(Pair<T,U>(T(i+1), y[i]))
        }
        let s = Series(values: points,
                       label: label,
                       startColor: startColor,
                       endColor: endColor,
                       scatterPattern: scatterPattern)
        addSeries(s)
    }
}

// extension containing drawing logic
extension ScatterPlot{

    // call functions to draw the graph
    public func drawGraphAndOutput(fileName name: String = "swift_plot_scatter_plot", renderer: Renderer){
        renderer.xOffset = xOffset
        renderer.yOffset = yOffset
        renderer.plotDimensions = plotDimensions
        plotBorder.topLeft       = Point(plotDimensions.subWidth*0.1,
                                         plotDimensions.subHeight*0.9)
        plotBorder.topRight      = Point(plotDimensions.subWidth*0.9,
                                         plotDimensions.subHeight*0.9)
        plotBorder.bottomLeft    = Point(plotDimensions.subWidth*0.1,
                                         plotDimensions.subHeight*0.1)
        plotBorder.bottomRight   = Point(plotDimensions.subWidth*0.9,
                                         plotDimensions.subHeight*0.1)
        plotLegend.legendTopLeft = Point(plotBorder.topLeft.x + Float(20),
                                         plotBorder.topLeft.y - Float(20))
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
        plotBorder.topLeft       = Point(plotDimensions.subWidth*0.1,
                                         plotDimensions.subHeight*0.9)
        plotBorder.topRight      = Point(plotDimensions.subWidth*0.9,
                                         plotDimensions.subHeight*0.9)
        plotBorder.bottomLeft    = Point(plotDimensions.subWidth*0.1,
                                         plotDimensions.subHeight*0.1)
        plotBorder.bottomRight   = Point(plotDimensions.subWidth*0.9,
                                         plotDimensions.subHeight*0.1)
        plotLegend.legendTopLeft = Point(plotBorder.topLeft.x + Float(20),
                                         plotBorder.topLeft.y - Float(20))
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

    public func drawGraphOutput(fileName name: String = "swift_plot_scatter_plot", renderer: Renderer){
        renderer.plotDimensions = plotDimensions
        renderer.drawOutput(fileName: name)
    }

    // functions implementing plotting logic
    func calcLabelLocations(renderer: Renderer){
        if (plotLabel != nil) {
            let xWidth: Float = renderer.getTextWidth(text: plotLabel!.xLabel,
                                                      textSize: plotLabel!.labelSize)
            let yWidth: Float = renderer.getTextWidth(text: plotLabel!.yLabel,
                                                      textSize: plotLabel!.labelSize)
            plotLabel!.xLabelLocation = Point(((plotBorder.bottomRight.x + plotBorder.bottomLeft.x)*Float(0.5)) - xWidth*Float(0.5),
                                              plotBorder.bottomLeft.y - plotLabel!.labelSize - 0.05*plotDimensions.graphHeight)
            plotLabel!.yLabelLocation = Point((plotBorder.bottomLeft.x - plotLabel!.labelSize - 0.05*plotDimensions.graphWidth),
                                              ((plotBorder.bottomLeft.y + plotBorder.topLeft.y)*Float(0.5) - yWidth))
        }
        if (plotTitle != nil) {
          let titleWidth: Float = renderer.getTextWidth(text: plotTitle!.title, textSize: plotTitle!.titleSize)
          plotTitle!.titleLocation = Point(((plotBorder.topRight.x + plotBorder.topLeft.x)*Float(0.5)) - titleWidth*Float(0.5),
                                           plotBorder.topLeft.y + plotTitle!.titleSize*Float(0.5))
        }
    }

    func calcMarkerLocAndScalePts(renderer: Renderer){

        plotMarkers.xMarkers = [Point]()
        plotMarkers.yMarkers = [Point]()
        plotMarkers.xMarkersTextLocation = [Point]()
        plotMarkers.yMarkersTextLocation = [Point]()
        plotMarkers.xMarkersText = [String]()
        plotMarkers.xMarkersText = [String]()

        var maximumX: T = maxX(points: series[0].values)
        var maximumY: U = maxY(points: series[0].values)
        var minimumX: T = minX(points: series[0].values)
        var minimumY: U = minY(points: series[0].values)

        for index in 1..<series.count {

            let s: Series<T,U> = series[index]
            var x: T = maxX(points: s.values)
            var y: U = maxY(points: s.values)
            if (x > maximumX) {
                maximumX = x
            }
            if (y > maximumY) {
                maximumY = y
            }
            x = minX(points: s.values)
            y = minY(points: s.values)
            if (x < minimumX) {
                minimumX = x
            }
            if (y < minimumY) {
                minimumY = y
            }
        }

        let origin = Point((plotDimensions.graphWidth/Float(maximumX-minimumX))*Float(T(-1)*minimumX),
                           (plotDimensions.graphHeight/Float(maximumY-minimumY))*Float(U(-1)*minimumY))

        let rightScaleMargin: Float = (plotDimensions.subWidth - plotDimensions.graphWidth)*Float(0.5) - 10.0;
        let topScaleMargin: Float = (plotDimensions.subHeight - plotDimensions.graphHeight)*Float(0.5) - 10.0;
        scaleX = Float(maximumX - minimumX) / (plotDimensions.graphWidth - rightScaleMargin);
        scaleY = Float(maximumY - minimumY) / (plotDimensions.graphHeight - topScaleMargin);

        let nD1: Int = max(getNumberOfDigits(Float(maximumY)), getNumberOfDigits(Float(minimumY)))
        var v1: Float
        if (nD1 > 1 && maximumY <= U(pow(Float(10), Float(nD1 - 1)))) {
            v1 = Float(pow(Float(10), Float(nD1 - 2)))
        } else if (nD1 > 1) {
            v1 = Float(pow(Float(10), Float(nD1 - 1)))
        } else {
            v1 = Float(pow(Float(10), Float(0)))
        }

        let nY: Float = v1/scaleY
        var inc1: Float = nY
        if(plotDimensions.graphHeight/nY > MAX_DIV){
            inc1 = (plotDimensions.graphHeight/nY)*inc1/MAX_DIV
        }

        let nD2: Int = max(getNumberOfDigits(Float(maximumX)), getNumberOfDigits(Float(minimumX)))
        var v2: Float
        if (nD2 > 1 && maximumX <= T(pow(Float(10), Float(nD2 - 1)))) {
            v2 = Float(pow(Float(10), Float(nD2 - 2)))
        } else if (nD2 > 1) {
            v2 = Float(pow(Float(10), Float(nD2 - 1)))
        } else {
            v2 = Float(pow(Float(10), Float(0)))
        }

        let nX: Float = v2/scaleX
        var inc2: Float = nX
        var noXD: Float = plotDimensions.graphWidth/nX
        if(noXD > MAX_DIV){
            inc2 = (plotDimensions.graphWidth/nX)*inc2/MAX_DIV
            noXD = MAX_DIV
        }

        var xM = Float(origin.x)
        while xM<=plotDimensions.graphWidth {
            if(xM+inc2<0.0 || xM<0.0) {
                xM = xM+inc2
                continue
            }
            let p = Point(xM, 0)
            plotMarkers.xMarkers.append(p)
            let text_p = Point(xM - (renderer.getTextWidth(text: "\(floor(scaleX*(xM-origin.x)))",
                                                           textSize: plotMarkers.markerTextSize)/2.0) + 8,
                               -15)
            plotMarkers.xMarkersTextLocation.append(text_p)
            plotMarkers.xMarkersText.append("\(round(scaleX*(xM-origin.x)))")
            xM = xM + inc2
        }

        xM = origin.x - inc2
        while xM>0.0 {
            if (xM > plotDimensions.graphWidth) {
                xM = xM - inc2
                continue
            }
            let p = Point(xM, 0)
            plotMarkers.xMarkers.append(p)
            let text_p = Point(xM - (renderer.getTextWidth(text: "\(ceil(scaleX*(xM-origin.x)))",
                                                           textSize: plotMarkers.markerTextSize)/2.0) + 8,
                               -15)
            plotMarkers.xMarkersTextLocation.append(text_p)
            plotMarkers.xMarkersText.append("\(round(scaleX*(xM-origin.x)))")
            xM = xM - inc2
        }

        var yM = origin.y
        while yM<=plotDimensions.graphHeight {
            if(yM+inc1<0.0 || yM<0.0){
                yM = yM + inc1
                continue
            }
            let p = Point(0, yM)
            plotMarkers.yMarkers.append(p)
            let text_p = Point(-(renderer.getTextWidth(text: "\(ceil(scaleY*(yM-origin.y)))",
                                                       textSize: plotMarkers.markerTextSize)+5),
                               yM - 4)
            plotMarkers.yMarkersTextLocation.append(text_p)
            plotMarkers.yMarkersText.append("\(ceil(scaleY*(yM-origin.y)))")
            yM = yM + inc1
        }
        yM = origin.y - inc1
        while yM>0.0 {
            let p = Point(0, yM)
            plotMarkers.yMarkers.append(p)
            let text_p = Point(-(renderer.getTextWidth(text: "\(floor(scaleY*(yM-origin.y)))",
                                                       textSize: plotMarkers.markerTextSize)+5),
                               yM - 4)
            plotMarkers.yMarkersTextLocation.append(text_p)
            plotMarkers.yMarkersText.append("\(floor(scaleY*(yM-origin.y)))")
            yM = yM - inc1
        }



        // scale points to be plotted according to plot size
        let scaleXInv: Float = 1.0/scaleX;
        let scaleYInv: Float = 1.0/scaleY
        for i in 0..<series.count {
            series[i].scaledValues.removeAll();
            for j in 0..<series[i].count {
                let scaledPair = Pair<T,U>(((series[i])[j].x)*T(scaleXInv) + T(origin.x),
                                           ((series[i])[j].y)*U(scaleYInv) + U(origin.y))
                if (Float(scaledPair.x) >= 0.0 && Float(scaledPair.x) <= plotDimensions.graphWidth && Float(scaledPair.y) >= 0.0 && Float(scaledPair.y) <= plotDimensions.graphHeight) {
                    series[i].scaledValues.append(scaledPair)
                }
            }
        }
    }

    //functions to draw the plot
    func drawBorder(renderer: Renderer){
        renderer.drawRect(topLeftPoint: plotBorder.topLeft,
                          topRightPoint: plotBorder.topRight,
                          bottomRightPoint: plotBorder.bottomRight,
                          bottomLeftPoint: plotBorder.bottomLeft,
                          strokeWidth: plotBorder.borderThickness,
                          strokeColor: Color.black,
                          isOriginShifted: false)
    }

    func drawGrid(renderer: Renderer) {
        if (enableGrid) {
            for index in 0..<plotMarkers.xMarkers.count {
                let p1 = Point(plotMarkers.xMarkers[index].x, 0)
                let p2 = Point(plotMarkers.xMarkers[index].x, plotDimensions.graphHeight)
                renderer.drawLine(startPoint: p1,
                                  endPoint: p2,
                                  strokeWidth: gridLineThickness,
                                  strokeColor: gridColor,
                                  isDashed: false,
                                  isOriginShifted: true)
            }
            for index in 0..<plotMarkers.yMarkers.count {
                let p1 = Point(0, plotMarkers.yMarkers[index].y)
                let p2 = Point(plotDimensions.graphWidth, plotMarkers.yMarkers[index].y)
                renderer.drawLine(startPoint: p1,
                                  endPoint: p2,
                                  strokeWidth: gridLineThickness,
                                  strokeColor: gridColor,
                                  isDashed: false,
                                  isOriginShifted: true)
            }
        }
    }

    func drawMarkers(renderer: Renderer) {
        for index in 0..<plotMarkers.xMarkers.count {
            let p1 = Point(plotMarkers.xMarkers[index].x, -3)
            let p2 = Point(plotMarkers.xMarkers[index].x, 0)
            renderer.drawLine(startPoint: p1,
                              endPoint: p2,
                              strokeWidth: plotBorder.borderThickness,
                              strokeColor: Color.black,
                              isDashed: false,
                              isOriginShifted: true)
            renderer.drawText(text: plotMarkers.xMarkersText[index],
                              location: plotMarkers.xMarkersTextLocation[index],
                              textSize: plotMarkers.markerTextSize,
                              strokeWidth: 0.7,
                              angle: 0,
                              isOriginShifted: true)
        }

        for index in 0..<plotMarkers.yMarkers.count {
            let p1 = Point(-3, plotMarkers.yMarkers[index].y)
            let p2 = Point(0, plotMarkers.yMarkers[index].y)
            renderer.drawLine(startPoint: p1,
                              endPoint: p2,
                              strokeWidth: plotBorder.borderThickness,
                              strokeColor: Color.black,
                              isDashed: false,
                              isOriginShifted: true)
            renderer.drawText(text: plotMarkers.yMarkersText[index],
                              location: plotMarkers.yMarkersTextLocation[index],
                              textSize: plotMarkers.markerTextSize,
                              strokeWidth: 0.7,
                              angle: 0,
                              isOriginShifted: true)
        }
    }

    func drawPlots(renderer: Renderer) {
        for seriesIndex in 0..<series.count {
            var s = series[seriesIndex]
            s.maxY = maxY(points: s.scaledValues)
            s.minY = minY(points: s.scaledValues)
            let seriesYRangeInverse: Float = 1.0/Float(s.maxY!-s.minY!)
            switch s.scatterPlotSeriesOptions.scatterPattern {
                case .circle:
                    for index in 0..<s.scaledValues.count {
                        let p = Point(Float(s.scaledValues[index].x),Float(s.scaledValues[index].y))
                        if (s.startColor != nil && s.endColor != nil) {
                            s.color = lerp(startColor: s.startColor!,
                                           endColor: s.endColor!,
                                           Float(s.scaledValues[index].y-s.minY!)*seriesYRangeInverse)
                        }
                        renderer.drawSolidCircle(center: p,
                                                 radius: scatterPatternSize*Float(0.5),
                                                 fillColor: s.color,
                                                 isOriginShifted: true)
                    }
                case .square:
                  for index in 0..<s.scaledValues.count {
                      let p = Point(Float(s.scaledValues[index].x),Float(s.scaledValues[index].y))
                      if (s.startColor != nil && s.endColor != nil) {
                          s.color = lerp(startColor: s.startColor!,
                                         endColor: s.endColor!,
                                         Float(s.scaledValues[index].y-s.minY!)*seriesYRangeInverse)
                      }
                      let tL = Point(p.x-scatterPatternSize*Float(0.5),
                                     p.y+scatterPatternSize*Float(0.5))
                      let tR = Point(p.x+scatterPatternSize*Float(0.5),
                                     p.y+scatterPatternSize*Float(0.5))
                      let bR = Point(p.x+scatterPatternSize*Float(0.5),
                                     p.y-scatterPatternSize*Float(0.5))
                      let bL = Point(p.x-scatterPatternSize*Float(0.5),
                                     p.y-scatterPatternSize*Float(0.5))
                      renderer.drawSolidRect(topLeftPoint: tL,
                                             topRightPoint: tR,
                                             bottomRightPoint: bR,
                                             bottomLeftPoint: bL,
                                             fillColor: s.color,
                                             hatchPattern: .none,
                                             isOriginShifted: true)
                  }
                case .triangle:
                    let r = scatterPatternSize/sqrt3
                    for index in 0..<s.scaledValues.count {
                        let p = Point(Float(s.scaledValues[index].x),Float(s.scaledValues[index].y))
                        if (s.startColor != nil && s.endColor != nil) {
                            s.color = lerp(startColor: s.startColor!,
                                           endColor: s.endColor!,
                                           Float(s.scaledValues[index].y-s.minY!)*seriesYRangeInverse)
                        }
                        let p1 = Point(p.x + 0,
                                       p.y + r)
                        let p2 = Point(p.x + r*sqrt3/Float(2),
                                       p.y - r*Float(0.5))
                        let p3 = Point(p.x - r*sqrt3/Float(2),
                                       p.y - r*Float(0.5))
                        renderer.drawSolidTriangle(point1: p1,
                                                   point2: p2,
                                                   point3: p3,
                                                   fillColor: s.color,
                                                   isOriginShifted: true)
                    }
                case .diamond:
                    for index in 0..<s.scaledValues.count {
                        let p = Point(Float(s.scaledValues[index].x),Float(s.scaledValues[index].y))
                        if (s.startColor != nil && s.endColor != nil) {
                            s.color = lerp(startColor: s.startColor!,
                                           endColor: s.endColor!,
                                           Float(s.scaledValues[index].y-s.minY!)*seriesYRangeInverse)
                        }
                        var tL = Point(p.x-scatterPatternSize*Float(0.5),
                                       p.y+scatterPatternSize*Float(0.5))
                        var tR = Point(p.x+scatterPatternSize*Float(0.5),
                                       p.y+scatterPatternSize*Float(0.5))
                        var bR = Point(p.x+scatterPatternSize*Float(0.5),
                                       p.y-scatterPatternSize*Float(0.5))
                        var bL = Point(p.x-scatterPatternSize*Float(0.5),
                                       p.y-scatterPatternSize*Float(0.5))
                        tL = rotatePoint(point: tL, center: p, angleDegrees: 45.0)
                        tR = rotatePoint(point: tR, center: p, angleDegrees: 45.0)
                        bL = rotatePoint(point: bL, center: p, angleDegrees: 45.0)
                        bR = rotatePoint(point: bR, center: p, angleDegrees: 45.0)
                        let diamondPoints: [Point] = [tL, tR, bR, bL]
                        renderer.drawSolidPolygon(points: diamondPoints,
                                                  fillColor: s.color,
                                                  isOriginShifted: true)
                    }
                  case .hexagon:
                      for index in 0..<s.scaledValues.count {
                          let p = Point(Float(s.scaledValues[index].x),Float(s.scaledValues[index].y))
                          if (s.startColor != nil && s.endColor != nil) {
                              s.color = lerp(startColor: s.startColor!,
                                             endColor: s.endColor!,
                                             Float(s.scaledValues[index].y-s.minY!)*seriesYRangeInverse)
                          }
                          var hexagonPoint = Point(p.x + 0.0,
                                                   p.y + scatterPatternSize*Float(0.5))
                          var hexagonPoints: [Point] = [hexagonPoint]
                          for _ in 2...6 {
                              hexagonPoint = rotatePoint(point: hexagonPoint,
                                                         center: p,
                                                         angleDegrees: 60.0)
                              hexagonPoints.append(hexagonPoint)
                          }
                          renderer.drawSolidPolygon(points: hexagonPoints,
                                                    fillColor: s.color,
                                                    isOriginShifted: true)
                      }
                  case .pentagon:
                      for index in 0..<s.scaledValues.count {
                          let p = Point(Float(s.scaledValues[index].x),Float(s.scaledValues[index].y))
                          if (s.startColor != nil && s.endColor != nil) {
                              s.color = lerp(startColor: s.startColor!,
                                             endColor: s.endColor!,
                                             Float(s.scaledValues[index].y-s.minY!)*seriesYRangeInverse)
                          }
                          var pentagonPoint = Point(p.x + 0.0,
                                                    p.y + scatterPatternSize*Float(0.5))
                          var pentagonPoints: [Point] = [pentagonPoint]
                          for _ in 2...6 {
                              pentagonPoint = rotatePoint(point: pentagonPoint,
                                                          center: p,
                                                          angleDegrees: 72.0)
                              pentagonPoints.append(pentagonPoint)
                          }
                          renderer.drawSolidPolygon(points: pentagonPoints,
                                                    fillColor: s.color,
                                                    isOriginShifted: true)
                      }
                  case .star:
                      for index in 0..<s.scaledValues.count {
                          let p = Point(Float(s.scaledValues[index].x),Float(s.scaledValues[index].y))
                          if (s.startColor != nil && s.endColor != nil) {
                              s.color = lerp(startColor: s.startColor!,
                                             endColor: s.endColor!,
                                             Float(s.scaledValues[index].y-s.minY!)*seriesYRangeInverse)
                          }
                          var starOuterPoint = Point(p.x + 0.0,
                                                     p.y + scatterPatternSize*Float(0.5))
                          var starInnerPoint = rotatePoint(point: Point(p.x + 0.0,
                                                                        p.y + scatterPatternSize*Float(0.25)),
                                                           center: p,
                                                           angleDegrees: 36.0)
                          var starPoints: [Point] = [starOuterPoint, starInnerPoint]
                          for _ in 2...6 {
                              starInnerPoint = rotatePoint(point: starInnerPoint,
                                                           center: p,
                                                           angleDegrees: 72.0)
                              starOuterPoint = rotatePoint(point: starOuterPoint,
                                                           center: p,
                                                           angleDegrees: 72.0)
                              starPoints.append(starOuterPoint)
                              starPoints.append(starInnerPoint)
                          }
                          renderer.drawSolidPolygon(points: starPoints,
                                                    fillColor: s.color,
                                                    isOriginShifted: true)
                      }
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
        for s in series {
            let w = renderer.getTextWidth(text: s.label,
                                          textSize: plotLegend.legendTextSize)
            if (w > maxWidth) {
                maxWidth = w
            }
        }

        plotLegend.legendWidth  = maxWidth + 3.5*plotLegend.legendTextSize
        plotLegend.legendHeight = (Float(series.count)*2.0 + 1.0)*plotLegend.legendTextSize

        let p1 = Point(plotLegend.legendTopLeft.x,
                       plotLegend.legendTopLeft.y)
        let p2 = Point(plotLegend.legendTopLeft.x + plotLegend.legendWidth,
                       plotLegend.legendTopLeft.y)
        let p3 = Point(plotLegend.legendTopLeft.x + plotLegend.legendWidth,
                       plotLegend.legendTopLeft.y - plotLegend.legendHeight)
        let p4 = Point(plotLegend.legendTopLeft.x,
                       plotLegend.legendTopLeft.y - plotLegend.legendHeight)

        renderer.drawSolidRectWithBorder(topLeftPoint: p1,
                                         topRightPoint: p2,
                                         bottomRightPoint: p3,
                                         bottomLeftPoint: p4,
                                         strokeWidth: plotBorder.borderThickness,
                                         fillColor: Color.transluscentWhite,
                                         borderColor: Color.black,
                                         isOriginShifted: false)

        for i in 0..<series.count {
            let tL = Point(plotLegend.legendTopLeft.x + plotLegend.legendTextSize,
                           plotLegend.legendTopLeft.y - (2.0*Float(i) + 1.0)*plotLegend.legendTextSize)
            let bR = Point(tL.x + plotLegend.legendTextSize,
                           tL.y - plotLegend.legendTextSize)
            let tR = Point(bR.x, tL.y)
            let bL = Point(tL.x, bR.y)
            if (series[i].startColor != nil && series[i].endColor != nil) {
                series[i].color = series[i].startColor!
            }
            switch series[i].scatterPlotSeriesOptions.scatterPattern {
                case .circle:
                    let c = Point((tL.x+bR.x)*Float(0.5),
                                  (tL.y+bR.y)*Float(0.5))
                    renderer.drawSolidCircle(center: c,
                                             radius: (tR.x-tL.x)*Float(0.5),
                                             fillColor: series[i].color,
                                             isOriginShifted: false)
                case .square:
                    renderer.drawSolidRect(topLeftPoint: tL,
                                           topRightPoint: tR,
                                           bottomRightPoint: bR,
                                           bottomLeftPoint: bL,
                                           fillColor: series[i].color,
                                           hatchPattern: .none,
                                           isOriginShifted: false)
                case .triangle:
                    let c = Point((tL.x+bR.x)*Float(0.5),
                                  (tL.y+bR.y)*Float(0.5))
                    let r: Float = (tR.x-tL.x)*Float(0.5)
                    let p1 = Point(c.x + 0,
                                   c.y + r)
                    let p2 = Point(c.x + r*sqrt3*Float(0.5),
                                   c.y - r*Float(0.5))
                    let p3 = Point(c.x - r*sqrt3*Float(0.5),
                                   c.y - r*Float(0.5))
                    renderer.drawSolidTriangle(point1: p1,
                                               point2: p2,
                                               point3: p3,
                                               fillColor: series[i].color,
                                               isOriginShifted: false)
                case .diamond:
                    let c = Point((tL.x+bR.x)*Float(0.5),
                                  (tL.y+bR.y)*Float(0.5))
                    let p1 = rotatePoint(point: tL, center: c, angleDegrees: 45.0)
                    let p2 = rotatePoint(point: tR, center: c, angleDegrees: 45.0)
                    let p3 = rotatePoint(point: bR, center: c, angleDegrees: 45.0)
                    let p4 = rotatePoint(point: bL, center: c, angleDegrees: 45.0)
                    let diamondPoints: [Point] = [p1, p2, p3, p4]
                    renderer.drawSolidPolygon(points: diamondPoints,
                                              fillColor: series[i].color,
                                              isOriginShifted: false)
                case .hexagon:
                  let c = Point((tL.x+bR.x)*Float(0.5),
                                (tL.y+bR.y)*Float(0.5))
                  var hexagonPoint = Point(c.x + 0.0,
                                           c.y + (tL.y-bL.y)*Float(0.5))
                  var hexagonPoints: [Point] = [hexagonPoint]
                  for _ in 2...6 {
                      hexagonPoint = rotatePoint(point: hexagonPoint,
                                                 center: c,
                                                 angleDegrees: 60.0)
                      hexagonPoints.append(hexagonPoint)
                  }
                  renderer.drawSolidPolygon(points: hexagonPoints,
                                            fillColor: series[i].color,
                                            isOriginShifted: false)
                case .pentagon:
                  let c = Point((tL.x+bR.x)*Float(0.5),
                                (tL.y+bR.y)*Float(0.5))
                  var pentagonPoint = Point(c.x + 0.0,
                                            c.y + (tL.y-bL.y)*Float(0.5))
                  var pentagonPoints: [Point] = [pentagonPoint]
                  for _ in 2...6 {
                      pentagonPoint = rotatePoint(point: pentagonPoint,
                                                  center: c,
                                                  angleDegrees: 72.0)
                      pentagonPoints.append(pentagonPoint)
                  }
                  renderer.drawSolidPolygon(points: pentagonPoints,
                                            fillColor: series[i].color,
                                            isOriginShifted: false)
                case .star:
                  let c = Point((tL.x+bR.x)*Float(0.5),
                                (tL.y+bR.y)*Float(0.5))
                  var starOuterPoint = Point(c.x + 0.0,
                                             c.y + (tL.y-bL.y)*Float(0.5))
                  var starInnerPoint = rotatePoint(point: Point(c.x + 0.0,
                                                                c.y + (tL.y-bL.y)*Float(0.25)),
                                                   center: c,
                                                   angleDegrees: 36.0)
                  var starPoints: [Point] = [starOuterPoint, starInnerPoint]
                  for _ in 2...6 {
                      starOuterPoint = rotatePoint(point: starOuterPoint,
                                                   center: c,
                                                   angleDegrees: 72.0)
                      starInnerPoint = rotatePoint(point: starInnerPoint,
                                                   center: c,
                                                   angleDegrees: 72.0)
                      starPoints.append(starOuterPoint)
                      starPoints.append(starInnerPoint)
                  }
                  renderer.drawSolidPolygon(points: starPoints,
                                            fillColor: series[i].color,
                                            isOriginShifted: false)
            }
            let p = Point(bR.x + plotLegend.legendTextSize,
                          bR.y)
            renderer.drawText(text: series[i].label,
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
