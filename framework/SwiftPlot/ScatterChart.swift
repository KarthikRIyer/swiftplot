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
            plotBorder.topLeft       = Point(newValue.subWidth*0.1, newValue.subHeight*0.9)
            plotBorder.topRight      = Point(newValue.subWidth*0.9, newValue.subHeight*0.9)
            plotBorder.bottomLeft    = Point(newValue.subWidth*0.1, newValue.subHeight*0.1)
            plotBorder.bottomRight   = Point(newValue.subWidth*0.9, newValue.subHeight*0.1)
            plotLegend.legendTopLeft = Point(plotBorder.topLeft.x + 20, plotBorder.topLeft.y - 20)
        }
    }

    var scaleX: Float = 1
    var scaleY: Float = 1
    var plotMarkers: PlotMarkers = PlotMarkers()
    var series = [Series]()

    public var plotLineThickness: Float = 3
    public var scatterPatternSize: Float = 10

    public init(points p: [Point], width: Float = 1000, height: Float = 660){
        plotDimensions = PlotDimensions(frameWidth: width, frameHeight: height)
        plotDimensions.calculateGraphDimensions()

        let s = Series(points: p,label: "Plot")
        series.append(s)
    }

    public init(width: Float = 1000, height: Float = 660){
        plotDimensions = PlotDimensions(frameWidth: width, frameHeight: height)
    }

    // functions to add series
    public func addSeries(_ s: Series){
        series.append(s)
    }
    public func addSeries(points p: [Point], label: String, color: Color = .lightBlue, scatterPattern: ScatterPlotSeriesOptions.ScatterPattern = .circle){
        let s = Series(points: p,label: label, color: color, scatterPattern: scatterPattern)
        addSeries(s)
    }
    public func addSeries(_ x: [Float], _ y: [Float], label: String, color: Color = .lightBlue, scatterPattern: ScatterPlotSeriesOptions.ScatterPattern = .circle){
        var pts = [Point]()
        for i in 0..<x.count {
            pts.append(Point(x[i], y[i]))
        }
        let s = Series(points: pts, label: label, color: color, scatterPattern: scatterPattern)
        addSeries(s)
    }
    public func addSeries(_ x: [Float], _ y: [Float], label: String, startColor: Color = .lightBlue, endColor: Color = .lightBlue, scatterPattern: ScatterPlotSeriesOptions.ScatterPattern = .circle){
        var pts = [Point]()
        for i in 0..<x.count {
            pts.append(Point(x[i], y[i]))
        }
        let s = Series(points: pts, label: label, startColor: startColor, endColor: endColor, scatterPattern: scatterPattern)
        addSeries(s)
    }
    public func addSeries(_ y: [Float], label: String, color: Color = .lightBlue, scatterPattern: ScatterPlotSeriesOptions.ScatterPattern = .circle){
        var pts = [Point]()
        for i in 0..<y.count {
            pts.append(Point(Float(i+1), y[i]))
        }
        let s = Series(points: pts, label: label, color: color, scatterPattern: scatterPattern)
        addSeries(s)
    }
    public func addSeries(_ y: [Float], label: String, startColor: Color = .lightBlue, endColor: Color = .lightBlue, scatterPattern: ScatterPlotSeriesOptions.ScatterPattern = .circle){
        var pts = [Point]()
        for i in 0..<y.count {
            pts.append(Point(Float(i+1), y[i]))
        }
        let s = Series(points: pts, label: label, startColor: startColor, endColor: endColor, scatterPattern: scatterPattern)
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
            plotLabel!.xLabelLocation = Point(((plotBorder.bottomRight.x + plotBorder.bottomLeft.x)/2.0) - xWidth/2.0, plotBorder.bottomLeft.y - plotTitle!.titleSize - 0.05*plotDimensions.graphHeight)
            plotLabel!.yLabelLocation = Point((plotBorder.bottomLeft.x - plotTitle!.titleSize - 0.05*plotDimensions.graphWidth), ((plotBorder.bottomLeft.y + plotBorder.topLeft.y)/2.0 - yWidth))
        }
        if (plotTitle != nil) {
          let titleWidth: Float = renderer.getTextWidth(text: plotTitle!.title, textSize: plotTitle!.titleSize)
          plotTitle!.titleLocation = Point(((plotBorder.topRight.x + plotBorder.topLeft.x)/2.0) - titleWidth/2.0, plotBorder.topLeft.y + plotTitle!.titleSize/2.0)
        }
    }

    func calcMarkerLocAndScalePts(renderer: Renderer){

        plotMarkers.xMarkers = [Point]()
        plotMarkers.yMarkers = [Point]()
        plotMarkers.xMarkersTextLocation = [Point]()
        plotMarkers.yMarkersTextLocation = [Point]()
        plotMarkers.xMarkersText = [String]()
        plotMarkers.xMarkersText = [String]()

        var maximumX: Float = getMaxX(points: series[0].points)
        var maximumY: Float = getMaxY(points: series[0].points)
        var minimumX: Float = getMinX(points: series[0].points)
        var minimumY: Float = getMinY(points: series[0].points)

        for index in 1..<series.count {

            let s: Series = series[index]
            let pts = s.points
            var x: Float = getMaxX(points: pts)
            var y: Float = getMaxY(points: pts)
            if (x > maximumX) {
                maximumX = x
            }
            if (y > maximumY) {
                maximumY = y
            }
            x = getMinX(points: pts)
            y = getMinY(points: pts)
            if (x < minimumX) {
                minimumX = x
            }
            if (y < minimumY) {
                minimumY = y
            }
        }

        let origin: Point = Point((plotDimensions.graphWidth/(maximumX-minimumX))*(-minimumX), (plotDimensions.graphHeight/(maximumY-minimumY))*(-minimumY))

        let rightScaleMargin: Float = (plotDimensions.subWidth - plotDimensions.graphWidth)/2.0 - 10.0;
        let topScaleMargin: Float = (plotDimensions.subHeight - plotDimensions.graphHeight)/2.0 - 10.0;
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

        var xM: Float = origin.x
        while xM<=plotDimensions.graphWidth {
            if(xM+inc2<0.0 || xM<0.0) {
                xM = xM+inc2
                continue
            }
            let p: Point = Point(xM, 0)
            plotMarkers.xMarkers.append(p)
            let text_p: Point = Point(xM - (renderer.getTextWidth(text: "\(floor(scaleX*(xM-origin.x)))", textSize: plotMarkers.markerTextSize)/2.0) + 8, -15)
            plotMarkers.xMarkersTextLocation.append(text_p)
            plotMarkers.xMarkersText.append("\(floor(scaleX*(xM-origin.x)))")
            xM = xM + inc2
        }

        xM = origin.x - inc2
        while xM>0.0 {
            if (xM > plotDimensions.graphWidth) {
                xM = xM - inc2
                continue
            }
            let p: Point = Point(xM, 0)
            plotMarkers.xMarkers.append(p)
            let text_p: Point = Point(xM - (renderer.getTextWidth(text: "\(ceil(scaleX*(xM-origin.x)))", textSize: plotMarkers.markerTextSize)/2.0) + 8, -15)
            plotMarkers.xMarkersTextLocation.append(text_p)
            plotMarkers.xMarkersText.append("\(ceil(scaleX*(xM-origin.x)))")
            xM = xM - inc2
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



        // scale points to be plotted according to plot size
        let scaleXInv: Float = 1.0/scaleX;
        let scaleYInv: Float = 1.0/scaleY
        for i in 0..<series.count {
            let pts = series[i].points
            series[i].scaledPoints.removeAll();
            for j in 0..<pts.count {
                let pt: Point = Point((pts[j].x)*scaleXInv + origin.x, (pts[j].y)*scaleYInv + origin.y)
                if (pt.x >= 0.0 && pt.x <= plotDimensions.graphWidth && pt.y >= 0.0 && pt.y <= plotDimensions.graphHeight) {
                    series[i].scaledPoints.append(pt)
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
        for seriesIndex in 0..<series.count {
            var s = series[seriesIndex]
            s.maxY = getMaxY(points: s.scaledPoints)
            s.minY = getMinY(points: s.scaledPoints)
            let seriesYRangeInverse: Float = 1.0/(s.maxY-s.minY)
            switch s.scatterPlotSeriesOptions.scatterPattern {
                case .circle:
                    for index in 0..<s.scaledPoints.count {
                        let p = s.scaledPoints[index]
                        if (s.startColor != nil && s.endColor != nil) {
                            s.color = lerp(startColor: s.startColor!, endColor: s.endColor!, (s.scaledPoints[index].y-s.minY)*seriesYRangeInverse)
                        }
                        renderer.drawSolidCircle(center: p, radius: scatterPatternSize/2, fillColor: s.color, isOriginShifted: true)
                    }
                case .square:
                    for index in 0..<s.scaledPoints.count {
                        let p = s.scaledPoints[index]
                        if (s.startColor != nil && s.endColor != nil) {
                            s.color = lerp(startColor: s.startColor!, endColor: s.endColor!, (s.scaledPoints[index].y-s.minY)*seriesYRangeInverse)
                        }
                        renderer.drawSolidRect(topLeftPoint: Point(p.x-scatterPatternSize/2, p.y+scatterPatternSize/2), topRightPoint: Point(p.x+scatterPatternSize/2, p.y+scatterPatternSize/2), bottomRightPoint: Point(p.x+scatterPatternSize/2, p.y-scatterPatternSize/2), bottomLeftPoint: Point(p.x-scatterPatternSize/2, p.y-scatterPatternSize/2), fillColor: s.color, hatchPattern: .none, isOriginShifted: true)
                    }
                case .triangle:
                    let r = scatterPatternSize/sqrt3
                    for index in 0..<s.scaledPoints.count {
                        let p = s.scaledPoints[index]
                        if (s.startColor != nil && s.endColor != nil) {
                            s.color = lerp(startColor: s.startColor!, endColor: s.endColor!, (s.scaledPoints[index].y-s.minY)*seriesYRangeInverse)
                        }
                        let p1: Point = Point(p.x + 0, p.y + r)
                        let p2: Point = Point(p.x + r*sqrt3/Float(2), p.y - r*Float(0.5))
                        let p3: Point = Point(p.x - r*sqrt3/Float(2), p.y - r*Float(0.5))
                        renderer.drawSolidTriangle(point1: p1, point2: p2, point3: p3, fillColor: s.color, isOriginShifted: true)
                    }
            }
        }
    }

    func drawTitle(renderer: Renderer) {
        if (plotTitle != nil) {
            renderer.drawText(text: plotTitle!.title, location: plotTitle!.titleLocation, textSize: plotTitle!.titleSize, strokeWidth: 1.2, angle: 0, isOriginShifted: false)
        }
    }

    func drawLabels(renderer: Renderer) {
        if (plotLabel != nil) {
          renderer.drawText(text: plotLabel!.xLabel, location: plotLabel!.xLabelLocation, textSize: plotLabel!.labelSize, strokeWidth: 1.2, angle: 0, isOriginShifted: false)
          renderer.drawText(text: plotLabel!.yLabel, location: plotLabel!.yLabelLocation, textSize: plotLabel!.labelSize, strokeWidth: 1.2, angle: 90, isOriginShifted: false)
        }
    }

    func drawLegends(renderer: Renderer) {
        var maxWidth: Float = 0
        for s in series {
            let w = renderer.getTextWidth(text: s.label, textSize: plotLegend.legendTextSize)
            if (w > maxWidth) {
                maxWidth = w
            }
        }

        plotLegend.legendWidth  = maxWidth + 3.5*plotLegend.legendTextSize
        plotLegend.legendHeight = (Float(series.count)*2.0 + 1.0)*plotLegend.legendTextSize

        let p1: Point = Point(plotLegend.legendTopLeft.x, plotLegend.legendTopLeft.y)
        let p2: Point = Point(plotLegend.legendTopLeft.x + plotLegend.legendWidth, plotLegend.legendTopLeft.y)
        let p3: Point = Point(plotLegend.legendTopLeft.x + plotLegend.legendWidth, plotLegend.legendTopLeft.y - plotLegend.legendHeight)
        let p4: Point = Point(plotLegend.legendTopLeft.x, plotLegend.legendTopLeft.y - plotLegend.legendHeight)

        renderer.drawSolidRectWithBorder(topLeftPoint: p1, topRightPoint: p2, bottomRightPoint: p3, bottomLeftPoint: p4, strokeWidth: plotBorder.borderThickness, fillColor: Color.transluscentWhite, borderColor: Color.black, isOriginShifted: false)

        for i in 0..<series.count {
            let tL: Point = Point(plotLegend.legendTopLeft.x + plotLegend.legendTextSize, plotLegend.legendTopLeft.y - (2.0*Float(i) + 1.0)*plotLegend.legendTextSize)
            let bR: Point = Point(tL.x + plotLegend.legendTextSize, tL.y - plotLegend.legendTextSize)
            let tR: Point = Point(bR.x, tL.y)
            let bL: Point = Point(tL.x, bR.y)
            if (series[i].startColor != nil && series[i].endColor != nil) {
                series[i].color = series[i].startColor!
            }
            switch series[i].scatterPlotSeriesOptions.scatterPattern {
                case .circle:
                    let c: Point = Point((tL.x+bR.x)/2, (tL.y+bR.y)/2)
                    renderer.drawSolidCircle(center: c, radius: (tR.x-tL.x)/2, fillColor: series[i].color, isOriginShifted: false)
                case .square:
                    renderer.drawSolidRect(topLeftPoint: tL, topRightPoint: tR, bottomRightPoint: bR, bottomLeftPoint: bL, fillColor: series[i].color, hatchPattern: .none, isOriginShifted: false)
                case .triangle:
                    let c: Point = Point((tL.x+bR.x)/2, (tL.y+bR.y)/2)
                    let r: Float = (tR.x-tL.x)/2
                    let p1: Point = Point(c.x + 0, c.y + r)
                    let p2: Point = Point(c.x + r*sqrt3/Float(2), c.y - r*Float(0.5))
                    let p3: Point = Point(c.x - r*sqrt3/Float(2), c.y - r*Float(0.5))
                    renderer.drawSolidTriangle(point1: p1, point2: p2, point3: p3, fillColor: series[i].color, isOriginShifted: false)
            }
            let p: Point = Point(bR.x + plotLegend.legendTextSize, bR.y)
            renderer.drawText(text: series[i].label, location: p, textSize: plotLegend.legendTextSize, strokeWidth: 1.2, angle: 0, isOriginShifted: false)
        }

    }

    func saveImage(fileName name: String, renderer: Renderer) {
        renderer.drawOutput(fileName: name)
    }
}
