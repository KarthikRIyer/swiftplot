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
        struct Sizes {
            var xLabelSize: Size?
            var yLabelSize: Size?
            var y2LabelSize: Size?
            var titleSize: Size?
        }
        
        var plotBorderRect: Rect
        var sizes: Sizes
        
        var xLabelLocation: Point?
        var yLabelLocation: Point?
        var y2LabelLocation: Point?
        var titleLocation: Point?
        
        var plotMarkers = PlotMarkers()
        var xMarkersTextLocation = [Point]()
        var yMarkersTextLocation = [Point]()
        var y2MarkersTextLocation = [Point]()
        
        var legendRect: Rect?
    }
    
    // Layout.
        
    func layout(renderer: Renderer, calculateMarkers: (inout PlotMarkers, Size)->Void) -> Results {
        // 1. Measure the things outside of the plot's border (axis titles, plot title)
        var sizes = Results.Sizes()
        measureLabels(renderer: renderer, results: &sizes)
        // 2. Calculate the plot's border
        let borderRect = calcBorder(sizes: sizes, renderer: renderer)
        // 3. Lay out the things outside of the plot's border (axis titles, plot title)
        var results = Results(plotBorderRect: borderRect, sizes: sizes)
        calcLabelLocations(&results)
        // 4. Let the plot calculate its scale, calculate marker positions.
        calculateMarkers(&results.plotMarkers, results.plotBorderRect.size)
        // 5. Lay out remaining chrome.
        calcMarkerTextLocations(renderer: renderer, results: &results)
        calcLegend(legendLabels, renderer: renderer, results: &results)
        return results
    }
    
    static let xLabelPadding: Float = 10
    static let yLabelPadding: Float = 10
    static let titleLabelPadding: Float = 14
    
    /// Measures the sizes of chrome elements outside the plot's borders (axis titles, plot title, etc).
    func measureLabels(renderer: Renderer, results: inout Results.Sizes) {
        if !plotLabel.xLabel.isEmpty {
            results.xLabelSize = renderer.getTextLayoutSize(text: plotLabel.xLabel, textSize: plotLabel.size)
        }
        if !plotLabel.yLabel.isEmpty {
            results.yLabelSize = renderer.getTextLayoutSize(text: plotLabel.yLabel, textSize: plotLabel.size)
        }
        if !plotLabel.y2Label.isEmpty {
            results.y2LabelSize = renderer.getTextLayoutSize(text: plotLabel.y2Label, textSize: plotLabel.size)
        }
        if !plotTitle.title.isEmpty {
            results.titleSize = renderer.getTextLayoutSize(text: plotTitle.title, textSize: plotTitle.size)
        }
    }
    
    /// Calculates the region of the plot which is used for displaying the plot's data (inside all of the chrome).
    func calcBorder(sizes: Results.Sizes, renderer: Renderer) -> Rect {
        var borderRect = Rect(
            origin: zeroPoint,
            size: self.plotSize
        )
        if let xLabel = sizes.xLabelSize {
            borderRect.clampingShift(dy: xLabel.height + 2 * Self.xLabelPadding)
        }
        if let yLabel = sizes.yLabelSize {
            borderRect.clampingShift(dx: yLabel.height + 2 * Self.yLabelPadding)
        }
        if let y2Label = sizes.y2LabelSize {
            borderRect.size.width -= (y2Label.height + 2 * Self.yLabelPadding)
        }
        if let titleLabel = sizes.titleSize {
            borderRect.size.height -= (titleLabel.height + 2 * Self.titleLabelPadding)
        }
        borderRect.contract(by: plotBorder.thickness)
        // Give space for the markers.
        borderRect.clampingShift(dy: (2 * markerTextSize) + 10) // X markers
        // TODO: Better space calculation for Y/Y2 markers.
        borderRect.clampingShift(dx: yMarkerMaxWidth + 10) // Y markers
        borderRect.size.width -= yMarkerMaxWidth + 10 // Y2 markers

        return borderRect
    }
    
    /// Lays out the chrome elements outside the plot's borders (axis titles, plot title, etc).
    func calcLabelLocations(_ results: inout Results) {
        if let xLabelSize = results.sizes.xLabelSize {
            results.xLabelLocation = Point(results.plotBorderRect.midX - xLabelSize.width/2,
                                           Self.xLabelPadding)
        }
        if let titleLabelSize = results.sizes.titleSize {
            results.titleLocation = Point(results.plotBorderRect.midX - titleLabelSize.width/2,
                                          plotSize.height  - titleLabelSize.height - Self.titleLabelPadding)
        }
        if let yLabelSize = results.sizes.yLabelSize {
            results.yLabelLocation = Point(Self.yLabelPadding + yLabelSize.height,
                                           results.plotBorderRect.midY - yLabelSize.width/2)
        }
        if let y2LabelSize = results.sizes.y2LabelSize {
            results.y2LabelLocation = Point(plotSize.width - Self.yLabelPadding,
                                            results.plotBorderRect.midY - y2LabelSize.width/2)
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
            let text_p = Point(results.plotBorderRect.width + 8, results.plotMarkers.y2Markers[i] - 4)
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
        
        let legendTopLeft = Point(results.plotBorderRect.minX + Float(20),
                                  results.plotBorderRect.maxY - Float(20))
        results.legendRect = Rect(
            origin: legendTopLeft,
            size: Size(width: legendWidth, height: -legendHeight)
        ).normalized
    }
    
    // Drawing.
    
    func drawBackground(results: Results, renderer: Renderer) {
        renderer.drawSolidRect(Rect(origin: zeroPoint, size: plotSize), fillColor: backgroundColor, hatchPattern: .none)
        if let plotBackgroundColor = plotBackgroundColor {
            renderer.drawSolidRect(results.plotBorderRect, fillColor: plotBackgroundColor, hatchPattern: .none)
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
                              location: titleLocation,
                              textSize: plotTitle.size,
                              color: plotTitle.color,
                              strokeWidth: 1.2,
                              angle: 0)
        }
    }

    func drawLabels(results: Results, renderer: Renderer) {
        if let xLocation = results.xLabelLocation {
            renderer.drawText(text: plotLabel.xLabel,
                              location: xLocation,
                              textSize: plotLabel.size,
                              color: plotLabel.color,
                              strokeWidth: 1.2,
                              angle: 0)
        }
        if let yLocation = results.yLabelLocation {
            renderer.drawText(text: plotLabel.yLabel,
                              location: yLocation,
                              textSize: plotLabel.size,
                              color: plotLabel.color,
                              strokeWidth: 1.2,
                              angle: 90)
        }
        if let y2Location = results.y2LabelLocation {
            renderer.drawText(text: plotLabel.y2Label,
                              location: y2Location,
                              textSize: plotLabel.size,
                              color: plotLabel.color,
                              strokeWidth: 1.2,
                              angle: 90)
        }
    }
    
    func drawBorder(results: Results, renderer: Renderer) {
        renderer.drawRect(results.plotBorderRect,
                          strokeWidth: plotBorder.thickness,
                          strokeColor: plotBorder.color)
    }
    
    func drawGrid(results: Results, renderer: Renderer) {
        guard enablePrimaryAxisGrid || enablePrimaryAxisGrid else { return }
        let rect = results.plotBorderRect
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
        let rect = results.plotBorderRect
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
                let p1 = Point(results.plotBorderRect.width,
                               (results.plotMarkers.y2Markers[index])) + rect.origin
                let p2 = Point(results.plotBorderRect.width + 6,
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
        renderer.withAdditionalOffset(results.plotBorderRect.origin) { renderer in
            drawData(markers: results.plotMarkers, size: results.plotBorderRect.size, renderer: renderer)
        }
        layout.drawForeground(results: results, renderer: renderer)
    }
    
}
