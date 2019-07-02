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
    public enum GraphOrientation {
        case vertical
        case horizontal
    }
    public var graphOrientation: GraphOrientation = .vertical
    public var scaleY: Float = 1
    public var scaleX: Float = 1
    public var plotMarkers: PlotMarkers = PlotMarkers()
    public var series: Series<LosslessStringConvertible,FloatConvertible> = Series<LosslessStringConvertible,FloatConvertible>()
    public var stackSeries = [Series<LosslessStringConvertible,FloatConvertible>]()

    var barWidth : Int = 0
    public var space: Int = 20

    var origin: Pair<FloatConvertible,FloatConvertible> = zeroPair

    public init(width: Float = 1000, height: Float = 660){
        plotDimensions = PlotDimensions(frameWidth: width, frameHeight: height)
    }
    public func addSeries(_ s: Series<LosslessStringConvertible,FloatConvertible>){
        series = s
    }
    public func addStackSeries(_ s: Series<LosslessStringConvertible,FloatConvertible>) {
        if (series.pairs.count != 0 && series.pairs.count == s.pairs.count) {
            stackSeries.append(s)
        }
        else {
            print("Stack point count does not match the Series point count.")
        }
    }
    public func addStackSeries(_ x: [Float],
                               label: String,
                               color: Color = .lightBlue,
                               hatchPattern: BarGraphSeriesOptions.Hatching = .none) {
        var pairs = [Pair<LosslessStringConvertible,FloatConvertible>]()
        for i in 0..<x.count {
            pairs.append(Pair<LosslessStringConvertible,FloatConvertible>(series.pairs[i].x, x[i]))
        }
        let s = Series<LosslessStringConvertible,FloatConvertible>(pairs: pairs,
                                                                   label: label,
                                                                   color: color,
                                                                   hatchPattern: hatchPattern)
        addStackSeries(s)
    }
    public func addSeries(pairs : [Pair<LosslessStringConvertible,FloatConvertible>],
                          label: String,
                          color: Color = Color.lightBlue,
                          hatchPattern: BarGraphSeriesOptions.Hatching = .none,
                          graphOrientation: BarGraph.GraphOrientation = .vertical){
        let s = Series<LosslessStringConvertible,FloatConvertible>(pairs: pairs,
                                                                   label: label,
                                                                   color: color,
                                                                   hatchPattern: hatchPattern)
        addSeries(s)
        self.graphOrientation = graphOrientation
    }
    public func addSeries<T: LosslessStringConvertible, U: FloatConvertible>(_ x: [T],
                                                                             _ y: [U],
                                                                             label: String,
                                                                             color: Color = Color.lightBlue,
                                                                             hatchPattern: BarGraphSeriesOptions.Hatching = .none,
                                                                             graphOrientation: BarGraph.GraphOrientation = .vertical){
        var pairs = [Pair<LosslessStringConvertible, FloatConvertible>]()
        for i in 0..<x.count {
            pairs.append(Pair<LosslessStringConvertible,FloatConvertible>(x[i], y[i]))
        }
        let s = Series<LosslessStringConvertible,FloatConvertible>(pairs: pairs,
                                                                   label: label,
                                                                   color: color,
                                                                   hatchPattern: hatchPattern)
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

    public func drawGraphOutput(fileName name: String = "swift_plot_line_graph",
                                renderer: Renderer){
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
            plotLabel!.xLabelLocation = Pair<FloatConvertible,FloatConvertible>(((Float(plotBorder.bottomRight.x)
                                                                                + Float(plotBorder.bottomLeft.x))*Float(0.5))
                                                                                - xWidth*Float(0.5),
                                                                                Float(plotBorder.bottomLeft.y)
                                                                                - plotLabel!.labelSize
                                                                                - 0.05*plotDimensions.graphHeight)
            plotLabel!.yLabelLocation = Pair<FloatConvertible,FloatConvertible>((Float(plotBorder.bottomLeft.x)
                                                                               - plotLabel!.labelSize
                                                                               - 0.05*plotDimensions.graphWidth),
                                                                               ((Float(plotBorder.bottomLeft.y)
                                                                               + Float(plotBorder.topLeft.y))*Float(0.5)
                                                                               - yWidth))
        }
        if (plotTitle != nil) {
          let titleWidth: Float = renderer.getTextWidth(text: plotTitle!.title,
                                                        textSize: plotTitle!.titleSize)
          plotTitle!.titleLocation = Pair<FloatConvertible,FloatConvertible>(((Float(plotBorder.topRight.x)
                                                                             + Float(plotBorder.topLeft.x))*Float(0.5))
                                                                             - titleWidth*Float(0.5),
                                                                             Float(plotBorder.topLeft.y)
                                                                             + plotTitle!.titleSize*Float(0.5))
        }
    }

    func calcMarkerLocAndScalePts(renderer: Renderer){

        var maximumY: Float = 0
        var minimumY: Float = 0
        var maximumX: Float = 0
        var minimumX: Float = 0

        if (graphOrientation == .vertical) {
            barWidth = Int(round(plotDimensions.graphWidth/Float(series.pairs.count)))
            maximumY = getMaxY(pairs: series.pairs)
            minimumY = getMinY(pairs: series.pairs)
        }
        else{
            barWidth = Int(round(plotDimensions.graphHeight/Float(series.pairs.count)))
            maximumX = getMaxY(pairs: series.pairs)
            minimumX = getMinY(pairs: series.pairs)
        }

        plotMarkers.xMarkers = [Pair<FloatConvertible,FloatConvertible>]()
        plotMarkers.yMarkers = [Pair<FloatConvertible,FloatConvertible>]()
        plotMarkers.xMarkersTextLocation = [Pair<FloatConvertible,FloatConvertible>]()
        plotMarkers.yMarkersTextLocation = [Pair<FloatConvertible,FloatConvertible>]()
        plotMarkers.xMarkersText = [String]()
        plotMarkers.xMarkersText = [String]()


        let pairs = series.pairs
        if (graphOrientation == .vertical) {
            for s in stackSeries {
                let minStackY = getMinY(pairs: s.pairs)
                let maxStackY = getMaxY(pairs: s.pairs)

                if (maxStackY>0) {
                    maximumY = maximumY + maxStackY
                }
                if (minStackY<0) {
                    minimumY = minimumY + minStackY
                }

            }

            if minimumY>=0.0 {
                origin = zeroPair
                minimumY = 0.0
            }
            else{
                origin = Pair<FloatConvertible,FloatConvertible>(0.0,
                                                                (plotDimensions.graphHeight/(maximumY-minimumY))*(-minimumY))
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

            var yM = Float(origin.y)
            while yM<=plotDimensions.graphHeight {
                if(yM+inc1<0.0 || yM<0.0){
                    yM = yM + inc1
                    continue
                }
                let p = Pair<FloatConvertible,FloatConvertible>(0, yM)
                plotMarkers.yMarkers.append(p)
                let text_p = Pair<FloatConvertible,FloatConvertible>(-(renderer.getTextWidth(text: "\(ceil(scaleY*(yM-Float(origin.y))))",
                                                                     textSize: plotMarkers.markerTextSize)+5), yM - 4)
                plotMarkers.yMarkersTextLocation.append(text_p)
                plotMarkers.yMarkersText.append("\(ceil(scaleY*(yM-Float(origin.y))))")
                yM = yM + inc1
            }
            yM = Float(origin.y) - inc1
            while yM>0.0 {
                let p = Pair<FloatConvertible,FloatConvertible>(0, yM)
                plotMarkers.yMarkers.append(p)
                let text_p = Pair<FloatConvertible,FloatConvertible>(-(renderer.getTextWidth(text: "\(floor(scaleY*(yM-Float(origin.y))))",
                                                                     textSize: plotMarkers.markerTextSize)+5), yM - 4)
                plotMarkers.yMarkersTextLocation.append(text_p)
                plotMarkers.yMarkersText.append("\(floor(scaleY*(yM-Float(origin.y))))")
                yM = yM - inc1
            }

            for i in 0..<series.pairs.count {
                let p = Pair<FloatConvertible,FloatConvertible>(Float(i*barWidth) + Float(barWidth)*Float(0.5), 0)
                plotMarkers.xMarkers.append(p)
                let bW: Int = barWidth*(i+1)
                let textWidth: Float = renderer.getTextWidth(text: "\(series.pairs[i].x)",
                                                             textSize: plotMarkers.markerTextSize)
                let text_p = Pair<FloatConvertible,FloatConvertible>(Float(bW) - textWidth*Float(0.5) - Float(barWidth)*Float(0.5),
                                                                     -2.0*plotMarkers.markerTextSize)
                plotMarkers.xMarkersTextLocation.append(text_p)
                plotMarkers.xMarkersText.append("\(series.pairs[i].x)")
            }

            // scale points to be plotted according to plot size
            let scaleYInv: Float = 1.0/scaleY
            series.scaledPairs.removeAll();
            for j in 0..<pairs.count {
                let scaledPair = Pair<LosslessStringConvertible,FloatConvertible>(pairs[j].x,
                                                                                  Float(pairs[j].y)*scaleYInv + Float(origin.y))
                series.scaledPairs.append(scaledPair)
            }
            for index in 0..<stackSeries.count {
                stackSeries[index].scaledPairs.removeAll()
                for j in 0..<stackSeries[index].pairs.count {
                    let scaledPair = Pair<LosslessStringConvertible,FloatConvertible>(stackSeries[index].pairs[j].x,
                                                                                      Float(stackSeries[index].pairs[j].y)*scaleYInv+Float(origin.y))
                    stackSeries[index].scaledPairs.append(scaledPair)
                }
            }
        }

        else{
            var x: Float = getMaxY(pairs: pairs)
            if (x > maximumX) {
                maximumX = x
            }
            x = getMinY(pairs: pairs)
            if (x < minimumX) {
                minimumX = x
            }

            for s in stackSeries {
                let minStackX = getMinY(pairs: s.pairs)
                let maxStackX = getMaxY(pairs: s.pairs)
                maximumX = maximumX + maxStackX
                minimumX = minimumX - minStackX
            }

            if minimumX>=0.0 {
                origin = zeroPair
                minimumX = 0.0
            }
            else{
                origin = Pair<FloatConvertible,FloatConvertible>((plotDimensions.graphWidth/(maximumX-minimumX))*(-minimumX), 0.0)
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

            var xM = Float(origin.x)
            while xM<=plotDimensions.graphWidth {
                if(xM+inc1<0.0 || xM<0.0){
                    xM = xM + inc1
                    continue
                }
                let p = Pair<FloatConvertible,FloatConvertible>(xM, 0)
                plotMarkers.xMarkers.append(p)
                let text_p = Pair<FloatConvertible,FloatConvertible>(xM - (renderer.getTextWidth(text: "\(floor(scaleX*(xM-Float(origin.x))))",
                                                                                                 textSize: plotMarkers.markerTextSize)*Float(0.5)) + 8,
                                                                     -15)
                plotMarkers.xMarkersTextLocation.append(text_p)
                plotMarkers.xMarkersText.append("\(ceil(scaleX*(xM-Float(origin.x))))")
                xM = xM + inc1
            }
            xM = Float(origin.x) - inc1
            while xM>0.0 {
                let p = Pair<FloatConvertible,FloatConvertible>(xM, 0)
                plotMarkers.xMarkers.append(p)
                let text_p = Pair<FloatConvertible,FloatConvertible>(xM - (renderer.getTextWidth(text: "\(floor(scaleX*(xM-Float(origin.x))))",
                                                                                                 textSize: plotMarkers.markerTextSize)*Float(0.5)) + 8,
                                                                     -15)
                plotMarkers.xMarkersTextLocation.append(text_p)
                plotMarkers.xMarkersText.append("\(floor(scaleX*(xM-Float(origin.x))))")
                xM = xM - inc1
            }

            for i in 0..<series.pairs.count {
                let p = Pair<FloatConvertible,FloatConvertible>(0, Float(i*barWidth) + Float(barWidth)*Float(0.5))
                plotMarkers.yMarkers.append(p)
                let bW: Int = barWidth*(i+1)
                let textWidth: Float = renderer.getTextWidth(text: "\(series.pairs[i].x)", textSize: plotMarkers.markerTextSize)
                let text_p = Pair<FloatConvertible,FloatConvertible>(-1.2*textWidth,
                                                                     Float(bW)
                                                                     - plotMarkers.markerTextSize/2
                                                                     - Float(barWidth)*Float(0.5))
                plotMarkers.yMarkersTextLocation.append(text_p)
                plotMarkers.yMarkersText.append("\(series.pairs[i].x)")
            }

            // scale points to be plotted according to plot size
            let scaleXInv: Float = 1.0/scaleX
            series.scaledPairs.removeAll();
            for j in 0..<pairs.count {
                let scaledPair = Pair<LosslessStringConvertible,FloatConvertible>(pairs[j].x,
                                                                                  Float(pairs[j].y)*scaleXInv+Float(origin.x))
                series.scaledPairs.append(scaledPair)
            }
            for index in 0..<stackSeries.count {
                stackSeries[index].scaledPairs.removeAll()
                for j in 0..<stackSeries[index].pairs.count {
                    let scaledPair = Pair<LosslessStringConvertible,FloatConvertible>(stackSeries[index].pairs[j].x,
                                                                                      Float(stackSeries[index].pairs[j].y)*scaleXInv+Float(origin.x))
                    stackSeries[index].scaledPairs.append(scaledPair)
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
                          strokeColor: Color.black, isOriginShifted: false)
    }

    func drawMarkers(renderer: Renderer) {
        for index in 0..<plotMarkers.xMarkers.count {
            let p1 = Pair<FloatConvertible,FloatConvertible>(plotMarkers.xMarkers[index].x, -3)
            let p2 = Pair<FloatConvertible,FloatConvertible>(plotMarkers.xMarkers[index].x, 0)
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
        if (graphOrientation == .vertical) {
            for index in 0..<series.pairs.count {
                var currentHeightPositive: Float = 0
                var currentHeightNegative: Float = 0
                var tL = Pair<FloatConvertible,FloatConvertible>(Float(plotMarkers.xMarkers[index].x)-Float(barWidth)*Float(0.5)+Float(space)*Float(0.5),
                                                                 Float(series.scaledPairs[index].y))
                var tR = Pair<FloatConvertible,FloatConvertible>(Float(plotMarkers.xMarkers[index].x)+Float(barWidth)*Float(0.5)-Float(space)*Float(0.5),
                                                                 Float(series.scaledPairs[index].y))
                var bL = Pair<FloatConvertible,FloatConvertible>(Float(plotMarkers.xMarkers[index].x)-Float(barWidth)*Float(0.5)+Float(space)*Float(0.5),
                                                                 Float(origin.y))
                var bR = Pair<FloatConvertible,FloatConvertible>(Float(plotMarkers.xMarkers[index].x)+Float(barWidth)*Float(0.5)-Float(space)*Float(0.5),
                                                                 Float(origin.y))
                if (Float(tL.y) - Float(bL.y) >= 0) {
                    currentHeightPositive = Float(tL.y) - Float(bL.y)
                }
                else {
                    currentHeightNegative = Float(tL.y) - Float(bL.y)
                }
                renderer.drawSolidRect(topLeftPoint: tL,
                                       topRightPoint: tR,
                                       bottomRightPoint: bR,
                                       bottomLeftPoint: bL,
                                       fillColor: series.color,
                                       hatchPattern: series.barGraphSeriesOptions.hatchPattern,
                                       isOriginShifted: true)
                for s in stackSeries {
                    tL = Pair<FloatConvertible,FloatConvertible>(Float(plotMarkers.xMarkers[index].x)-Float(barWidth)*Float(0.5)+Float(space)*Float(0.5),
                                                                 Float(s.scaledPairs[index].y))
                    bL = Pair<FloatConvertible,FloatConvertible>(Float(plotMarkers.xMarkers[index].x)-Float(barWidth)*Float(0.5)+Float(space)*Float(0.5),
                                                                 Float(origin.y))
                    if (Float(tL.y) - Float(bL.y) >= 0) {
                        tL = Pair<FloatConvertible,FloatConvertible>(Float(plotMarkers.xMarkers[index].x)-Float(barWidth)*Float(0.5)+Float(space)*Float(0.5),
                                                                     Float(s.scaledPairs[index].y) + currentHeightPositive)
                        tR = Pair<FloatConvertible,FloatConvertible>(Float(plotMarkers.xMarkers[index].x)+Float(barWidth)*Float(0.5)-Float(space)*Float(0.5),
                                                                     Float(s.scaledPairs[index].y) + currentHeightPositive)
                        bL = Pair<FloatConvertible,FloatConvertible>(Float(plotMarkers.xMarkers[index].x)-Float(barWidth)*Float(0.5)+Float(space)*Float(0.5),
                                                                     Float(origin.y) + currentHeightPositive)
                        bR = Pair<FloatConvertible,FloatConvertible>(Float(plotMarkers.xMarkers[index].x) + Float(barWidth)*Float(0.5) - Float(space)*Float(0.5),
                                                                     Float(origin.y) + currentHeightPositive)
                    }
                    else {
                        tL = Pair<FloatConvertible,FloatConvertible>(Float(plotMarkers.xMarkers[index].x)-Float(barWidth)*Float(0.5)+Float(space)*Float(0.5),
                                                                     Float(s.scaledPairs[index].y) + currentHeightNegative)
                        tR = Pair<FloatConvertible,FloatConvertible>(Float(plotMarkers.xMarkers[index].x)+Float(barWidth)*Float(0.5)-Float(space)*Float(0.5),
                                                                     Float(s.scaledPairs[index].y) + currentHeightNegative)
                        bL = Pair<FloatConvertible,FloatConvertible>(Float(plotMarkers.xMarkers[index].x)-Float(barWidth)*Float(0.5)+Float(space)*Float(0.5),
                                                                     Float(origin.y) + currentHeightNegative)
                        bR = Pair<FloatConvertible,FloatConvertible>(Float(plotMarkers.xMarkers[index].x)+Float(barWidth)*Float(0.5)-Float(space)*Float(0.5),
                                                                     Float(origin.y) + currentHeightNegative)
                    }
                    let heightIncrement = Float(tL.y) - Float(bL.y)
                    if (heightIncrement >= 0) {
                        currentHeightPositive = currentHeightPositive + heightIncrement
                    }
                    else {
                        currentHeightNegative = currentHeightNegative + heightIncrement
                    }
                    renderer.drawSolidRect(topLeftPoint: tL,
                                           topRightPoint: tR,
                                           bottomRightPoint: bR,
                                           bottomLeftPoint: bL,
                                           fillColor: s.color,
                                           hatchPattern: s.barGraphSeriesOptions.hatchPattern,
                                           isOriginShifted: true)
                }
            }
        }
        else {
            for index in 0..<series.pairs.count {
                var currentWidthPositive: Float = 0
                var currentWidthNegative: Float = 0
                var tL = Pair<FloatConvertible,FloatConvertible>(Float(origin.x),
                                                                 Float(plotMarkers.yMarkers[index].y)+Float(barWidth)*Float(0.5)-Float(space)*Float(0.5))
                var tR = Pair<FloatConvertible,FloatConvertible>(Float(series.scaledPairs[index].y),
                                                                 Float(plotMarkers.yMarkers[index].y)+Float(barWidth)*Float(0.5)-Float(space)*Float(0.5))
                var bL = Pair<FloatConvertible,FloatConvertible>(Float(origin.x),
                                                                 Float(plotMarkers.yMarkers[index].y)-Float(barWidth)*Float(0.5)+Float(space)*Float(0.5))
                var bR = Pair<FloatConvertible,FloatConvertible>(Float(series.scaledPairs[index].y),
                                                                 Float(plotMarkers.yMarkers[index].y)-Float(barWidth)*Float(0.5)+Float(space)*Float(0.5))
                if (Float(tR.x) - Float(tL.x) >= 0) {
                    currentWidthPositive = Float(tR.x) - Float(tL.x)
                }
                else {
                    currentWidthNegative = Float(tR.x) - Float(tL.x)
                }
                renderer.drawSolidRect(topLeftPoint: tL,
                                       topRightPoint: tR,
                                       bottomRightPoint: bR,
                                       bottomLeftPoint: bL,
                                       fillColor: series.color,
                                       hatchPattern: series.barGraphSeriesOptions.hatchPattern,
                                       isOriginShifted: true)
                for s in stackSeries {

                    tL = Pair<FloatConvertible,FloatConvertible>(Float(origin.x),
                                                                 Float(plotMarkers.yMarkers[index].y)+Float(barWidth)*Float(0.5)-Float(space)*Float(0.5))
                    tR = Pair<FloatConvertible,FloatConvertible>(Float(s.scaledPairs[index].y),
                                                                 Float(plotMarkers.yMarkers[index].y)+Float(barWidth)*Float(0.5)-Float(space)*Float(0.5))
                    if (Float(tR.x) - Float(tL.x) >= 0) {
                        tL = Pair<FloatConvertible,FloatConvertible>(Float(origin.x)+currentWidthPositive,
                                                                     Float(plotMarkers.yMarkers[index].y)+Float(barWidth)*Float(0.5)-Float(space)*Float(0.5))
                        tR = Pair<FloatConvertible,FloatConvertible>(Float(s.scaledPairs[index].y)+currentWidthPositive,
                                                                     Float(plotMarkers.yMarkers[index].y)+Float(barWidth)/2.0-Float(space)*Float(0.5))
                        bL = Pair<FloatConvertible,FloatConvertible>(Float(origin.x)+currentWidthPositive,
                                                                     Float(plotMarkers.yMarkers[index].y)-Float(barWidth)*Float(0.5)+Float(space)*Float(0.5))
                        bR = Pair<FloatConvertible,FloatConvertible>(Float(s.scaledPairs[index].y)+currentWidthPositive,
                                                                     Float(plotMarkers.yMarkers[index].y)-Float(barWidth)/2.0+Float(space)*Float(0.5))
                    }
                    else {
                        tL = Pair<FloatConvertible,FloatConvertible>(Float(origin.x)+currentWidthNegative,
                                                                     Float(plotMarkers.yMarkers[index].y)+Float(barWidth)*Float(0.5)-Float(space)*Float(0.5))
                        tR = Pair<FloatConvertible,FloatConvertible>(Float(s.scaledPairs[index].y)+currentWidthNegative,
                                                                     Float(plotMarkers.yMarkers[index].y)+Float(barWidth)/2.0-Float(space)*Float(0.5))
                        bL = Pair<FloatConvertible,FloatConvertible>(Float(origin.x)+currentWidthNegative,
                                                                     Float(plotMarkers.yMarkers[index].y)-Float(barWidth)*Float(0.5)+Float(space)*Float(0.5))
                        bR = Pair<FloatConvertible,FloatConvertible>(Float(s.scaledPairs[index].y)+currentWidthNegative,
                                                                     Float(plotMarkers.yMarkers[index].y)-Float(barWidth)*Float(0.5)+Float(space)*Float(0.5))
                    }
                    let widthIncrement = Float(tR.x) - Float(tL.x)
                    if (widthIncrement >= 0) {
                        currentWidthPositive = currentWidthPositive + widthIncrement
                    }
                    else {
                        currentWidthNegative = currentWidthNegative + widthIncrement
                    }
                    renderer.drawSolidRect(topLeftPoint: tL,
                                           topRightPoint: tR,
                                           bottomRightPoint: bR,
                                           bottomLeftPoint: bL,
                                           fillColor: s.color,
                                           hatchPattern: s.barGraphSeriesOptions.hatchPattern,
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
        var legendSeries = stackSeries
        legendSeries.insert(series, at: 0)
        for s in legendSeries {
        	let w = renderer.getTextWidth(text: s.label,
                                        textSize: plotLegend.legendTextSize)
        	if (w > maxWidth) {
        		maxWidth = w
        	}
        }
        plotLegend.legendWidth  = maxWidth + 3.5*plotLegend.legendTextSize
        plotLegend.legendHeight = (Float(stackSeries.count + 1)*2.0 + 1.0)*plotLegend.legendTextSize

        let p1 = Pair<FloatConvertible,FloatConvertible>(Float(plotLegend.legendTopLeft.x),
                                                         Float(plotLegend.legendTopLeft.y))
        let p2 = Pair<FloatConvertible,FloatConvertible>(Float(plotLegend.legendTopLeft.x)+plotLegend.legendWidth,
                                                         Float(plotLegend.legendTopLeft.y))
        let p3 = Pair<FloatConvertible,FloatConvertible>(Float(plotLegend.legendTopLeft.x)+plotLegend.legendWidth,
                                                         Float(plotLegend.legendTopLeft.y)-plotLegend.legendHeight)
        let p4 = Pair<FloatConvertible,FloatConvertible>(Float(plotLegend.legendTopLeft.x),
                                                         Float(plotLegend.legendTopLeft.y)-plotLegend.legendHeight)

        renderer.drawSolidRectWithBorder(topLeftPoint: p1,
                                         topRightPoint: p2,
                                         bottomRightPoint: p3,
                                         bottomLeftPoint: p4,
                                         strokeWidth: plotBorder.borderThickness,
                                         fillColor: .transluscentWhite,
                                         borderColor: .black,
                                         isOriginShifted: false)

        for i in 0..<legendSeries.count {
        	let tL = Pair<FloatConvertible,FloatConvertible>(Float(plotLegend.legendTopLeft.x)+plotLegend.legendTextSize,
                                                           Float(plotLegend.legendTopLeft.y)-(2.0*Float(i) + 1.0)*plotLegend.legendTextSize)
        	let bR = Pair<FloatConvertible,FloatConvertible>(Float(tL.x)+plotLegend.legendTextSize,
                                                           Float(tL.y)-plotLegend.legendTextSize)
        	let tR = Pair<FloatConvertible,FloatConvertible>(Float(bR.x), Float(tL.y))
        	let bL = Pair<FloatConvertible,FloatConvertible>(Float(tL.x), Float(bR.y))
        	renderer.drawSolidRect(topLeftPoint: tL,
                                 topRightPoint: tR,
                                 bottomRightPoint: bR,
                                 bottomLeftPoint: bL,
                                 fillColor: legendSeries[i].color,
                                 hatchPattern: .none,
                                 isOriginShifted: false)
        	let p = Pair<FloatConvertible,FloatConvertible>(Float(bR.x) + plotLegend.legendTextSize,
                                                          Float(bR.y))
        	renderer.drawText(text: legendSeries[i].label,
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
