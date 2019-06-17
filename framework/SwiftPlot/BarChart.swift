import Foundation

// class defining a barGraph and all it's logic
public class BarGraph: Plot {

    let MAX_DIV: Float = 50

    public var xOffset: Float = 0
    public var yOffset: Float = 0

    public var plotTitle: PlotTitle? = nil
    public var plotLabel: PlotLabel? = nil
    public var plotLegend: PlotLegend = PlotLegend()
    public var plotBorder: PlotBorder = PlotBorder()
    public var plotDimensions: PlotDimensions {
        willSet{
            plotBorder.topLeft       = Point(newValue.subWidth*0.1, newValue.subHeight*0.9)
            plotBorder.topRight      = Point(newValue.subWidth*0.9, newValue.subHeight*0.9)
            plotBorder.bottomLeft    = Point(newValue.subWidth*0.1, newValue.subHeight*0.1)
            plotBorder.bottomRight   = Point(newValue.subWidth*0.9, newValue.subHeight*0.1)
            plotLegend.legendTopLeft = Point(plotBorder.topLeft.x + 20, plotBorder.topLeft.y - 20)
        }
    }
    public enum GraphOrientation {
        case vertical
        case horizontal
    }
    public var graphOrientation: GraphOrientation = .vertical
    public var scaleY: Float = 1
    public var scaleX: Float = 1
    public var plotMarkers: PlotMarkers = PlotMarkers()
    public var series: Series = Series()
    public var stackSeries = [Series]()

    var barWidth : Int = 0
    public var space: Int = 20

    var origin: Point = Point.zero

    public init(width: Float = 1000, height: Float = 660){
        plotDimensions = PlotDimensions(frameWidth: width, frameHeight: height)
    }
    public func addSeries(_ s: Series){
        series = s
    }
    public func addStackSeries(_ s: Series) {
        if (series.points.count != 0 && series.points.count == s.points.count) {
            stackSeries.append(s)
        }
        else {
            print("Stack point count does not match the Series point count.")
        }
    }
    public func addStackSeries(_ x: [Float], label: String, color: Color = .lightBlue, hatchPattern: BarGraphSeriesOptions.Hatching = .none) {
        var pts = [Point]()
        if (graphOrientation == .vertical) {
            for i in 0..<x.count {
                pts.append(Point(series.points[i].x, x[i]))
            }
        }
        else {
            for i in 0..<x.count {
                pts.append(Point(x[i], series.points[i].x))
            }
        }
        let s = Series(points: pts,label: label, color: color, hatchPattern: hatchPattern)
        addStackSeries(s)
    }
    public func addSeries(points p: [Point], label: String, color: Color = Color.lightBlue, hatchPattern: BarGraphSeriesOptions.Hatching = .none){
        let s = Series(points: p,label: label, color: color, hatchPattern: hatchPattern)
        addSeries(s)
    }
    public func addSeries(_ x: [Float], _ y: [Float], label: String, color: Color = Color.lightBlue, hatchPattern: BarGraphSeriesOptions.Hatching = .none, graphOrientation: BarGraph.GraphOrientation = .vertical){
        var pts = [Point]()
        for i in 0..<x.count {
            pts.append(Point(x[i], y[i]))
        }
        let s = Series(points: pts, label: label, color: color, hatchPattern: hatchPattern)
        addSeries(s)
        self.graphOrientation = graphOrientation
    }
    public func addSeries(_ x: [String], _ y: [Float], label: String, color: Color = Color.lightBlue, hatchPattern: BarGraphSeriesOptions.Hatching = .none, graphOrientation: BarGraph.GraphOrientation = .vertical){
        var pts = [Point]()
        if (graphOrientation == .vertical) {
            for i in 0..<x.count {
                pts.append(Point(x[i], y[i]))
            }
        }
        else {
            for i in 0..<x.count {
                pts.append(Point(y[i], x[i]))
            }
        }
        let s = Series(points: pts, label: label, color: color, hatchPattern: hatchPattern)
        addSeries(s)
        self.graphOrientation = graphOrientation
    }

    public func addSeries(_ x: [Float], _ y: [String], label: String, color: Color = Color.lightBlue, hatchPattern: BarGraphSeriesOptions.Hatching = .none, graphOrientation: BarGraph.GraphOrientation = .horizontal){
        var pts = [Point]()
        if (graphOrientation == .horizontal) {
            for i in 0..<x.count {
                pts.append(Point(x[i], y[i]))
            }
        }
        else {
            for i in 0..<x.count {
                pts.append(Point(y[i], x[i]))
            }
        }
        let s = Series(points: pts, label: label, color: color, hatchPattern: hatchPattern)
        addSeries(s)
        self.graphOrientation = graphOrientation
    }

}

// extension containing drawing logic
extension BarGraph {

    // call functions to draw the graph
    public func drawGraphAndOutput(fileName name: String = "swift_plot_line_graph", renderer: Renderer){
        renderer.xOffset = xOffset
        renderer.yOffset = yOffset
        renderer.plotDimensions = plotDimensions
        plotBorder.topLeft       = Point(plotDimensions.subWidth*0.1, plotDimensions.subHeight*0.9)
        plotBorder.topRight      = Point(plotDimensions.subWidth*0.9, plotDimensions.subHeight*0.9)
        plotBorder.bottomLeft    = Point(plotDimensions.subWidth*0.1, plotDimensions.subHeight*0.1)
        plotBorder.bottomRight   = Point(plotDimensions.subWidth*0.9, plotDimensions.subHeight*0.1)
        plotLegend.legendTopLeft = Point(plotBorder.topLeft.x + 20, plotBorder.topLeft.y - 20)
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
        plotBorder.topLeft       = Point(plotDimensions.subWidth*0.1, plotDimensions.subHeight*0.9)
        plotBorder.topRight      = Point(plotDimensions.subWidth*0.9, plotDimensions.subHeight*0.9)
        plotBorder.bottomLeft    = Point(plotDimensions.subWidth*0.1, plotDimensions.subHeight*0.1)
        plotBorder.bottomRight   = Point(plotDimensions.subWidth*0.9, plotDimensions.subHeight*0.1)
        plotLegend.legendTopLeft = Point(plotBorder.topLeft.x + 20, plotBorder.topLeft.y - 20)
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
            let xWidth   : Float = renderer.getTextWidth(text: plotLabel!.xLabel, textSize: plotLabel!.labelSize)
            let yWidth    : Float = renderer.getTextWidth(text: plotLabel!.yLabel, textSize: plotLabel!.labelSize)
            plotLabel!.xLabelLocation = Point(((plotBorder.bottomRight.x + plotBorder.bottomLeft.x)*Float(0.5)) - xWidth*Float(0.5), plotBorder.bottomLeft.y - plotLabel!.labelSize - 0.05*plotDimensions.graphHeight)
            plotLabel!.yLabelLocation = Point((plotBorder.bottomLeft.x - plotLabel!.labelSize - 0.05*plotDimensions.graphWidth), ((plotBorder.bottomLeft.y + plotBorder.topLeft.y)*Float(0.5) - yWidth))
        }
        if (plotTitle != nil) {
          let titleWidth: Float = renderer.getTextWidth(text: plotTitle!.title, textSize: plotTitle!.titleSize)
          plotTitle!.titleLocation = Point(((plotBorder.topRight.x + plotBorder.topLeft.x)*Float(0.5)) - titleWidth*Float(0.5), plotBorder.topLeft.y + plotTitle!.titleSize*Float(0.5))
        }
    }

    func calcMarkerLocAndScalePts(renderer: Renderer){

        var maximumY: Float = 0
        var minimumY: Float = 0
        var maximumX: Float = 0
        var minimumX: Float = 0

        if (graphOrientation == .vertical) {
            barWidth = Int(round(plotDimensions.graphWidth/Float(series.points.count)))
            maximumY = getMaxY(points: series.points)
            minimumY = getMinY(points: series.points)
        }
        else{
            barWidth = Int(round(plotDimensions.graphHeight/Float(series.points.count)))
            maximumX = getMaxX(points: series.points)
            minimumX = getMinX(points: series.points)
        }

        plotMarkers.xMarkers = [Point]()
        plotMarkers.yMarkers = [Point]()
        plotMarkers.xMarkersTextLocation = [Point]()
        plotMarkers.yMarkersTextLocation = [Point]()
        plotMarkers.xMarkersText = [String]()
        plotMarkers.xMarkersText = [String]()


        let pts = series.points
        if (graphOrientation == .vertical) {
            for s in stackSeries {
                let minStackY = getMinY(points: s.points)
                let maxStackY = getMaxY(points: s.points)

                if (maxStackY>0) {
                    maximumY = maximumY + maxStackY
                }
                if (minStackY<0) {
                    minimumY = minimumY + minStackY
                }

            }

            if minimumY>=0.0 {
                origin = Point.zero
                minimumY = 0.0
            }
            else{
                origin = Point(0.0, (plotDimensions.graphHeight/(maximumY-minimumY))*(-minimumY))
            }

            let topScaleMargin: Float = (plotDimensions.subHeight - plotDimensions.graphHeight)*Float(0.5) - 10.0;
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

            var yM: Float = origin.y
            while yM<=plotDimensions.graphHeight {
                if(yM+inc1<0.0 || yM<0.0){
                    yM = yM + inc1
                    continue
                }
                let p: Point = Point(0, yM)
                plotMarkers.yMarkers.append(p)
                let text_p: Point = Point(-(renderer.getTextWidth(text: "\(ceil(scaleY*(yM-origin.y)))", textSize: plotMarkers.markerTextSize)+5), yM - 4)
                plotMarkers.yMarkersTextLocation.append(text_p)
                plotMarkers.yMarkersText.append("\(ceil(scaleY*(yM-origin.y)))")
                yM = yM + inc1
            }
            yM = origin.y - inc1
            while yM>0.0 {
                let p: Point = Point(0, yM)
                plotMarkers.yMarkers.append(p)
                let text_p: Point = Point(-(renderer.getTextWidth(text: "\(floor(scaleY*(yM-origin.y)))", textSize: plotMarkers.markerTextSize)+5), yM - 4)
                plotMarkers.yMarkersTextLocation.append(text_p)
                plotMarkers.yMarkersText.append("\(floor(scaleY*(yM-origin.y)))")
                yM = yM - inc1
            }

            for i in 0..<series.points.count {
                let p: Point = Point(Float(i*barWidth) + Float(barWidth)*Float(0.5), 0)
                plotMarkers.xMarkers.append(p)
                let bW: Int = barWidth*(i+1)
                let textWidth: Float = renderer.getTextWidth(text: "\(series.points[i].xString)", textSize: plotMarkers.markerTextSize)
                let text_p: Point = Point(Float(bW) - textWidth*Float(0.5) - Float(barWidth)*Float(0.5), -2.0*plotMarkers.markerTextSize)
                plotMarkers.xMarkersTextLocation.append(text_p)
                plotMarkers.xMarkersText.append("\(series.points[i].xString)")
            }

            // scale points to be plotted according to plot size
            let scaleYInv: Float = 1.0/scaleY
            series.scaledPoints.removeAll();
            for j in 0..<pts.count {
                let pt: Point = Point(pts[j].x, (pts[j].y)*scaleYInv + origin.y)
                // if (pt.y >= 0.0 && pt.y <= plotDimensions.graphHeight) {
                series.scaledPoints.append(pt)
                // }
            }
            for index in 0..<stackSeries.count {
                stackSeries[index].scaledPoints.removeAll()
                for j in 0..<stackSeries[index].points.count {
                    let pt: Point = Point(stackSeries[index].points[j].x, (stackSeries[index].points[j].y)*scaleYInv + origin.y)
                    // if (pt.y >= 0.0 && pt.y <= plotDimensions.graphHeight) {
                    stackSeries[index].scaledPoints.append(pt)
                    // }
                }
            }
        }

        else{
            var x: Float = getMaxX(points: pts)
            if (x > maximumX) {
                maximumX = x
            }
            x = getMinX(points: pts)
            if (x < minimumX) {
                minimumX = x
            }

            for s in stackSeries {
                let minStackX = getMinX(points: s.points)
                let maxStackX = getMaxX(points: s.points)
                maximumX = maximumX + maxStackX
                minimumX = minimumX - minStackX
            }

            if minimumX>=0.0 {
                origin = Point.zero
                minimumX = 0.0
            }
            else{
                origin = Point((plotDimensions.graphWidth/(maximumX-minimumX))*(-minimumX), 0.0)
            }

            let rightScaleMargin: Float = (plotDimensions.subWidth - plotDimensions.graphWidth)*Float(0.5) - 10.0
            scaleX = (maximumX - minimumX) / (plotDimensions.graphWidth - rightScaleMargin)

            let nD1: Int = max(getNumberOfDigits(maximumX), getNumberOfDigits(minimumX))
            var v1: Float
            if (nD1 > 1 && maximumX <= pow(Float(10), Float(nD1 - 1))) {
                v1 = Float(pow(Float(10), Float(nD1 - 2)))
            } else if (nD1 > 1) {
                v1 = Float(pow(Float(10), Float(nD1 - 1)))
            } else {
                v1 = Float(pow(Float(10), Float(0)))
            }

            let nX: Float = v1/scaleX
            var inc1: Float = nX
            if(plotDimensions.graphWidth/nX > MAX_DIV){
                inc1 = (plotDimensions.graphWidth/nX)*inc1/MAX_DIV
            }

            var xM: Float = origin.x
            while xM<=plotDimensions.graphWidth {
                if(xM+inc1<0.0 || xM<0.0){
                    xM = xM + inc1
                    continue
                }
                let p: Point = Point(xM, 0)
                plotMarkers.xMarkers.append(p)
                let text_p: Point = Point(xM - (renderer.getTextWidth(text: "\(floor(scaleX*(xM-origin.x)))", textSize: plotMarkers.markerTextSize)*Float(0.5)) + 8, -15)
                plotMarkers.xMarkersTextLocation.append(text_p)
                plotMarkers.xMarkersText.append("\(ceil(scaleX*(xM-origin.x)))")
                xM = xM + inc1
            }
            xM = origin.x - inc1
            while xM>0.0 {
                let p: Point = Point(xM, 0)
                plotMarkers.xMarkers.append(p)
                let text_p: Point = Point(xM - (renderer.getTextWidth(text: "\(floor(scaleX*(xM-origin.x)))", textSize: plotMarkers.markerTextSize)*Float(0.5)) + 8, -15)
                plotMarkers.xMarkersTextLocation.append(text_p)
                plotMarkers.xMarkersText.append("\(floor(scaleX*(xM-origin.x)))")
                xM = xM - inc1
            }

            for i in 0..<series.points.count {
                let p: Point = Point(0, Float(i*barWidth) + Float(barWidth)*Float(0.5))
                plotMarkers.yMarkers.append(p)
                let bW: Int = barWidth*(i+1)
                let textWidth: Float = renderer.getTextWidth(text: "\(series.points[i].yString)", textSize: plotMarkers.markerTextSize)
                let text_p: Point = Point(-1.2*textWidth, Float(bW) - plotMarkers.markerTextSize/2 - Float(barWidth)*Float(0.5))
                plotMarkers.yMarkersTextLocation.append(text_p)
                plotMarkers.yMarkersText.append("\(series.points[i].yString)")
            }

            // scale points to be plotted according to plot size
            let scaleXInv: Float = 1.0/scaleX
            series.scaledPoints.removeAll();
            for j in 0..<pts.count {
                let pt: Point = Point(pts[j].x*scaleXInv + origin.x, pts[j].y)
                // if (pt.y >= 0.0 && pt.y <= plotDimensions.graphHeight) {
                series.scaledPoints.append(pt)
                // }
            }
            for index in 0..<stackSeries.count {
                stackSeries[index].scaledPoints.removeAll()
                for j in 0..<stackSeries[index].points.count {
                    let pt: Point = Point(stackSeries[index].points[j].x*scaleXInv + origin.x, stackSeries[index].points[j].y)
                    // if (pt.y >= 0.0 && pt.y <= plotDimensions.graphHeight) {
                    stackSeries[index].scaledPoints.append(pt)
                    // }
                }
            }
        }

    }

    //functions to draw the plot
    func drawBorder(renderer: Renderer){
        renderer.drawRect(topLeftPoint: plotBorder.topLeft, topRightPoint: plotBorder.topRight, bottomRightPoint: plotBorder.bottomRight, bottomLeftPoint: plotBorder.bottomLeft, strokeWidth: plotBorder.borderThickness, strokeColor: Color.black, isOriginShifted: false)
    }

    func drawMarkers(renderer: Renderer) {
        for index in 0..<plotMarkers.xMarkers.count {
            let p1: Point = Point(plotMarkers.xMarkers[index].x, -3)
            let p2: Point = Point(plotMarkers.xMarkers[index].x, 0)
            renderer.drawLine(startPoint: p1, endPoint: p2, strokeWidth: plotBorder.borderThickness, strokeColor: Color.black, isDashed: false, isOriginShifted: true)
            renderer.drawText(text: plotMarkers.xMarkersText[index], location: plotMarkers.xMarkersTextLocation[index], textSize: plotMarkers.markerTextSize, strokeWidth: 0.7, angle: 0, isOriginShifted: true)
        }

        for index in 0..<plotMarkers.yMarkers.count {
            let p1: Point = Point(-3, plotMarkers.yMarkers[index].y)
            let p2: Point = Point(0, plotMarkers.yMarkers[index].y)
            renderer.drawLine(startPoint: p1, endPoint: p2, strokeWidth: plotBorder.borderThickness, strokeColor: Color.black, isDashed: false, isOriginShifted: true)
            renderer.drawText(text: plotMarkers.yMarkersText[index], location: plotMarkers.yMarkersTextLocation[index], textSize: plotMarkers.markerTextSize, strokeWidth: 0.7, angle: 0, isOriginShifted: true)
        }

    }

    func drawPlots(renderer: Renderer) {
        if (graphOrientation == .vertical) {
            for index in 0..<series.points.count {
                var currentHeightPositive: Float = 0
                var currentHeightNegative: Float = 0
                var tL: Point = Point(plotMarkers.xMarkers[index].x - Float(barWidth)*Float(0.5) + Float(space)*Float(0.5), series.scaledPoints[index].y)
                var tR: Point = Point(plotMarkers.xMarkers[index].x + Float(barWidth)*Float(0.5) - Float(space)*Float(0.5), series.scaledPoints[index].y)
                var bL: Point = Point(plotMarkers.xMarkers[index].x - Float(barWidth)*Float(0.5) + Float(space)*Float(0.5), origin.y)
                var bR: Point = Point(plotMarkers.xMarkers[index].x + Float(barWidth)*Float(0.5) - Float(space)*Float(0.5), origin.y)
                if (tL.y - bL.y >= 0) {
                    currentHeightPositive = tL.y - bL.y
                }
                else {
                    currentHeightNegative = tL.y - bL.y
                }
                renderer.drawSolidRect(topLeftPoint: tL, topRightPoint: tR, bottomRightPoint: bR, bottomLeftPoint: bL, fillColor: series.color, hatchPattern: series.barGraphSeriesOptions.hatchPattern, isOriginShifted: true)
                for s in stackSeries {
                    tL = Point(plotMarkers.xMarkers[index].x - Float(barWidth)*Float(0.5) + Float(space)*Float(0.5), s.scaledPoints[index].y)
                    bL = Point(plotMarkers.xMarkers[index].x - Float(barWidth)*Float(0.5) + Float(space)*Float(0.5), origin.y)
                    if (tL.y - bL.y >= 0) {
                        tL = Point(plotMarkers.xMarkers[index].x - Float(barWidth)*Float(0.5) + Float(space)*Float(0.5), s.scaledPoints[index].y + currentHeightPositive)
                        tR = Point(plotMarkers.xMarkers[index].x + Float(barWidth)*Float(0.5) - Float(space)*Float(0.5), s.scaledPoints[index].y + currentHeightPositive)
                        bL = Point(plotMarkers.xMarkers[index].x - Float(barWidth)*Float(0.5) + Float(space)*Float(0.5), origin.y + currentHeightPositive)
                        bR = Point(plotMarkers.xMarkers[index].x + Float(barWidth)*Float(0.5) - Float(space)*Float(0.5), origin.y + currentHeightPositive)
                    }
                    else {
                        tL = Point(plotMarkers.xMarkers[index].x - Float(barWidth)*Float(0.5) + Float(space)*Float(0.5), s.scaledPoints[index].y + currentHeightNegative)
                        tR = Point(plotMarkers.xMarkers[index].x + Float(barWidth)*Float(0.5) - Float(space)*Float(0.5), s.scaledPoints[index].y + currentHeightNegative)
                        bL = Point(plotMarkers.xMarkers[index].x - Float(barWidth)*Float(0.5) + Float(space)*Float(0.5), origin.y + currentHeightNegative)
                        bR = Point(plotMarkers.xMarkers[index].x + Float(barWidth)*Float(0.5) - Float(space)*Float(0.5), origin.y + currentHeightNegative)
                    }
                    let heightIncrement = tL.y - bL.y
                    if (heightIncrement >= 0) {
                        currentHeightPositive = currentHeightPositive + heightIncrement
                    }
                    else {
                        currentHeightNegative = currentHeightNegative + heightIncrement
                    }
                    renderer.drawSolidRect(topLeftPoint: tL, topRightPoint: tR, bottomRightPoint: bR, bottomLeftPoint: bL, fillColor: s.color, hatchPattern: s.barGraphSeriesOptions.hatchPattern, isOriginShifted: true)
                }
            }
        }
        else {
            for index in 0..<series.points.count {
                var currentWidthPositive: Float = 0
                var currentWidthNegative: Float = 0
                var tL: Point = Point(origin.x, plotMarkers.yMarkers[index].y + Float(barWidth)*Float(0.5) - Float(space)*Float(0.5))
                var tR: Point = Point(series.scaledPoints[index].x, plotMarkers.yMarkers[index].y + Float(barWidth)*Float(0.5) - Float(space)*Float(0.5))
                var bL: Point = Point(origin.x, plotMarkers.yMarkers[index].y - Float(barWidth)*Float(0.5) + Float(space)*Float(0.5))
                var bR: Point = Point(series.scaledPoints[index].x, plotMarkers.yMarkers[index].y - Float(barWidth)*Float(0.5) + Float(space)*Float(0.5))
                if (tR.x - tL.x >= 0) {
                    currentWidthPositive = tR.x - tL.x
                }
                else {
                    currentWidthNegative = tR.x - tL.x
                }
                renderer.drawSolidRect(topLeftPoint: tL, topRightPoint: tR, bottomRightPoint: bR, bottomLeftPoint: bL, fillColor: series.color, hatchPattern: series.barGraphSeriesOptions.hatchPattern, isOriginShifted: true)
                for s in stackSeries {

                    tL = Point(origin.x, plotMarkers.yMarkers[index].y + Float(barWidth)*Float(0.5) - Float(space)*Float(0.5))
                    tR = Point(s.scaledPoints[index].x, plotMarkers.yMarkers[index].y + Float(barWidth)*Float(0.5) - Float(space)*Float(0.5))
                    if (tR.x - tL.x >= 0) {
                        tL = Point(origin.x + currentWidthPositive, plotMarkers.yMarkers[index].y + Float(barWidth)*Float(0.5) - Float(space)*Float(0.5))
                        tR = Point(s.scaledPoints[index].x + currentWidthPositive, plotMarkers.yMarkers[index].y + Float(barWidth)/2.0 - Float(space)*Float(0.5))
                        bL = Point(origin.x + currentWidthPositive, plotMarkers.yMarkers[index].y - Float(barWidth)*Float(0.5) + Float(space)*Float(0.5))
                        bR = Point(s.scaledPoints[index].x + currentWidthPositive, plotMarkers.yMarkers[index].y - Float(barWidth)/2.0 + Float(space)*Float(0.5))
                    }
                    else {
                        tL = Point(origin.x + currentWidthNegative, plotMarkers.yMarkers[index].y + Float(barWidth)*Float(0.5) - Float(space)*Float(0.5))
                        tR = Point(s.scaledPoints[index].x + currentWidthNegative, plotMarkers.yMarkers[index].y + Float(barWidth)/2.0 - Float(space)*Float(0.5))
                        bL = Point(origin.x + currentWidthNegative, plotMarkers.yMarkers[index].y - Float(barWidth)*Float(0.5) + Float(space)*Float(0.5))
                        bR = Point(s.scaledPoints[index].x + currentWidthNegative, plotMarkers.yMarkers[index].y - Float(barWidth)*Float(0.5) + Float(space)*Float(0.5))
                    }
                    let widthIncrement = tR.x - tL.x
                    if (widthIncrement >= 0) {
                        currentWidthPositive = currentWidthPositive + widthIncrement
                    }
                    else {
                        currentWidthNegative = currentWidthNegative + widthIncrement
                    }
                    renderer.drawSolidRect(topLeftPoint: tL, topRightPoint: tR, bottomRightPoint: bR, bottomLeftPoint: bL, fillColor: s.color, hatchPattern: s.barGraphSeriesOptions.hatchPattern, isOriginShifted: true)
                }
            }
        }

    }

    func drawTitle(renderer: Renderer) {
        guard let plotTitle = self.plotTitle else { return }
        renderer.drawText(text: plotTitle.title, location: plotTitle.titleLocation, textSize: plotTitle.titleSize, strokeWidth: 1.2, angle: 0, isOriginShifted: false)
    }

    func drawLabels(renderer: Renderer) {
        guard let plotLabel = self.plotLabel else { return }
        renderer.drawText(text: plotLabel.xLabel, location: plotLabel.xLabelLocation, textSize: plotLabel.labelSize, strokeWidth: 1.2, angle: 0, isOriginShifted: false)
        renderer.drawText(text: plotLabel.yLabel, location: plotLabel.yLabelLocation, textSize: plotLabel.labelSize, strokeWidth: 1.2, angle: 90, isOriginShifted: false)
    }

    func drawLegends(renderer: Renderer) {
        var maxWidth: Float = 0
        var legendSeries = stackSeries
        legendSeries.insert(series, at: 0)
        for s in legendSeries {
        	let w = renderer.getTextWidth(text: s.label, textSize: plotLegend.legendTextSize)
        	if (w > maxWidth) {
        		maxWidth = w
        	}
        }
        plotLegend.legendWidth  = maxWidth + 3.5*plotLegend.legendTextSize
        plotLegend.legendHeight = (Float(stackSeries.count + 1)*2.0 + 1.0)*plotLegend.legendTextSize

        let p1: Point = Point(plotLegend.legendTopLeft.x, plotLegend.legendTopLeft.y)
        let p2: Point = Point(plotLegend.legendTopLeft.x + plotLegend.legendWidth, plotLegend.legendTopLeft.y)
        let p3: Point = Point(plotLegend.legendTopLeft.x + plotLegend.legendWidth, plotLegend.legendTopLeft.y - plotLegend.legendHeight)
        let p4: Point = Point(plotLegend.legendTopLeft.x, plotLegend.legendTopLeft.y - plotLegend.legendHeight)

        renderer.drawSolidRectWithBorder(topLeftPoint: p1, topRightPoint: p2, bottomRightPoint: p3, bottomLeftPoint: p4, strokeWidth: plotBorder.borderThickness, fillColor: Color.transluscentWhite, borderColor: Color.black, isOriginShifted: false)

        for i in 0..<legendSeries.count {
        	let tL: Point = Point(plotLegend.legendTopLeft.x + plotLegend.legendTextSize, plotLegend.legendTopLeft.y - (2.0*Float(i) + 1.0)*plotLegend.legendTextSize)
        	let bR: Point = Point(tL.x + plotLegend.legendTextSize, tL.y - plotLegend.legendTextSize)
        	let tR: Point = Point(bR.x, tL.y)
        	let bL: Point = Point(tL.x, bR.y)
        	renderer.drawSolidRect(topLeftPoint: tL, topRightPoint: tR, bottomRightPoint: bR, bottomLeftPoint: bL, fillColor: legendSeries[i].color, hatchPattern: .none, isOriginShifted: false)
        	let p: Point = Point(bR.x + plotLegend.legendTextSize, bR.y)
        	renderer.drawText(text: legendSeries[i].label, location: p, textSize: plotLegend.legendTextSize, strokeWidth: 1.2, angle: 0, isOriginShifted: false)
        }

    }

    func saveImage(fileName name: String, renderer: Renderer) {
        renderer.drawOutput(fileName: name)
    }

}
