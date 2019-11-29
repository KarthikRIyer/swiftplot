import Foundation

public enum LegendIcon {
    case square(Color)
    case shape(ScatterPlotSeriesOptions.ScatterPattern, Color)
}

public struct GraphLayout {
    // Inputs.
    var plotSize: Size
    
    init(size: Size) {
        self.plotSize = size
    }
    var backgroundColor: Color = .white
    var plotBackgroundColor: Color?
    var plotTitle = PlotTitle()
    var plotLabel  = PlotLabel()
    var plotLegend = PlotLegend()
    var plotBorder = PlotBorder()
    var grid = Grid()
    var legendLabels: [(String, LegendIcon)] = []
    
    var enablePrimaryAxisGrid = true
    var enableSecondaryAxisGrid = true
    var markerTextSize: Float = 12
    /// The amount of (horizontal) space to reserve for markers on the Y-axis.
    var yMarkerMaxWidth: Float = 40
    
    struct Results {
        var plotBorderRect: Rect?
        
        var xLabelLocation: Rect?
        var yLabelLocation: Rect?
        var y2LabelLocation: Rect?
        var titleLocation: Rect?
        
        var plotMarkers = PlotMarkers()
        var xMarkersTextLocation = [Point]()
        var yMarkersTextLocation = [Point]()
        var y2MarkersTextLocation = [Point]()
        
        var legendRect: Rect?
    }
    
    // Layout.
        
    func layout(renderer: Renderer, calculateMarkers: (inout PlotMarkers, Size)->Void) -> Results {
        var results = Results()
        calcLabelLocations(renderer: renderer, results: &results)
        calcBorder(results: &results, renderer: renderer)
        recenterLabels(&results)

        calculateMarkers(&results.plotMarkers, results.plotBorderRect!.size)
        
        calcMarkerTextLocations(renderer: renderer, results: &results)
        calcLegend(legendLabels, renderer: renderer, results: &results)
        return results
    }
    
    static let xLabelPadding: Float = 10
    static let yLabelPadding: Float = 10
    static let titleLabelPadding: Float = 14
    
    func calcBorder(results: inout Results, renderer: Renderer) {
        var borderRect = Rect(
            origin: zeroPoint,
            size: self.plotSize
        )
        if let xLabel = results.xLabelLocation {
            borderRect.clampingShift(dy: xLabel.maxY + Self.xLabelPadding)
        }
        if let yLabel = results.yLabelLocation {
            borderRect.clampingShift(dx: yLabel.origin.x + Self.yLabelPadding)
        }
        if let y2Label = results.y2LabelLocation {
            borderRect.size.width -= plotSize.width - (y2Label.origin.x - Self.yLabelPadding)
        }
        if let titleLabel = results.titleLocation {
            borderRect.size.height = titleLabel.origin.y - borderRect.origin.y - Self.titleLabelPadding
        }
        borderRect.contract(by: plotBorder.thickness)
        // Give space for the markers.
        borderRect.clampingShift(dy: 2 * markerTextSize) // X markers
        // TODO: Better space calculation for Y/Y2 markers.
        borderRect.clampingShift(dx: yMarkerMaxWidth + 10) // Y markers
        borderRect.size.width -= yMarkerMaxWidth + 10 // Y2 markers

        results.plotBorderRect = borderRect
    }
    
    func recenterLabels(_ results: inout Results) {
        // TODO: Move recentering until after markers have been processed, so we can center within the empty space
        // if there are no markers.
        if var xLabel = results.xLabelLocation {
            xLabel.origin.x = results.plotBorderRect!.midX - xLabel.width/2
            results.xLabelLocation = xLabel
        }
        if var titleLabel = results.titleLocation {
            titleLabel.origin.x = results.plotBorderRect!.midX - titleLabel.width/2
            results.titleLocation = titleLabel
        }
        if var yLabel = results.yLabelLocation {
            yLabel.origin.y = results.plotBorderRect!.midY - yLabel.width/2
            results.yLabelLocation = yLabel
        }
        if var y2Label = results.y2LabelLocation {
            y2Label.origin.y = results.plotBorderRect!.midY - y2Label.width/2
            results.y2LabelLocation = y2Label
        }
    }

    func calcLabelLocations(renderer: Renderer, results: inout Results) {
        if !plotLabel.xLabel.isEmpty {
            let xLabelSize = renderer.getTextLayoutSize(text: plotLabel.xLabel, textSize: plotLabel.size)
            results.xLabelLocation = Rect(origin: Point(plotSize.width/2 - xLabelSize.width/2, Self.xLabelPadding),
                                          size: xLabelSize)
        }
        if !plotLabel.yLabel.isEmpty {
            let yLabelSize = renderer.getTextLayoutSize(text: plotLabel.yLabel, textSize: plotLabel.size)
            results.yLabelLocation = Rect(origin: Point(Self.yLabelPadding + yLabelSize.height,
                                                        plotSize.height/2 - yLabelSize.width/2),
                                          size: yLabelSize)
        }
        if !plotLabel.y2Label.isEmpty {
            let y2LabelSize = renderer.getTextLayoutSize(text: plotLabel.y2Label, textSize: plotLabel.size)
            results.y2LabelLocation = Rect(origin: Point(plotSize.width - y2LabelSize.height - Self.yLabelPadding,
                                                         plotSize.height/2 - y2LabelSize.width/2),
                                           size: y2LabelSize)
        }
        
        if !plotTitle.title.isEmpty {
          let titleSize = renderer.getTextLayoutSize(text: plotTitle.title, textSize: plotTitle.size)
          results.titleLocation = Rect(origin: Point(
            plotSize.width/2 - titleSize.width/2,
            plotSize.height  - titleSize.height - Self.titleLabelPadding
          ), size: titleSize)
        }
    }
    
    func calcMarkerTextLocations(renderer: Renderer, results: inout Results) {
        
        for i in 0..<results.plotMarkers.xMarkers.count {
            let textWidth = renderer.getTextWidth(text: results.plotMarkers.xMarkersText[i], textSize: markerTextSize)
            let text_p = Point(results.plotMarkers.xMarkers[i] - (textWidth/2), -2.0 * markerTextSize)
            results.xMarkersTextLocation.append(text_p)
        }
        
        for i in 0..<results.plotMarkers.yMarkers.count {
            var textWidth = renderer.getTextWidth(text: results.plotMarkers.yMarkersText[i], textSize: markerTextSize)
            textWidth = min(textWidth, yMarkerMaxWidth)
            let text_p = Point(-textWidth - 8, results.plotMarkers.yMarkers[i] - 4)
            results.yMarkersTextLocation.append(text_p)
        }
        
        for i in 0..<results.plotMarkers.y2Markers.count {
            let text_p = Point(results.plotBorderRect!.width + 8, results.plotMarkers.y2Markers[i] - 4)
            results.y2MarkersTextLocation.append(text_p)
        }
    }
    
    func calcLegend(_ labels: [(String, LegendIcon)], renderer: Renderer, results: inout Results) {
        guard !labels.isEmpty else { return }
        let maxWidth = labels.lazy.map {
            renderer.getTextWidth(text: $0.0, textSize: self.plotLegend.textSize)
        }.max() ?? 0
        
        let legendWidth  = maxWidth + 3.5 * plotLegend.textSize
        let legendHeight = (Float(labels.count)*2.0 + 1.0) * plotLegend.textSize
        
        let legendTopLeft = Point(results.plotBorderRect!.minX + Float(20),
                                  results.plotBorderRect!.maxY - Float(20))
        results.legendRect = Rect(
            origin: legendTopLeft,
            size: Size(width: legendWidth, height: -legendHeight)
        ).normalized
    }
    
    // Drawing.
    
    func drawBackground(results: Results, renderer: Renderer) {
        renderer.drawSolidRect(Rect(origin: zeroPoint, size: plotSize), fillColor: backgroundColor, hatchPattern: .none)
        if let plotBackgroundColor = plotBackgroundColor {
            renderer.drawSolidRect(results.plotBorderRect!, fillColor: plotBackgroundColor, hatchPattern: .none)
        }
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
        if let titleLocation = results.titleLocation {
            renderer.drawText(text: plotTitle.title,
                              location: titleLocation.origin,
                              textSize: plotTitle.size,
                              color: plotTitle.color,
                              strokeWidth: 1.2,
                              angle: 0)
        }
    }

    func drawLabels(results: Results, renderer: Renderer) {
        if let xLocation = results.xLabelLocation {
            renderer.drawText(text: plotLabel.xLabel,
                              location: xLocation.origin,
                              textSize: plotLabel.size,
                              color: plotLabel.color,
                              strokeWidth: 1.2,
                              angle: 0)
        }
        if let yLocation = results.yLabelLocation {
            renderer.drawText(text: plotLabel.yLabel,
                              location: yLocation.origin,
                              textSize: plotLabel.size,
                              color: plotLabel.color,
                              strokeWidth: 1.2,
                              angle: 90)
        }
        if let y2Location = results.y2LabelLocation {
            renderer.drawText(text: plotLabel.y2Label,
                              location: y2Location.origin,
                              textSize: plotLabel.size,
                              color: plotLabel.color,
                              strokeWidth: 1.2,
                              angle: 90)
        }
    }
    
    func drawBorder(results: Results, renderer: Renderer) {
        guard let borderRect = results.plotBorderRect else { return }
        renderer.drawRect(borderRect,
                          strokeWidth: plotBorder.thickness,
                          strokeColor: plotBorder.color)
    }
    
    func drawGrid(results: Results, renderer: Renderer) {
        guard enablePrimaryAxisGrid || enablePrimaryAxisGrid,
            let rect = results.plotBorderRect else { return }
        
        for index in 0..<results.plotMarkers.xMarkers.count {
            let p1 = Point(results.plotMarkers.xMarkers[index] + rect.minX, rect.minY)
            let p2 = Point(results.plotMarkers.xMarkers[index] + rect.minX, rect.maxY)
            renderer.drawLine(startPoint: p1,
                              endPoint: p2,
                              strokeWidth: grid.thickness,
                              strokeColor: grid.color,
                              isDashed: false)
        }
    
        if (enablePrimaryAxisGrid) {
            for index in 0..<results.plotMarkers.yMarkers.count {
                let p1 = Point(rect.minX, results.plotMarkers.yMarkers[index] + rect.minY)
                let p2 = Point(rect.maxX, results.plotMarkers.yMarkers[index] + rect.minY)
                renderer.drawLine(startPoint: p1,
                                  endPoint: p2,
                                  strokeWidth: grid.thickness,
                                  strokeColor: grid.color,
                                  isDashed: false)
            }
        }
        if (enableSecondaryAxisGrid) {
            for index in 0..<results.plotMarkers.y2Markers.count {
                let p1 = Point(rect.minX, results.plotMarkers.y2Markers[index] + rect.minY)
                let p2 = Point(rect.maxX, results.plotMarkers.y2Markers[index] + rect.minY)
                renderer.drawLine(startPoint: p1,
                                  endPoint: p2,
                                  strokeWidth: grid.thickness,
                                  strokeColor: grid.color,
                                  isDashed: false)
            }
        }
    }

    func drawMarkers(results: Results, renderer: Renderer) {
        guard let rect = results.plotBorderRect else { return }
        for index in 0..<results.plotMarkers.xMarkers.count {
            let p1 = Point(results.plotMarkers.xMarkers[index], -6) + rect.origin
            let p2 = Point(results.plotMarkers.xMarkers[index], 0) + rect.origin
            renderer.drawLine(startPoint: p1,
                              endPoint: p2,
                              strokeWidth: plotBorder.thickness,
                              strokeColor: plotBorder.color,
                              isDashed: false)
            renderer.drawText(text: results.plotMarkers.xMarkersText[index],
                              location: results.xMarkersTextLocation[index] + rect.origin,
                              textSize: markerTextSize,
                              color: plotBorder.color,
                              strokeWidth: 0.7,
                              angle: 0)
        }

        for index in 0..<results.plotMarkers.yMarkers.count {
            let p1 = Point(-6, results.plotMarkers.yMarkers[index]) + rect.origin
            let p2 = Point(0, results.plotMarkers.yMarkers[index]) + rect.origin
            renderer.drawLine(startPoint: p1,
                              endPoint: p2,
                              strokeWidth: plotBorder.thickness,
                              strokeColor: plotBorder.color,
                              isDashed: false)
            renderer.drawText(text: results.plotMarkers.yMarkersText[index],
                              location: results.yMarkersTextLocation[index]  + rect.origin,
                              textSize: markerTextSize,
                              color: plotBorder.color,
                              strokeWidth: 0.7,
                              angle: 0)
        }
        
        if !results.plotMarkers.y2Markers.isEmpty {
            for index in 0..<results.plotMarkers.y2Markers.count {
                let p1 = Point(results.plotBorderRect!.width,
                               (results.plotMarkers.y2Markers[index])) + rect.origin
                let p2 = Point(results.plotBorderRect!.width + 6,
                               (results.plotMarkers.y2Markers[index])) + rect.origin
                renderer.drawLine(startPoint: p1,
                                  endPoint: p2,
                                  strokeWidth: plotBorder.thickness,
                                  strokeColor: plotBorder.color,
                                  isDashed: false)
                renderer.drawText(text: results.plotMarkers.y2MarkersText[index],
                                  location: results.y2MarkersTextLocation[index]  + rect.origin,
                                  textSize: markerTextSize,
                                  color: plotBorder.color,
                                  strokeWidth: 0.7,
                                  angle: 0)
            }
        }
    }
    
    func drawLegend(_ entries: [(String, LegendIcon)], results: Results, renderer: Renderer) {
        
        guard let legendRect = results.legendRect else { return }
        renderer.drawSolidRectWithBorder(legendRect,
                                         strokeWidth: plotLegend.borderThickness,
                                         fillColor: plotLegend.backgroundColor,
                                         borderColor: plotLegend.borderColor)
        
        for i in 0..<entries.count {
            let seriesIcon = Rect(
                origin: Point(legendRect.origin.x + plotLegend.textSize,
                              legendRect.maxY - (2.0*Float(i) + 1.0)*plotLegend.textSize),
                size: Size(width: plotLegend.textSize, height: -plotLegend.textSize)
            )
            switch entries[i].1 {
            case .square(let color):
                renderer.drawSolidRect(seriesIcon,
                                       fillColor: color,
                                       hatchPattern: .none)
            case .shape(let shape, let color):
                shape.draw(in: seriesIcon,
                           color: color,
                           renderer: renderer)
            }
            let p = Point(seriesIcon.maxX + plotLegend.textSize, seriesIcon.minY)
            renderer.drawText(text: entries[i].0,
                              location: p,
                              textSize: plotLegend.textSize,
                              color: plotLegend.textColor,
                              strokeWidth: 1.2,
                              angle: 0)
        }
    }
}

public protocol HasGraphLayout: AnyObject {
    
    var layout: GraphLayout { get set }
    
    var legendLabels: [(String, LegendIcon)] { get }
    
    func calculateScaleAndMarkerLocations(markers: inout PlotMarkers, size: Size, renderer: Renderer)
    
    func drawData(markers: PlotMarkers, size: Size, renderer: Renderer)
}

extension HasGraphLayout {
    
    public var plotSize: Size {
        get { layout.plotSize }
        set { layout.plotSize = newValue }
    }
    
    public var plotTitle: PlotTitle {
        get { layout.plotTitle }
        set { layout.plotTitle = newValue }
    }
    public var plotLabel: PlotLabel {
        get { layout.plotLabel }
        set { layout.plotLabel = newValue }
    }
    public var plotLegend: PlotLegend {
        get { layout.plotLegend }
        set { layout.plotLegend = newValue }
    }
    public var plotBorder: PlotBorder {
        get { layout.plotBorder }
        set { layout.plotBorder = newValue }
    }
    public var grid: Grid {
        get { layout.grid }
        set { layout.grid = newValue }
    }
    public var backgroundColor: Color {
        get { layout.backgroundColor }
        set { layout.backgroundColor = newValue }
    }
    public var plotBackgroundColor: Color? {
        get { layout.plotBackgroundColor }
        set { layout.plotBackgroundColor = newValue }
    }

    public var markerTextSize: Float {
        get { layout.markerTextSize }
        set { layout.markerTextSize = newValue }
    }
}

extension Plot where Self: HasGraphLayout {
    
    public func drawGraph(renderer: Renderer) {
        layout.legendLabels = self.legendLabels
        let results = layout.layout(renderer: renderer, calculateMarkers: { markers, size in
            calculateScaleAndMarkerLocations(
                markers: &markers,
                size: size,
                renderer: renderer)
        })
        layout.drawBackground(results: results, renderer: renderer)
        renderer.withOffset(results.plotBorderRect!.origin) { renderer in
            drawData(markers: results.plotMarkers, size: results.plotBorderRect!.size, renderer: renderer)
        }
        layout.drawForeground(results: results, renderer: renderer)
    }
    
}

extension Renderer {
    func withOffset(_ offset: Point, _ perform: (Renderer)->Void) {
        let oldOffset = (self.xOffset, self.yOffset)
        (self.xOffset, self.yOffset) = (oldOffset.0 + offset.x, oldOffset.1 + offset.y)
        perform(self)
        (self.xOffset, self.yOffset) = oldOffset
    }
}
