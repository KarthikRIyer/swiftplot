import Foundation

public struct GraphLayout {
    // Inputs.
    var plotDimensions: PlotDimensions
    
    var plotTitle: PlotTitle? = nil
    var plotLabel: PlotLabel? = nil
    var plotLegend = PlotLegend()
    var plotBorder = PlotBorder()
    
    var enablePrimaryAxisGrid = true
    var enableSecondaryAxisGrid = true
    var gridColor = Color.gray
    var gridLineThickness: Float = 0.5
    var markerTextSize: Float = 12
    
    struct Results {
        var xLabelLocation: Point?
        var yLabelLocation: Point?
        var titleLocation: Point?
        
        var plotBorderRect: Rect?
        var plotLegendTopLeft: Point?
        var primaryAxisPlotMarkers = PlotMarkers()
        var secondaryAxisPlotMarkers: PlotMarkers? = nil
        
        var legendRect: Rect?
    }
    
    // Layout.
    
    enum LegendIcon {
        case square(Color)
        case shape(ScatterPlotSeriesOptions.ScatterPattern, Color)
    }
    
    var legendLabels: [(String, LegendIcon)] = []
    var drawLegendIcon: Optional<(Int, Rect, Renderer)->Void> = nil
    
    func layout(renderer: Renderer, calculateMarkers: (inout PlotMarkers, inout PlotMarkers?)->Void) -> Results {
        var results = Results()
        calcBorderAndLegend(results: &results)
        calcLabelLocations(renderer: renderer, results: &results)
        calculateMarkers(&results.primaryAxisPlotMarkers, &results.secondaryAxisPlotMarkers)
        calcLegend(legendLabels, results: &results, renderer: renderer)
        return results
    }
    
    func calcBorderAndLegend(results: inout Results) {
        let borderRect = Rect(
            origin: Point(plotDimensions.subWidth * 0.1, plotDimensions.subHeight * 0.1),
            size: Size(width: plotDimensions.subWidth * 0.8,
                       height: plotDimensions.subHeight * 0.8)
        )
        results.plotBorderRect = borderRect
        results.plotLegendTopLeft = Point(borderRect.minX + Float(20),
                                          borderRect.maxY - Float(20))
    }

    func calcLabelLocations(renderer: Renderer, results: inout Results) {
        if let plotLabel = plotLabel {
            let xWidth = renderer.getTextWidth(text: plotLabel.xLabel, textSize: plotLabel.labelSize)
            let yWidth = renderer.getTextWidth(text: plotLabel.yLabel, textSize: plotLabel.labelSize)
            results.xLabelLocation = Point(
                results.plotBorderRect!.midX - xWidth * 0.5,
                results.plotBorderRect!.minY - plotLabel.labelSize - 0.05 * plotDimensions.graphHeight
            )
            results.yLabelLocation = Point(
                results.plotBorderRect!.origin.x - plotLabel.labelSize - 0.05 * plotDimensions.graphWidth,
                results.plotBorderRect!.midY - yWidth
            )
        }
        if let plotTitle = plotTitle {
          let titleWidth = renderer.getTextWidth(text: plotTitle.title, textSize: plotTitle.titleSize)
          results.titleLocation = Point(
            results.plotBorderRect!.midX - titleWidth * 0.5,
            results.plotBorderRect!.maxY + plotTitle.titleSize * 0.5
          )
        }
    }
    
    func calcLegend(_ labels: [(String, LegendIcon)], results: inout Results, renderer: Renderer) {

        let maxWidth = labels.lazy.map {
            renderer.getTextWidth(text: $0.0, textSize: self.plotLegend.legendTextSize)
        }.max() ?? 0
        
        let legendWidth  = maxWidth + 3.5 * plotLegend.legendTextSize
        let legendHeight = (Float(labels.count)*2.0 + 1.0) * plotLegend.legendTextSize
        
        results.legendRect = Rect(
            origin: results.plotLegendTopLeft!,
            size: Size(width: legendWidth, height: -legendHeight)
        ).normalized
    }
    
    // Drawing.
    
    func drawBackground(results: Results, renderer: Renderer) {
        drawGrid(results: results, renderer: renderer)
        drawBorder(results: results, renderer: renderer)
        drawMarkers(results: results, renderer: renderer)
    }
    
    func drawForeground(results: Results, renderer: Renderer) {
        drawTitle(results: results, renderer: renderer)
        drawLabels(results: results, renderer: renderer)
        drawLegend(legendLabels, results: results, renderer: renderer)
    }
    
    func drawTitle(results: Results, renderer: Renderer) {
        guard let plotTitle = self.plotTitle, let location = results.titleLocation else { return }
        renderer.drawText(text: plotTitle.title,
                          location: location,
                          textSize: plotTitle.titleSize,
                          strokeWidth: 1.2,
                          angle: 0,
                          isOriginShifted: false)
    }

    func drawLabels(results: Results, renderer: Renderer) {
        guard let plotLabel = self.plotLabel else { return }
        if let xLocation = results.xLabelLocation {
            renderer.drawText(text: plotLabel.xLabel,
                              location: xLocation,
                              textSize: plotLabel.labelSize,
                              strokeWidth: 1.2,
                              angle: 0,
                              isOriginShifted: false)
        }
        if let yLocation = results.yLabelLocation {
            renderer.drawText(text: plotLabel.yLabel,
                              location: yLocation,
                              textSize: plotLabel.labelSize,
                              strokeWidth: 1.2,
                              angle: 90,
                              isOriginShifted: false)
        }
    }
    
    func drawBorder(results: Results, renderer: Renderer) {
        guard let borderRect = results.plotBorderRect else { return }
        renderer.drawRect(borderRect,
                          strokeWidth: plotBorder.borderThickness,
                          strokeColor: Color.black, isOriginShifted: false)
    }
    
    func drawGrid(results: Results, renderer: Renderer) {
        guard enablePrimaryAxisGrid || enablePrimaryAxisGrid else { return }
        for index in 0..<results.primaryAxisPlotMarkers.xMarkers.count {
            let p1 = Point(results.primaryAxisPlotMarkers.xMarkers[index].x, 0)
            let p2 = Point(results.primaryAxisPlotMarkers.xMarkers[index].x, plotDimensions.graphHeight)
            renderer.drawLine(startPoint: p1,
                              endPoint: p2,
                              strokeWidth: gridLineThickness,
                              strokeColor: gridColor,
                              isDashed: false,
                              isOriginShifted: true)
        }
    
        if (enablePrimaryAxisGrid) {
            for index in 0..<results.primaryAxisPlotMarkers.yMarkers.count {
                let p1 = Point(0, results.primaryAxisPlotMarkers.yMarkers[index].y)
                let p2 = Point(plotDimensions.graphWidth, results.primaryAxisPlotMarkers.yMarkers[index].y)
                renderer.drawLine(startPoint: p1,
                                  endPoint: p2,
                                  strokeWidth: gridLineThickness,
                                  strokeColor: gridColor,
                                  isDashed: false,
                                  isOriginShifted: true)
            }
        }
        if (enableSecondaryAxisGrid) {
            if let secondaryAxisMarkers = results.secondaryAxisPlotMarkers {
                for index in 0..<secondaryAxisMarkers.yMarkers.count {
                    let p1 = Point(0, secondaryAxisMarkers.yMarkers[index].y)
                    let p2 = Point(plotDimensions.graphWidth, secondaryAxisMarkers.yMarkers[index].y)
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

    func drawMarkers(results: Results, renderer: Renderer) {
        for index in 0..<results.primaryAxisPlotMarkers.xMarkers.count {
            let p1 = Point(results.primaryAxisPlotMarkers.xMarkers[index].x, -6)
            let p2 = Point(results.primaryAxisPlotMarkers.xMarkers[index].x, 0)
            renderer.drawLine(startPoint: p1,
                              endPoint: p2,
                              strokeWidth: plotBorder.borderThickness,
                              strokeColor: Color.black,
                              isDashed: false,
                              isOriginShifted: true)
            renderer.drawText(text: results.primaryAxisPlotMarkers.xMarkersText[index],
                              location: results.primaryAxisPlotMarkers.xMarkersTextLocation[index],
                              textSize: markerTextSize,
                              strokeWidth: 0.7,
                              angle: 0,
                              isOriginShifted: true)
        }

        for index in 0..<results.primaryAxisPlotMarkers.yMarkers.count {
            let p1 = Point(-6, results.primaryAxisPlotMarkers.yMarkers[index].y)
            let p2 = Point(0, results.primaryAxisPlotMarkers.yMarkers[index].y)
            renderer.drawLine(startPoint: p1,
                              endPoint: p2,
                              strokeWidth: plotBorder.borderThickness,
                              strokeColor: Color.black,
                              isDashed: false,
                              isOriginShifted: true)
            renderer.drawText(text: results.primaryAxisPlotMarkers.yMarkersText[index],
                              location: results.primaryAxisPlotMarkers.yMarkersTextLocation[index],
                              textSize: markerTextSize,
                              strokeWidth: 0.7,
                              angle: 0,
                              isOriginShifted: true)
        }
        
        if let secondaryAxisMarkers = results.secondaryAxisPlotMarkers {
            for index in 0..<secondaryAxisMarkers.yMarkers.count {
                let p1 = Point(plotDimensions.graphWidth,
                               (secondaryAxisMarkers.yMarkers[index].y))
                let p2 = Point(plotDimensions.graphWidth + 6,
                               (secondaryAxisMarkers.yMarkers[index].y))
                renderer.drawLine(startPoint: p1,
                                  endPoint: p2,
                                  strokeWidth: plotBorder.borderThickness,
                                  strokeColor: Color.black,
                                  isDashed: false,
                                  isOriginShifted: true)
                renderer.drawText(text: secondaryAxisMarkers.yMarkersText[index],
                                  location: secondaryAxisMarkers.yMarkersTextLocation[index],
                                  textSize: secondaryAxisMarkers.markerTextSize,
                                  strokeWidth: 0.7,
                                  angle: 0,
                                  isOriginShifted: true)
            }
        }
    }
    
    func drawLegend(_ entries: [(String, LegendIcon)], results: Results, renderer: Renderer) {
        
        guard let legendRect = results.legendRect else { return }
        renderer.drawSolidRectWithBorder(legendRect,
                                         strokeWidth: plotBorder.borderThickness,
                                         fillColor: .transluscentWhite,
                                         borderColor: .black,
                                         isOriginShifted: false)
        
        for i in 0..<entries.count {
            let seriesIcon = Rect(
                origin: Point(legendRect.origin.x + plotLegend.legendTextSize,
                              legendRect.maxY - (2.0*Float(i) + 1.0)*plotLegend.legendTextSize),
                size: Size(width: plotLegend.legendTextSize, height: -plotLegend.legendTextSize)
            )
            switch entries[i].1 {
            case .square(let color):
                renderer.drawSolidRect(seriesIcon,
                                       fillColor: color,
                                       hatchPattern: .none,
                                       isOriginShifted: false)
            case .shape(let shape, let color):
                shape.draw(in: seriesIcon,
                           color: color,
                           renderer: renderer)
            }
            let p = Point(seriesIcon.maxX + plotLegend.legendTextSize, seriesIcon.minY)
            renderer.drawText(text: entries[i].0,
                              location: p,
                              textSize: plotLegend.legendTextSize,
                              strokeWidth: 1.2,
                              angle: 0,
                              isOriginShifted: false)
        }
    }
}

public protocol HasGraphLayout: AnyObject {
    var layout: GraphLayout { get set }
}

extension HasGraphLayout {
    public var plotTitle: PlotTitle? {
        get { layout.plotTitle }
        set { layout.plotTitle = newValue }
    }
    public var plotLabel: PlotLabel? {
        get { layout.plotLabel }
        set { layout.plotLabel = newValue }
    }
    public var plotLegend: PlotLegend {
        get { layout.plotLegend }
        set { layout.plotLegend = newValue }
    }
    //    public var plotBorder: PlotBorder {
    //        get { layout.plotBorder }
    //        set { layout.plotBorder = newValue }
    //    }
    public var plotDimensions: PlotDimensions {
        get { layout.plotDimensions }
        set { layout.plotDimensions = newValue }
    }
    public var gridColor: Color {
        get { layout.gridColor }
        set { layout.gridColor = newValue }
    }
    public var gridLineThickness: Float {
        get { layout.gridLineThickness }
        set { layout.gridLineThickness = newValue }
    }
    public var markerTextSize: Float {
        get { layout.markerTextSize }
        set { layout.markerTextSize = newValue }
    }
}

// class defining a barGraph and all it's logic
public class BarGraph<T:LosslessStringConvertible,U:FloatConvertible>: Plot, HasGraphLayout {

    let MAX_DIV: Float = 50

    public var xOffset: Float = 0
    public var yOffset: Float = 0

    public var layout: GraphLayout
    
    public enum GraphOrientation {
        case vertical
        case horizontal
    }
    public var graphOrientation: GraphOrientation = .vertical
    public var space: Int = 20
    
    var scaleY: Float = 1
    var scaleX: Float = 1

    var series = Series<T,U>()
    var stackSeries = [Series<T,U>]()
    var barWidth : Int = 0
    var origin = zeroPoint

    public init(width: Float = 1000,
                height: Float = 660,
                enableGrid: Bool = false){
        layout = GraphLayout(plotDimensions: PlotDimensions(frameWidth: width, frameHeight: height))
        self.enableGrid = enableGrid
    }
    
    public var enableGrid: Bool {
        get { layout.enablePrimaryAxisGrid }
        set { layout.enablePrimaryAxisGrid = newValue }
    }
    
    public func addSeries(_ s: Series<T,U>){
        series = s
    }
    public func addStackSeries(_ s: Series<T,U>) {
        if (series.count != 0 && series.count == s.count) {
            stackSeries.append(s)
        }
        else {
            print("Stack point count does not match the Series point count.")
        }
    }
    public func addStackSeries(_ x: [U],
                               label: String,
                               color: Color = .lightBlue,
                               hatchPattern: BarGraphSeriesOptions.Hatching = .none) {
        var values = [Pair<T,U>]()
        for i in 0..<x.count {
            values.append(Pair<T,U>(series.values[i].x, x[i]))
        }
        let s = Series<T,U>(values: values,
                            label: label,
                            color: color,
                            hatchPattern: hatchPattern)
        addStackSeries(s)
    }
    public func addSeries(values: [Pair<T,U>],
                          label: String,
                          color: Color = Color.lightBlue,
                          hatchPattern: BarGraphSeriesOptions.Hatching = .none,
                          graphOrientation: BarGraph.GraphOrientation = .vertical){
        let s = Series<T,U>(values: values,
                            label: label,
                            color: color,
                            hatchPattern: hatchPattern)
        addSeries(s)
        self.graphOrientation = graphOrientation
    }
    public func addSeries(_ x: [T],
                          _ y: [U],
                          label: String,
                          color: Color = Color.lightBlue,
                          hatchPattern: BarGraphSeriesOptions.Hatching = .none,
                          graphOrientation: BarGraph.GraphOrientation = .vertical){
        var values = [Pair<T,U>]()
        for i in 0..<x.count {
            values.append(Pair<T,U>(x[i], y[i]))
        }
        let s = Series<T,U>(values: values,
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
    public func drawGraphAndOutput(fileName name: String = "swift_plot_bar_graph", renderer: Renderer){
        renderer.plotDimensions = plotDimensions
        drawGraph(renderer: renderer)
        saveImage(fileName: name, renderer: renderer)
    }

    public func drawGraphOutput(fileName name: String = "swift_plot_line_graph",
                                renderer: Renderer){
        renderer.plotDimensions = plotDimensions
        renderer.drawOutput(fileName: name)
    }
    
    public func drawGraph(renderer: Renderer){
        renderer.xOffset = xOffset
        renderer.yOffset = yOffset
        
        var legendSeries = stackSeries.map { ($0.label, GraphLayout.LegendIcon.square($0.color)) }
        legendSeries.insert((series.label, .square(series.color)), at: 0)
        layout.legendLabels = legendSeries
        
        let results = layout.layout(renderer: renderer, calculateMarkers: { primary, secondary in
            calcMarkerLocAndScalePts(markers: &primary, renderer: renderer)
        })
        layout.drawBackground(results: results, renderer: renderer)
          drawPlots(markers: results.primaryAxisPlotMarkers, renderer: renderer)
        layout.drawForeground(results: results, renderer: renderer)
    }

    // functions implementing plotting logic
    func calcMarkerLocAndScalePts(markers: inout PlotMarkers, renderer: Renderer) {

        var maximumY: U = U(0)
        var minimumY: U = U(0)
        var maximumX: U = U(0)
        var minimumX: U = U(0)

        if (graphOrientation == .vertical) {
            barWidth = Int(round(plotDimensions.graphWidth/Float(series.count)))
            maximumY = maxY(points: series.values)
            minimumY = minY(points: series.values)
        }
        else{
            barWidth = Int(round(plotDimensions.graphHeight/Float(series.count)))
            maximumX = maxY(points: series.values)
            minimumX = minY(points: series.values)
        }

        if (graphOrientation == .vertical) {
            for s in stackSeries {
                let minStackY = minY(points: s.values)
                let maxStackY = maxY(points: s.values)

                if (maxStackY > U(0)) {
                    maximumY = maximumY + maxStackY
                }
                if (minStackY < U(0)) {
                    minimumY = minimumY + minStackY
                }

            }

            if (minimumY >= U(0)) {
                origin = zeroPoint
                minimumY = U(0)
            }
            else{
                origin = Point(0.0,
                               (plotDimensions.graphHeight/Float(maximumY-minimumY))*Float(U(-1)*minimumY))
            }

            let topScaleMargin: Float = (plotDimensions.subHeight - plotDimensions.graphHeight)*Float(0.5) - 10.0;
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

            var yM = Float(origin.y)
            while yM<=plotDimensions.graphHeight {
                if(yM+inc1<0.0 || yM<0.0){
                    yM = yM + inc1
                    continue
                }
                let p = Point(0, yM)
                markers.yMarkers.append(p)
                let text_p = Point(-(renderer.getTextWidth(text: "\(ceil(scaleY*(yM-origin.y)))",
                                                           textSize: layout.markerTextSize)+8), yM - 4)
                markers.yMarkersTextLocation.append(text_p)
                markers.yMarkersText.append("\(round(scaleY*(yM-origin.y)))")
                yM = yM + inc1
            }
            yM = origin.y - inc1
            while yM>0.0 {
                let p = Point(0, yM)
                markers.yMarkers.append(p)
                let text_p = Point(-(renderer.getTextWidth(text: "\(floor(scaleY*(yM-origin.y)))",
                                                           textSize: layout.markerTextSize)+8), yM - 4)
                markers.yMarkersTextLocation.append(text_p)
                markers.yMarkersText.append("\(round(scaleY*(yM-origin.y)))")
                yM = yM - inc1
            }

            for i in 0..<series.count {
                let p = Point(Float(i*barWidth) + Float(barWidth)*Float(0.5), 0)
                markers.xMarkers.append(p)
                let bW: Int = barWidth*(i+1)
                let textWidth: Float = renderer.getTextWidth(text: "\(series[i].x)",
                                                             textSize: layout.markerTextSize)
                let text_p = Point(Float(bW) - textWidth*Float(0.5) - Float(barWidth)*Float(0.5),
                                                                     -2.0*layout.markerTextSize)
                markers.xMarkersTextLocation.append(text_p)
                markers.xMarkersText.append("\(series[i].x)")
            }

            // scale points to be plotted according to plot size
            let scaleYInv: Float = 1.0/scaleY
            series.scaledValues.removeAll();
            for j in 0..<series.count {
                let scaledPair = Pair<T,U>(series[j].x,
                                           series[j].y*U(scaleYInv) + U(origin.y))
                series.scaledValues.append(scaledPair)
            }
            for index in 0..<stackSeries.count {
                stackSeries[index].scaledValues.removeAll()
                for j in 0..<(stackSeries[index]).count {
                    let scaledPair = Pair<T,U>((stackSeries[index])[j].x,
                                               ((stackSeries[index])[j].y)*U(scaleYInv)+U(origin.y))
                    stackSeries[index].scaledValues.append(scaledPair)
                }
            }
        }

        else{
            var x = maxY(points: series.values)
            if (x > maximumX) {
                maximumX = x
            }
            x = minY(points: series.values)
            if (x < minimumX) {
                minimumX = x
            }

            for s in stackSeries {
                let minStackX = minY(points: s.values)
                let maxStackX = maxY(points: s.values)
                maximumX = maximumX + maxStackX
                minimumX = minimumX - minStackX
            }

            if minimumX >= U(0) {
                origin = zeroPoint
                minimumX = U(0)
            }
            else{
                origin = Point((plotDimensions.graphWidth/Float(maximumX-minimumX))*Float(U(-1)*minimumX), 0.0)
            }

            let rightScaleMargin: Float = (plotDimensions.subWidth - plotDimensions.graphWidth)*Float(0.5) - 10.0
            scaleX = Float(maximumX - minimumX) / (plotDimensions.graphWidth - rightScaleMargin)

            let nD1: Int = max(getNumberOfDigits(Float(maximumX)), getNumberOfDigits(Float(minimumX)))
            var v1: Float
            if (nD1 > 1 && maximumX <= U(pow(Float(10), Float(nD1 - 1)))) {
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

            var xM = origin.x
            while xM<=plotDimensions.graphWidth {
                if(xM+inc1<0.0 || xM<0.0){
                    xM = xM + inc1
                    continue
                }
                let p = Point(xM, 0)
                markers.xMarkers.append(p)
                let text_p = Point(xM - (renderer.getTextWidth(text: "\(floor(scaleX*(xM-origin.x)))",
                                                               textSize: layout.markerTextSize)*Float(0.5)) + 8,
                                   -20)
                markers.xMarkersTextLocation.append(text_p)
                markers.xMarkersText.append("\(ceil(scaleX*(xM-origin.x)))")
                xM = xM + inc1
            }
            xM = origin.x - inc1
            while xM>0.0 {
                let p = Point(xM, 0)
                markers.xMarkers.append(p)
                let text_p = Point(xM - (renderer.getTextWidth(text: "\(floor(scaleX*(xM-origin.x)))",
                                                               textSize: layout.markerTextSize)*Float(0.5)) + 8,
                                   -20)
                markers.xMarkersTextLocation.append(text_p)
                markers.xMarkersText.append("\(floor(scaleX*(xM-origin.x)))")
                xM = xM - inc1
            }

            for i in 0..<series.count {
                let p = Point(0, Float(i*barWidth) + Float(barWidth)*Float(0.5))
                markers.yMarkers.append(p)
                let bW: Int = barWidth*(i+1)
                let textWidth: Float = renderer.getTextWidth(text: "\(series[i].x)", textSize: layout.markerTextSize)
                let text_p = Point(-1.2*textWidth,
                                   Float(bW)
                                   - layout.markerTextSize/2
                                   - Float(barWidth)*Float(0.5))
                markers.yMarkersTextLocation.append(text_p)
                markers.yMarkersText.append("\(series[i].x)")
            }

            // scale points to be plotted according to plot size
            let scaleXInv: Float = 1.0/scaleX
            series.scaledValues.removeAll();
            for j in 0..<series.count {
                let scaledPair = Pair<T,U>(series[j].x,
                                           series[j].y*U(scaleXInv)+U(origin.x))
                series.scaledValues.append(scaledPair)
            }
            for index in 0..<stackSeries.count {
                stackSeries[index].scaledValues.removeAll()
                for j in 0..<(stackSeries[index]).count {
                    let scaledPair = Pair<T,U>((stackSeries[index])[j].x,
                                                (stackSeries[index])[j].y*U(scaleXInv)+U(origin.x))
                    stackSeries[index].scaledValues.append(scaledPair)
                }
            }
        }

    }

    //functions to draw the plot
    func drawPlots(markers: PlotMarkers, renderer: Renderer) {
        if (graphOrientation == .vertical) {
            for index in 0..<series.count {
                var currentHeightPositive: Float = 0
                var currentHeightNegative: Float = 0
                var rect = Rect(
                    origin: Point(
                        markers.xMarkers[index].x-Float(barWidth)*Float(0.5)+Float(space)*Float(0.5),
                        origin.y),
                    size: Size(
                        width: Float(barWidth - space),
                        height: Float(series.scaledValues[index].y) - origin.y)
                )
                if (rect.size.height >= 0) {
                    currentHeightPositive = rect.size.height
                }
                else {
                    currentHeightNegative = rect.size.height
                }
                renderer.drawSolidRect(rect,
                                       fillColor: series.color,
                                       hatchPattern: series.barGraphSeriesOptions.hatchPattern,
                                       isOriginShifted: true)
                for s in stackSeries {
                    let stackValue = Float(s.scaledValues[index].y)
                    if (stackValue - origin.y >= 0) {
                        rect.origin.y = origin.y + currentHeightPositive
                        rect.size.height = stackValue - origin.y
                        currentHeightPositive += stackValue
                    }
                    else {
                        rect.origin.y = origin.y - currentHeightNegative - stackValue
                        rect.size.height = stackValue - origin.y
                        currentHeightNegative += stackValue
                    }
                    renderer.drawSolidRect(rect,
                                           fillColor: s.color,
                                           hatchPattern: s.barGraphSeriesOptions.hatchPattern,
                                           isOriginShifted: true)
                }
            }
        }
        else {
            for index in 0..<series.count {
                var currentWidthPositive: Float = 0
                var currentWidthNegative: Float = 0
                var rect = Rect(
                    origin: Point(origin.x, markers.yMarkers[index].y-Float(barWidth)*Float(0.5)+Float(space)*Float(0.5)),
                    size: Size(
                        width: Float(series.scaledValues[index].y) - origin.x,
                        height: Float(barWidth - space))
                )
                if (rect.size.width >= 0) {
                    currentWidthPositive = rect.size.width
                }
                else {
                    currentWidthNegative = rect.size.width
                }
                renderer.drawSolidRect(rect,
                                       fillColor: series.color,
                                       hatchPattern: series.barGraphSeriesOptions.hatchPattern,
                                       isOriginShifted: true)
                for s in stackSeries {
                    let stackValue = Float(s.scaledValues[index].y)
                    if (stackValue - origin.x >= 0) {
                        rect.origin.x = origin.x + currentWidthPositive
                        rect.size.width = stackValue - origin.x
                        currentWidthPositive += stackValue
                    }
                    else {
                        rect.origin.x = origin.x - currentWidthNegative - stackValue
                        rect.size.width = stackValue - origin.x
                        currentWidthNegative += stackValue
                    }
                    renderer.drawSolidRect(rect,
                                           fillColor: s.color,
                                           hatchPattern: s.barGraphSeriesOptions.hatchPattern,
                                           isOriginShifted: true)
                }
            }
        }
    }

    func saveImage(fileName name: String, renderer: Renderer) {
        renderer.drawOutput(fileName: name)
    }

}
