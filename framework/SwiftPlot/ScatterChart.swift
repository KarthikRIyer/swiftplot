import Foundation

// class defining a lineGraph and all its logic
public class ScatterPlot: Plot {

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
            plotBorder.topLeft       = Pair<FloatConvertible,FloatConvertible>(newValue.subWidth*0.1,
                                                                               newValue.subHeight*0.9)
            plotBorder.topRight      = Pair<FloatConvertible,FloatConvertible>(newValue.subWidth*0.9,
                                                                               newValue.subHeight*0.9)
            plotBorder.bottomLeft    = Pair<FloatConvertible,FloatConvertible>(newValue.subWidth*0.1,
                                                                               newValue.subHeight*0.1)
            plotBorder.bottomRight   = Pair<FloatConvertible,FloatConvertible>(newValue.subWidth*0.9,
                                                                               newValue.subHeight*0.1)
            plotLegend.legendTopLeft = Pair<FloatConvertible,FloatConvertible>(Float(plotBorder.topLeft.x) + Float(20),
                                                                               Float(plotBorder.topLeft.y) - Float(20))
        }
    }

    var scaleX: Float = 1
    var scaleY: Float = 1
    var plotMarkers: PlotMarkers = PlotMarkers()
    var series = [Series<FloatConvertible,FloatConvertible>]()

    public var plotLineThickness: Float = 3
    public var scatterPatternSize: Float = 10

    public init(pairs p: [Pair<FloatConvertible,FloatConvertible>], width: Float = 1000, height: Float = 660){
        plotDimensions = PlotDimensions(frameWidth: width, frameHeight: height)
        plotDimensions.calculateGraphDimensions()

        let s = Series(pairs: p,label: "Plot")
        series.append(s)
    }

    public init(width: Float = 1000, height: Float = 660){
        plotDimensions = PlotDimensions(frameWidth: width, frameHeight: height)
    }

    // functions to add series
    public func addSeries(_ s: Series<FloatConvertible,FloatConvertible>){
        series.append(s)
    }
    public func addSeries(pairs : [Pair<FloatConvertible,FloatConvertible>],
                          label: String,
                          color: Color = .lightBlue,
                          scatterPattern: ScatterPlotSeriesOptions.ScatterPattern = .circle){
        let s = Series(pairs: pairs,label: label, color: color, scatterPattern: scatterPattern)
        addSeries(s)
    }
    public func addSeries<T: FloatConvertible>(_ x: [T],
                                               _ y: [T],
                                               label: String,
                                               color: Color = .lightBlue,
                                               scatterPattern: ScatterPlotSeriesOptions.ScatterPattern = .circle){
        var pairs = [Pair<FloatConvertible,FloatConvertible>]()
        for i in 0..<x.count {
            pairs.append(Pair<FloatConvertible,FloatConvertible>(x[i], y[i]))
        }
        let s = Series(pairs: pairs,
                       label: label,
                       color: color,
                       scatterPattern: scatterPattern)
        addSeries(s)
    }
    public func addSeries<T: FloatConvertible>(_ x: [T],
                                               _ y: [T],
                                               label: String,
                                               startColor: Color = .lightBlue,
                                               endColor: Color = .lightBlue,
                                               scatterPattern: ScatterPlotSeriesOptions.ScatterPattern = .circle){
        var pairs = [Pair<FloatConvertible,FloatConvertible>]()
        for i in 0..<x.count {
            pairs.append(Pair<FloatConvertible,FloatConvertible>(x[i], y[i]))
        }
        let s = Series(pairs: pairs,
                       label: label,
                       startColor: startColor,
                       endColor: endColor,
                       scatterPattern: scatterPattern)
        addSeries(s)
    }
    public func addSeries<T: FloatConvertible>(_ y: [T],
                                               label: String,
                                               color: Color = .lightBlue,
                                               scatterPattern: ScatterPlotSeriesOptions.ScatterPattern = .circle){
        var pairs = [Pair<FloatConvertible,FloatConvertible>]()
        for i in 0..<y.count {
            pairs.append(Pair<FloatConvertible,FloatConvertible>(Float(i+1), y[i]))
        }
        let s = Series(pairs: pairs,
                       label: label,
                       color: color,
                       scatterPattern: scatterPattern)
        addSeries(s)
    }
    public func addSeries<T: FloatConvertible>(_ y: [T],
                                               label: String,
                                               startColor: Color = .lightBlue,
                                               endColor: Color = .lightBlue,
                                               scatterPattern: ScatterPlotSeriesOptions.ScatterPattern = .circle){
        var pairs = [Pair<FloatConvertible,FloatConvertible>]()
        for i in 0..<y.count {
            pairs.append(Pair<FloatConvertible,FloatConvertible>(Float(i+1), y[i]))
        }
        let s = Series(pairs: pairs,
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
    public func drawGraphAndOutput(fileName name: String = "swift_plot_line_graph", renderer: Renderer){
        renderer.xOffset = xOffset
        renderer.yOffset = yOffset
        renderer.plotDimensions = plotDimensions
        plotBorder.topLeft       = Pair<FloatConvertible,FloatConvertible>(plotDimensions.subWidth*0.1,
                                                                           plotDimensions.subHeight*0.9)
        plotBorder.topRight      = Pair<FloatConvertible,FloatConvertible>(plotDimensions.subWidth*0.9,
                                                                           plotDimensions.subHeight*0.9)
        plotBorder.bottomLeft    = Pair<FloatConvertible,FloatConvertible>(plotDimensions.subWidth*0.1,
                                                                           plotDimensions.subHeight*0.1)
        plotBorder.bottomRight   = Pair<FloatConvertible,FloatConvertible>(plotDimensions.subWidth*0.9,
                                                                           plotDimensions.subHeight*0.1)
        plotLegend.legendTopLeft = Pair<FloatConvertible,FloatConvertible>(Float(plotBorder.topLeft.x) + Float(20),
                                                                           Float(plotBorder.topLeft.y) - Float(20))
        calcLabelLocations(renderer: renderer)
        calcMarkerLocAndScalePts(renderer: renderer)
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
        plotBorder.topLeft       = Pair<FloatConvertible,FloatConvertible>(plotDimensions.subWidth*0.1,
                                                                           plotDimensions.subHeight*0.9)
        plotBorder.topRight      = Pair<FloatConvertible,FloatConvertible>(plotDimensions.subWidth*0.9,
                                                                           plotDimensions.subHeight*0.9)
        plotBorder.bottomLeft    = Pair<FloatConvertible,FloatConvertible>(plotDimensions.subWidth*0.1,
                                                                           plotDimensions.subHeight*0.1)
        plotBorder.bottomRight   = Pair<FloatConvertible,FloatConvertible>(plotDimensions.subWidth*0.9,
                                                                           plotDimensions.subHeight*0.1)
        plotLegend.legendTopLeft = Pair<FloatConvertible,FloatConvertible>(Float(plotBorder.topLeft.x) + Float(20),
                                                                           Float(plotBorder.topLeft.y) - Float(20))
        calcLabelLocations(renderer: renderer)
        calcMarkerLocAndScalePts(renderer: renderer)
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
            plotLabel!.xLabelLocation = Pair<FloatConvertible,FloatConvertible>(((Float(plotBorder.bottomRight.x) + Float(plotBorder.bottomLeft.x))*Float(0.5)) - xWidth*Float(0.5),
                                                                                Float(plotBorder.bottomLeft.y) - plotLabel!.labelSize - 0.05*plotDimensions.graphHeight)
            plotLabel!.yLabelLocation = Pair<FloatConvertible,FloatConvertible>((Float(plotBorder.bottomLeft.x) - plotLabel!.labelSize - 0.05*plotDimensions.graphWidth),
                                                                                ((Float(plotBorder.bottomLeft.y) + Float(plotBorder.topLeft.y))*Float(0.5) - yWidth))
        }
        if (plotTitle != nil) {
          let titleWidth: Float = renderer.getTextWidth(text: plotTitle!.title, textSize: plotTitle!.titleSize)
          plotTitle!.titleLocation = Pair<FloatConvertible,FloatConvertible>(((Float(plotBorder.topRight.x) + Float(plotBorder.topLeft.x))*Float(0.5)) - titleWidth*Float(0.5),
                                                                             Float(plotBorder.topLeft.y) + plotTitle!.titleSize*Float(0.5))
        }
    }

    func calcMarkerLocAndScalePts(renderer: Renderer){

        plotMarkers.xMarkers = [Pair<FloatConvertible,FloatConvertible>]()
        plotMarkers.yMarkers = [Pair<FloatConvertible,FloatConvertible>]()
        plotMarkers.xMarkersTextLocation = [Pair<FloatConvertible,FloatConvertible>]()
        plotMarkers.yMarkersTextLocation = [Pair<FloatConvertible,FloatConvertible>]()
        plotMarkers.xMarkersText = [String]()
        plotMarkers.xMarkersText = [String]()

        var maximumX: Float = getMaxX(pairs: series[0].pairs)
        var maximumY: Float = getMaxY(pairs: series[0].pairs)
        var minimumX: Float = getMinX(pairs: series[0].pairs)
        var minimumY: Float = getMinY(pairs: series[0].pairs)

        for index in 1..<series.count {

            let s: Series<FloatConvertible,FloatConvertible> = series[index]
            let pairs = s.pairs
            var x: Float = getMaxX(pairs: pairs)
            var y: Float = getMaxY(pairs: pairs)
            if (x > maximumX) {
                maximumX = x
            }
            if (y > maximumY) {
                maximumY = y
            }
            x = getMinX(pairs: pairs)
            y = getMinY(pairs: pairs)
            if (x < minimumX) {
                minimumX = x
            }
            if (y < minimumY) {
                minimumY = y
            }
        }

        let origin: Pair<FloatConvertible,FloatConvertible> = Pair<FloatConvertible,FloatConvertible>((plotDimensions.graphWidth/(maximumX-minimumX))*(-minimumX),
                                                                                                      (plotDimensions.graphHeight/(maximumY-minimumY))*(-minimumY))

        let rightScaleMargin: Float = (plotDimensions.subWidth - plotDimensions.graphWidth)*Float(0.5) - 10.0;
        let topScaleMargin: Float = (plotDimensions.subHeight - plotDimensions.graphHeight)*Float(0.5) - 10.0;
        scaleX = (maximumX - minimumX) / (plotDimensions.graphWidth - rightScaleMargin);
        scaleY = (maximumY - minimumY) / (plotDimensions.graphHeight - topScaleMargin);

        let nD1: Int = max(getNumberOfDigits(maximumY), getNumberOfDigits(minimumY))
        var v1: Float
        if (nD1 > 1 && maximumY <= pow(Float(10), Float(nD1 - 1))) {
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

        let nD2: Int = max(getNumberOfDigits(maximumX), getNumberOfDigits(minimumX))
        var v2: Float
        if (nD2 > 1 && maximumX <= pow(Float(10), Float(nD2 - 1))) {
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
            let p = Pair<FloatConvertible,FloatConvertible>(xM, 0)
            plotMarkers.xMarkers.append(p)
            let text_p = Pair<FloatConvertible,FloatConvertible>(xM - (renderer.getTextWidth(text: "\(floor(scaleX*(xM-Float(origin.x))))",
                                                                                             textSize: plotMarkers.markerTextSize)/2.0) + 8,
                                                                 -15)
            plotMarkers.xMarkersTextLocation.append(text_p)
            plotMarkers.xMarkersText.append("\(floor(scaleX*(xM-Float(origin.x))))")
            xM = xM + inc2
        }

        xM = Float(origin.x) - inc2
        while xM>0.0 {
            if (xM > plotDimensions.graphWidth) {
                xM = xM - inc2
                continue
            }
            let p = Pair<FloatConvertible,FloatConvertible>(xM, 0)
            plotMarkers.xMarkers.append(p)
            let text_p = Pair<FloatConvertible,FloatConvertible>(xM - (renderer.getTextWidth(text: "\(ceil(scaleX*(xM-Float(origin.x))))",
                                                                                             textSize: plotMarkers.markerTextSize)/2.0) + 8,
                                                                 -15)
            plotMarkers.xMarkersTextLocation.append(text_p)
            plotMarkers.xMarkersText.append("\(ceil(scaleX*(xM-Float(origin.x))))")
            xM = xM - inc2
        }

        var yM = Float(origin.y)
        while yM<=plotDimensions.graphHeight {
            if(yM+inc1<0.0 || yM<0.0){
                yM = yM + inc1
                continue
            }
            let p = Pair<FloatConvertible,FloatConvertible>(0, yM)
            plotMarkers.yMarkers.append(p)
            let text_p = Pair<FloatConvertible,FloatConvertible>(-(renderer.getTextWidth(text: "\(ceil(scaleY*(yM-Float(origin.y))))",
                                                                                         textSize: plotMarkers.markerTextSize)+5),
                                                                 yM - 4)
            plotMarkers.yMarkersTextLocation.append(text_p)
            plotMarkers.yMarkersText.append("\(ceil(scaleY*(yM-Float(origin.y))))")
            yM = yM + inc1
        }
        yM = Float(origin.y) - inc1
        while yM>0.0 {
            let p = Pair<FloatConvertible,FloatConvertible>(0, yM)
            plotMarkers.yMarkers.append(p)
            let text_p = Pair<FloatConvertible,FloatConvertible>(-(renderer.getTextWidth(text: "\(floor(scaleY*(yM-Float(origin.y))))",
                                                                                         textSize: plotMarkers.markerTextSize)+5),
                                                                 yM - 4)
            plotMarkers.yMarkersTextLocation.append(text_p)
            plotMarkers.yMarkersText.append("\(floor(scaleY*(yM-Float(origin.y))))")
            yM = yM - inc1
        }



        // scale points to be plotted according to plot size
        let scaleXInv: Float = 1.0/scaleX;
        let scaleYInv: Float = 1.0/scaleY
        for i in 0..<series.count {
            let pairs = series[i].pairs
            series[i].scaledPairs.removeAll();
            for j in 0..<pairs.count {
                let scaledPair = Pair<FloatConvertible,FloatConvertible>(Float(pairs[j].x)*scaleXInv + Float(origin.x),
                                                                         Float(pairs[j].y)*scaleYInv + Float(origin.y))
                if (Float(scaledPair.x) >= 0.0 && Float(scaledPair.x) <= plotDimensions.graphWidth && Float(scaledPair.y) >= 0.0 && Float(scaledPair.y) <= plotDimensions.graphHeight) {
                    series[i].scaledPairs.append(scaledPair)
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

    func drawMarkers(renderer: Renderer) {
        for index in 0..<plotMarkers.xMarkers.count {
            let p1 = Pair<FloatConvertible,FloatConvertible>(Float(plotMarkers.xMarkers[index].x), -3)
            let p2 = Pair<FloatConvertible,FloatConvertible>(Float(plotMarkers.xMarkers[index].x), 0)
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
            let p1 = Pair<FloatConvertible,FloatConvertible>(-3, Float(plotMarkers.yMarkers[index].y))
            let p2 = Pair<FloatConvertible,FloatConvertible>(0, Float(plotMarkers.yMarkers[index].y))
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
            s.maxY = getMaxY(pairs: s.scaledPairs)
            s.minY = getMinY(pairs: s.scaledPairs)
            let seriesYRangeInverse: Float = 1.0/(s.maxY-s.minY)
            switch s.scatterPlotSeriesOptions.scatterPattern {
                case .circle:
                    for index in 0..<s.scaledPairs.count {
                        let p = s.scaledPairs[index]
                        if (s.startColor != nil && s.endColor != nil) {
                            s.color = lerp(startColor: s.startColor!,
                                           endColor: s.endColor!,
                                           (Float(s.scaledPairs[index].y)-s.minY)*seriesYRangeInverse)
                        }
                        renderer.drawSolidCircle(center: p,
                                                 radius: scatterPatternSize*Float(0.5),
                                                 fillColor: s.color,
                                                 isOriginShifted: true)
                    }
                case .square:
                  for index in 0..<s.scaledPairs.count {
                      let p = s.scaledPairs[index]
                      if (s.startColor != nil && s.endColor != nil) {
                          s.color = lerp(startColor: s.startColor!,
                                         endColor: s.endColor!,
                                         (Float(s.scaledPairs[index].y)-s.minY)*seriesYRangeInverse)
                      }
                      let tL = Pair<FloatConvertible,FloatConvertible>(Float(p.x)-scatterPatternSize*Float(0.5),
                                                                       Float(p.y)+scatterPatternSize*Float(0.5))
                      let tR = Pair<FloatConvertible,FloatConvertible>(Float(p.x)+scatterPatternSize*Float(0.5),
                                                                       Float(p.y)+scatterPatternSize*Float(0.5))
                      let bR = Pair<FloatConvertible,FloatConvertible>(Float(p.x)+scatterPatternSize*Float(0.5),
                                                                       Float(p.y)-scatterPatternSize*Float(0.5))
                      let bL = Pair<FloatConvertible,FloatConvertible>(Float(p.x)-scatterPatternSize*Float(0.5),
                                                                       Float(p.y)-scatterPatternSize*Float(0.5))
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
                    for index in 0..<s.scaledPairs.count {
                        let p = s.scaledPairs[index]
                        if (s.startColor != nil && s.endColor != nil) {
                            s.color = lerp(startColor: s.startColor!,
                                           endColor: s.endColor!,
                                           (Float(s.scaledPairs[index].y)-s.minY)*seriesYRangeInverse)
                        }
                        let p1 = Pair<FloatConvertible,FloatConvertible>(Float(p.x) + 0,
                                                                         Float(p.y) + r)
                        let p2 = Pair<FloatConvertible,FloatConvertible>(Float(p.x) + r*sqrt3/Float(2),
                                                                         Float(p.y) - r*Float(0.5))
                        let p3 = Pair<FloatConvertible,FloatConvertible>(Float(p.x) - r*sqrt3/Float(2),
                                                                         Float(p.y) - r*Float(0.5))
                        renderer.drawSolidTriangle(point1: p1,
                                                   point2: p2,
                                                   point3: p3,
                                                   fillColor: s.color,
                                                   isOriginShifted: true)
                    }
                case .diamond:
                    for index in 0..<s.scaledPairs.count {
                        let p = s.scaledPairs[index]
                        if (s.startColor != nil && s.endColor != nil) {
                            s.color = lerp(startColor: s.startColor!,
                                           endColor: s.endColor!,
                                           (Float(s.scaledPairs[index].y)-s.minY)*seriesYRangeInverse)
                        }
                        var tL = Pair<FloatConvertible,FloatConvertible>(Float(p.x)-scatterPatternSize*Float(0.5),
                                                                         Float(p.y)+scatterPatternSize*Float(0.5))
                        var tR = Pair<FloatConvertible,FloatConvertible>(Float(p.x)+scatterPatternSize*Float(0.5),
                                                                         Float(p.y)+scatterPatternSize*Float(0.5))
                        var bR = Pair<FloatConvertible,FloatConvertible>(Float(p.x)+scatterPatternSize*Float(0.5),
                                                                         Float(p.y)-scatterPatternSize*Float(0.5))
                        var bL = Pair<FloatConvertible,FloatConvertible>(Float(p.x)-scatterPatternSize*Float(0.5),
                                                                         Float(p.y)-scatterPatternSize*Float(0.5))
                        tL = rotatePoint(point: tL, center: p, angleDegrees: 45.0)
                        tR = rotatePoint(point: tR, center: p, angleDegrees: 45.0)
                        bL = rotatePoint(point: bL, center: p, angleDegrees: 45.0)
                        bR = rotatePoint(point: bR, center: p, angleDegrees: 45.0)
                        let diamondPoints: [Pair<FloatConvertible,FloatConvertible>] = [tL, tR, bR, bL]
                        renderer.drawSolidPolygon(points: diamondPoints,
                                                  fillColor: s.color,
                                                  isOriginShifted: true)
                    }
                  case .hexagon:
                      for index in 0..<s.scaledPairs.count {
                          let p = s.scaledPairs[index]
                          if (s.startColor != nil && s.endColor != nil) {
                              s.color = lerp(startColor: s.startColor!,
                                             endColor: s.endColor!,
                                             (Float(s.scaledPairs[index].y)-s.minY)*seriesYRangeInverse)
                          }
                          var hexagonPoint = Pair<FloatConvertible,FloatConvertible>(Float(p.x) + 0.0,
                                                                                     Float(p.y) + scatterPatternSize*Float(0.5))
                          var hexagonPoints: [Pair<FloatConvertible,FloatConvertible>] = [hexagonPoint]
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
                      for index in 0..<s.scaledPairs.count {
                          let p = s.scaledPairs[index]
                          if (s.startColor != nil && s.endColor != nil) {
                              s.color = lerp(startColor: s.startColor!,
                                             endColor: s.endColor!,
                                             (Float(s.scaledPairs[index].y)-s.minY)*seriesYRangeInverse)
                          }
                          var pentagonPoint = Pair<FloatConvertible,FloatConvertible>(Float(p.x) + 0.0,
                                                                                      Float(p.y) + scatterPatternSize*Float(0.5))
                          var pentagonPoints: [Pair<FloatConvertible,FloatConvertible>] = [pentagonPoint]
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
                      for index in 0..<s.scaledPairs.count {
                          let p = s.scaledPairs[index]
                          if (s.startColor != nil && s.endColor != nil) {
                              s.color = lerp(startColor: s.startColor!,
                                             endColor: s.endColor!,
                                             (Float(s.scaledPairs[index].y)-s.minY)*seriesYRangeInverse)
                          }
                          var starOuterPoint = Pair<FloatConvertible,FloatConvertible>(Float(p.x) + 0.0,
                                                                                       Float(p.y) + scatterPatternSize*Float(0.5))
                          var starInnerPoint = rotatePoint(point: Pair<FloatConvertible,FloatConvertible>(Float(p.x) + 0.0,
                                                                                                          Float(p.y) + scatterPatternSize*Float(0.25)),
                                                           center: p,
                                                           angleDegrees: 36.0)
                          var starPoints: [Pair<FloatConvertible,FloatConvertible>] = [starOuterPoint, starInnerPoint]
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

        let p1 = Pair<FloatConvertible,FloatConvertible>(Float(plotLegend.legendTopLeft.x),
                                                         Float(plotLegend.legendTopLeft.y))
        let p2 = Pair<FloatConvertible,FloatConvertible>(Float(plotLegend.legendTopLeft.x) + plotLegend.legendWidth,
                                                         Float(plotLegend.legendTopLeft.y))
        let p3 = Pair<FloatConvertible,FloatConvertible>(Float(plotLegend.legendTopLeft.x) + plotLegend.legendWidth,
                                                         Float(plotLegend.legendTopLeft.y) - plotLegend.legendHeight)
        let p4 = Pair<FloatConvertible,FloatConvertible>(Float(plotLegend.legendTopLeft.x),
                                                         Float(plotLegend.legendTopLeft.y) - plotLegend.legendHeight)

        renderer.drawSolidRectWithBorder(topLeftPoint: p1,
                                         topRightPoint: p2,
                                         bottomRightPoint: p3,
                                         bottomLeftPoint: p4,
                                         strokeWidth: plotBorder.borderThickness,
                                         fillColor: Color.transluscentWhite,
                                         borderColor: Color.black,
                                         isOriginShifted: false)

        for i in 0..<series.count {
            let tL = Pair<FloatConvertible,FloatConvertible>(Float(plotLegend.legendTopLeft.x) + plotLegend.legendTextSize,
                                                             Float(plotLegend.legendTopLeft.y) - (2.0*Float(i) + 1.0)*plotLegend.legendTextSize)
            let bR = Pair<FloatConvertible,FloatConvertible>(Float(tL.x) + plotLegend.legendTextSize,
                                                             Float(tL.y) - plotLegend.legendTextSize)
            let tR = Pair<FloatConvertible,FloatConvertible>(Float(bR.x), Float(tL.y))
            let bL = Pair<FloatConvertible,FloatConvertible>(Float(tL.x), Float(bR.y))
            if (series[i].startColor != nil && series[i].endColor != nil) {
                series[i].color = series[i].startColor!
            }
            switch series[i].scatterPlotSeriesOptions.scatterPattern {
                case .circle:
                    let c = Pair<FloatConvertible,FloatConvertible>((Float(tL.x)+Float(bR.x))*Float(0.5),
                                                                    (Float(tL.y)+Float(bR.y))*Float(0.5))
                    renderer.drawSolidCircle(center: c,
                                             radius: (Float(tR.x)-Float(tL.x))*Float(0.5),
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
                    let c = Pair<FloatConvertible,FloatConvertible>((Float(tL.x)+Float(bR.x))*Float(0.5),
                                                                    (Float(tL.y)+Float(bR.y))*Float(0.5))
                    let r: Float = (Float(tR.x)-Float(tL.x))*Float(0.5)
                    let p1 = Pair<FloatConvertible,FloatConvertible>(Float(c.x) + 0,
                                                                     Float(c.y) + r)
                    let p2 = Pair<FloatConvertible,FloatConvertible>(Float(c.x) + r*sqrt3*Float(0.5),
                                                                     Float(c.y) - r*Float(0.5))
                    let p3 = Pair<FloatConvertible,FloatConvertible>(Float(c.x) - r*sqrt3*Float(0.5),
                                                                     Float(c.y) - r*Float(0.5))
                    renderer.drawSolidTriangle(point1: p1,
                                               point2: p2,
                                               point3: p3,
                                               fillColor: series[i].color,
                                               isOriginShifted: false)
                case .diamond:
                    let c = Pair<FloatConvertible,FloatConvertible>((Float(tL.x)+Float(bR.x))*Float(0.5),
                                                                    (Float(tL.y)+Float(bR.y))*Float(0.5))
                    let p1 = rotatePoint(point: tL, center: c, angleDegrees: 45.0)
                    let p2 = rotatePoint(point: tR, center: c, angleDegrees: 45.0)
                    let p3 = rotatePoint(point: bR, center: c, angleDegrees: 45.0)
                    let p4 = rotatePoint(point: bL, center: c, angleDegrees: 45.0)
                    let diamondPoints: [Pair<FloatConvertible,FloatConvertible>] = [p1, p2, p3, p4]
                    renderer.drawSolidPolygon(points: diamondPoints,
                                              fillColor: series[i].color,
                                              isOriginShifted: false)
                case .hexagon:
                  let c = Pair<FloatConvertible,FloatConvertible>((Float(tL.x)+Float(bR.x))*Float(0.5),
                                                                  (Float(tL.y)+Float(bR.y))*Float(0.5))
                  var hexagonPoint = Pair<FloatConvertible,FloatConvertible>(Float(c.x) + 0.0,
                                                                             Float(c.y) + (Float(tL.y)-Float(bL.y))*Float(0.5))
                  var hexagonPoints: [Pair<FloatConvertible,FloatConvertible>] = [hexagonPoint]
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
                  let c = Pair<FloatConvertible,FloatConvertible>((Float(tL.x)+Float(bR.x))*Float(0.5),
                                                                  (Float(tL.y)+Float(bR.y))*Float(0.5))
                  var pentagonPoint = Pair<FloatConvertible,FloatConvertible>(Float(c.x) + 0.0,
                                                                              Float(c.y) + (Float(tL.y)-Float(bL.y))*Float(0.5))
                  var pentagonPoints: [Pair<FloatConvertible,FloatConvertible>] = [pentagonPoint]
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
                  let c = Pair<FloatConvertible,FloatConvertible>((Float(tL.x)+Float(bR.x))*Float(0.5),
                                                                  (Float(tL.y)+Float(bR.y))*Float(0.5))
                  var starOuterPoint = Pair<FloatConvertible,FloatConvertible>(Float(c.x) + 0.0,
                                                                               Float(c.y) + (Float(tL.y)-Float(bL.y))*Float(0.5))
                  var starInnerPoint = rotatePoint(point: Pair<FloatConvertible,FloatConvertible>(Float(c.x) + 0.0,
                                                                                                  Float(c.y) + (Float(tL.y)-Float(bL.y))*Float(0.25)),
                                                   center: c,
                                                   angleDegrees: 36.0)
                  var starPoints: [Pair<FloatConvertible,FloatConvertible>] = [starOuterPoint, starInnerPoint]
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
            let p = Pair<FloatConvertible,FloatConvertible>(Float(bR.x) + plotLegend.legendTextSize,
                                                            Float(bR.y))
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
