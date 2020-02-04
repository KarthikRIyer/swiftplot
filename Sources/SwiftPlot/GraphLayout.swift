import Foundation

public enum LegendIcon {
    case square(Color)
    case shape(ScatterPlotSeriesOptions.ScatterPattern, Color)
}

/// A component for laying-out and rendering rectangular graphs.
///
/// The principle 3 components of a `GraphLayout` are:
/// - The rectangular plot area itself,
/// - Any `LayoutComponent`s that surround the plot and take up space (e.g. the title, axis markers and labels), and
/// - Any `Annotation`s that are layered on top of the plot and do not take up space in a layout sense (e.g. arrows, watermarks).
///
public struct GraphLayout {
    // Inputs.
    var backgroundColor: Color = .white
    var plotBackgroundColor: Color?
    var plotTitle = PlotTitle()
    var plotLabel  = PlotLabel()
    var plotLegend = PlotLegend()
    var plotBorder = PlotBorder()
    var grid = Grid()
    var annotations: [Annotation] = []
  
    var enablePrimaryAxisGrid = true
    var enableSecondaryAxisGrid = true
    var drawsGridOverForeground = false
    var markerTextSize: Float = 12
    var markerThickness: Float = 2
    /// The amount of (horizontal) space to reserve for markers on the Y-axis.
    var yMarkerMaxWidth: Float = 40
  
  enum MarkerLabelAlignment {
    case atMarker
    case betweenMarkers
  }
  var markerLabelAlignment = MarkerLabelAlignment.atMarker
    
    struct LayoutPlan : CoordinateResolver {
        /// The size these results have been calculated for; the entire size of the plot.
        let totalSize: Size
        
        /// The region of the plot which will actually be filled with chart data.
        let plotBorderRect: Rect
        
        /// All of the `LayoutComponent`s on this graph, including built-in components.
        let allComponents: EdgeComponents<[LayoutComponent]>
        
        /// The measured sizes of the plot elements.
        let sizes: EdgeComponents<[Size]>
        
        let plotMarkers: PlotMarkers
        let legendLabels: [(String, LegendIcon)]
        
        var xMarkersTextLocation = [Point]()
        var yMarkersTextLocation = [Point]()
        var y2MarkersTextLocation = [Point]()
        var legendRect: Rect?

        func resolve(_ coordinate: Coordinate) -> Point {
            let x = coordinate.point.x
            let y = coordinate.point.y
            switch(coordinate.coordinateSpace) {
                case .figurePoints:
                    return Point(x, y)
                case .axesPoints:
                    return Point(x, y) + plotBorderRect.origin
                case .figureFraction:
                    let maxX = plotBorderRect.origin.x + plotBorderRect.size.width
                    let maxY = plotBorderRect.origin.y + plotBorderRect.size.height
                    return Point(x * maxX, y * maxY)
                case .axesFraction:
                    let maxX = plotBorderRect.size.width
                    let maxY =  plotBorderRect.size.height
                    return Point(x * maxX, y * maxY) + plotBorderRect.origin
            }
        }
    }
}

// Layout.

extension GraphLayout {
    
    func layout<T>(size: Size, renderer: Renderer,
                   layoutContent: (Size)->(T, PlotMarkers?, [(String, LegendIcon)]?) ) -> (T, LayoutPlan) {
        
        // 1. Calculate the plot size. To do that, we first have measure everything outside of the plot.
        let components = makeLayoutComponents()
        let sizes = components.mapByEdge { edge, edgeComponents -> [Size] in
            return edgeComponents.map { $0.measure(edge: edge, renderer) }
        }
        var plotSize = calcPlotSize(totalSize: size, componentSizes: sizes)
        
        // 2. Call back to the plot to lay out its data. It may ask to adjust the plot size.
        let (drawingData, markers, legendInfo) = layoutContent(plotSize)
        (drawingData as? AdjustsPlotSize).map { plotSize = adjustPlotSize(plotSize, info: $0) }
        
        // 3. Now that we have the final sizes of everything, we can calculate their locations.
        let plotRect = layoutPlotRect(plotSize: plotSize, componentSizes: sizes)
        
        var plan = LayoutPlan(totalSize: size,
                              plotBorderRect: plotRect,
                              allComponents: components,
                              sizes: sizes,
                              plotMarkers: markers ?? PlotMarkers(),
                              legendLabels: legendInfo ?? [])
        calcMarkerTextLocations(renderer: renderer, plan: &plan)
        calcLegend(plan.legendLabels, renderer: renderer, plan: &plan)
        return (drawingData, plan)
    }
    
    static let xLabelPadding: Float = 12
    static let yLabelPadding: Float = 12
    static let titleLabelPadding: Float = 16
    
    static let markerStemLength: Float = 6
    /// Padding around y marker-labels.
    static let yMarkerSpace: Float = 4
    /// Padding around x marker-labels.
    static let xMarkerSpace: Float = 6
    
    // FIXME: To be removed. These items should already be `LayoutComponent`s.
    private func makeLayoutComponents() -> EdgeComponents<[LayoutComponent]> {
        var elements = EdgeComponents<[LayoutComponent]>(left: [], top: [], right: [], bottom: [])
        if !plotLabel.xLabel.isEmpty {
            let label = Label(text: plotLabel.xLabel, size: plotLabel.size)
                          .padding(.all(Self.xLabelPadding))
            elements.bottom.append(label)
            // Add a space, otherwise the label looks misaligned.
            elements.bottom.append(FixedSpace(size: Self.xLabelPadding/2))
        } else {
            elements.bottom.append(FixedSpace(size: Self.xLabelPadding))
        }
        if !plotLabel.yLabel.isEmpty {
            let label = Label(text: plotLabel.yLabel, size: plotLabel.size)
                          .padding(.all(Self.yLabelPadding))
            elements.left.append(label)
        }
        if !plotLabel.y2Label.isEmpty {
            let label = Label(text: plotLabel.y2Label, size: plotLabel.size)
                          .padding(.all(Self.yLabelPadding))
            elements.right.append(label)
        }
        if !plotTitle.title.isEmpty {
            let label = Label(text: plotTitle.title, size: plotTitle.size)
                          .padding(.all(Self.titleLabelPadding))
            elements.top.append(label)
        } else {
            elements.top.append(FixedSpace(size: Self.titleLabelPadding))
        }
        return elements
    }
    
    /// Calculates the region of the plot which is used for displaying the plot's data (inside all of the chrome).
    private func calcPlotSize(totalSize: Size, componentSizes: EdgeComponents<[Size]>) -> Size {
        var plotSize = totalSize
        
        // Subtract space for the LayoutComponents.
        componentSizes.left.forEach  { plotSize.width -= $0.width }
        componentSizes.right.forEach { plotSize.width -= $0.width }
        componentSizes.top.forEach    { plotSize.height -= $0.height }
        componentSizes.bottom.forEach { plotSize.height -= $0.height }
        
        // Subtract space for the markers.
        // TODO: Make this more accurate.
        plotSize.height -= (Self.markerStemLength + (2 * Self.xMarkerSpace) + markerTextSize) // X markers
        plotSize.width -= (Self.markerStemLength + (2 * Self.yMarkerSpace) + yMarkerMaxWidth) // Y markers
        plotSize.width -= (Self.markerStemLength + (2 * Self.yMarkerSpace) + yMarkerMaxWidth) // Y2 markers
        // Subtract space for border thickness.
        plotSize.height -= 2 * plotBorder.thickness
        plotSize.width  -= 2 * plotBorder.thickness
        
        // Sanitize the resulting rectangle.
        plotSize.height = max(plotSize.height, 0)
        plotSize.width = max(plotSize.width, 0)
        plotSize.height.round(.down)
        plotSize.width.round(.down)
        
        return plotSize
    }
  
    private func layoutPlotRect(plotSize: Size, componentSizes: EdgeComponents<[Size]>) -> Rect {
        // 1. Calculate the plotBorderRect.
        // We already have the size, so we only need to calculate the origin.
        var plotOrigin = Point.zero
        
        // Offset by the left/bottom PlotElements.
        plotOrigin.x += componentSizes.left.reduce(into: 0) { $0 += $1.width }
        plotOrigin.y += componentSizes.bottom.reduce(into: 0) { $0 += $1.height }
        // Offset by marker sizes (TODO: they are not PlotElements yet, so not handled above).
        let xMarkerHeight = (Self.markerStemLength + (2 * Self.xMarkerSpace) + markerTextSize) // X markers
        let yMarkerWidth  = (Self.markerStemLength + (2 * Self.yMarkerSpace) + yMarkerMaxWidth)      // Y markers
        plotOrigin.y += xMarkerHeight
        plotOrigin.x += yMarkerWidth
        // Offset by plot thickness.
        plotOrigin.x += plotBorder.thickness
        plotOrigin.y += plotBorder.thickness
        
        // These are the final coordinates of the plot's internal space, so update `results`.
        return Rect(origin: plotOrigin, size: plotSize).roundedInwards
    }
    
    /// Makes adjustments to the layout as requested by the plot.
    private func adjustPlotSize(_ plotSize: Size, info: AdjustsPlotSize) -> Size {
        if info.desiredPlotSize != .zero {
            // Validate the requested size.
            guard info.desiredPlotSize.height <= plotSize.height,
                info.desiredPlotSize.width <= plotSize.width else {
                    print("Size requested by plot is too large. Cannot fulfill: \(info.desiredPlotSize)")
                    return plotSize
            }
            return info.desiredPlotSize
        }
        return plotSize
    }
    
    private func calcMarkerTextLocations(renderer: Renderer, plan: inout LayoutPlan) {
        let xLabelOffset = plotBorder.thickness + Self.markerStemLength + Self.xMarkerSpace
        let yLabelOffset = plotBorder.thickness + Self.markerStemLength + Self.yMarkerSpace
        for i in 0..<plan.plotMarkers.xMarkers.count {
            let textSize = renderer.getTextLayoutSize(text: plan.plotMarkers.xMarkersText[i], textSize: markerTextSize)
            let markerLocation = plan.plotMarkers.xMarkers[i]
            var textLocation   = Point(0, -xLabelOffset - textSize.height)
            switch markerLabelAlignment {
            case .atMarker:
                textLocation.x = markerLocation - (textSize.width/2)
            case .betweenMarkers:
              let nextMarkerLocation: Float
              if i < plan.plotMarkers.xMarkers.endIndex - 1 {
                nextMarkerLocation = plan.plotMarkers.xMarkers[i + 1]
              } else {
                nextMarkerLocation = plan.plotBorderRect.width
              }
              let midpoint = markerLocation + (nextMarkerLocation - markerLocation)/2
              textLocation.x = midpoint - (textSize.width/2)
            }
            plan.xMarkersTextLocation.append(textLocation)
        }
      
        /// Vertically aligns the label and returns the optimal Y coordinate to draw at.
        func alignYLabel(markers: [Float], index: Int, textSize: Size) -> Float {
          let markerLocation = markers[index]
          switch markerLabelAlignment {
          case .atMarker:
            return markerLocation - (textSize.height/2)
          case .betweenMarkers:
            let nextMarkerLocation: Float
            if index < markers.endIndex - 1 {
              nextMarkerLocation = markers[index + 1]
            } else {
              nextMarkerLocation = plan.plotBorderRect.height
            }
            let midpoint = markerLocation + (nextMarkerLocation - markerLocation)/2
            return midpoint - (textSize.height/2)
          }
        }
      
        for i in 0..<plan.plotMarkers.yMarkers.count {
            var textSize = renderer.getTextLayoutSize(text: plan.plotMarkers.yMarkersText[i],
                                                      textSize: markerTextSize)
            textSize.width = min(textSize.width, yMarkerMaxWidth)
            var textLocation = Point(-yLabelOffset - textSize.width, 0)
            textLocation.y = alignYLabel(markers: plan.plotMarkers.yMarkers, index: i, textSize: textSize)
            plan.yMarkersTextLocation.append(textLocation)
        }
        
        for i in 0..<plan.plotMarkers.y2Markers.count {
            var textSize = renderer.getTextLayoutSize(text: plan.plotMarkers.y2MarkersText[i],
                                                      textSize: markerTextSize)
            textSize.width = min(textSize.width, yMarkerMaxWidth)
            var textLocation = Point(yLabelOffset + plan.plotBorderRect.width, 0)
            textLocation.y = alignYLabel(markers: plan.plotMarkers.y2Markers, index: i, textSize: textSize)
            plan.y2MarkersTextLocation.append(textLocation)
        }
    }
    
    private func calcLegend(_ labels: [(String, LegendIcon)], renderer: Renderer, plan: inout LayoutPlan) {
        guard !labels.isEmpty else { return }
        let maxWidth = labels.lazy.map {
            renderer.getTextWidth(text: $0.0, textSize: self.plotLegend.textSize)
        }.max() ?? 0
        
        let legendWidth  = maxWidth + 3.5 * plotLegend.textSize
        let legendHeight = (Float(labels.count)*2.0 + 1.0) * plotLegend.textSize
        
        let legendTopLeft = Point(plan.plotBorderRect.minX + Float(20),
                                  plan.plotBorderRect.maxY - Float(20))
        plan.legendRect = Rect(
            origin: legendTopLeft,
            size: Size(width: legendWidth, height: -legendHeight)
        ).normalized
    }
}

// Drawing.
fileprivate var debuggingEnabled = false
extension Renderer {
    var debug: Renderer? {
        guard debuggingEnabled else { _onFastPath(); return nil }
        return self
    }
}

extension GraphLayout {
    
    fileprivate func drawBackground(_ plan: LayoutPlan, renderer: Renderer) {
        renderer.drawSolidRect(Rect(origin: .zero, size: plan.totalSize),
                               fillColor: backgroundColor, hatchPattern: .none)
        if let plotBackgroundColor = plotBackgroundColor {
            renderer.drawSolidRect(plan.plotBorderRect, fillColor: plotBackgroundColor, hatchPattern: .none)
        }
        if !drawsGridOverForeground {
          drawGrid(plan, renderer: renderer)
        }
        drawBorder(plan, renderer: renderer)
        drawMarkers(plan, renderer: renderer)
    }
    
    fileprivate func drawForeground(_ plan: LayoutPlan, renderer: Renderer) {
        if drawsGridOverForeground {
          drawGrid(plan, renderer: renderer)
        }
        drawLayoutComponents(plan.allComponents, plotRect: plan.plotBorderRect,
                             measuredSizes: plan.sizes, renderer: renderer)
        drawLegend(plan.legendLabels, plan: plan, renderer: renderer)
        drawAnnotations(resolver: plan, renderer: renderer)
    }
    
    private func drawLayoutComponents(_ components: EdgeComponents<[LayoutComponent]>, plotRect: Rect,
                                      measuredSizes: EdgeComponents<[Size]>, renderer: Renderer) {
        
        var plotExternalRect = plotRect
        plotExternalRect.contract(by: -1 * plotBorder.thickness)
        
        let xMarkerHeight = (2 * markerTextSize) + 10 // X markers
        let yMarkerWidth  = yMarkerMaxWidth + 10      // Y markers
        
        // Elements are laid out so that [0] is closest to the plot.
        // Top components.
        var t_height: Float = 0
        for (item, idx) in zip(components.top, components.top.indices) {
            let itemSize = measuredSizes.top[idx]
            let rect = Rect(origin: Point(plotExternalRect.minX, plotExternalRect.maxY + t_height),
                            size: Size(width: plotExternalRect.width, height: itemSize.height))
            t_height += itemSize.height
            renderer.debug?.drawSolidRect(rect, fillColor: Color.random().withAlpha(1), hatchPattern: .none)
            item.draw(rect, measuredSize: itemSize, edge: .top, renderer: renderer)
        }
        // Bottom components.
        var b_height: Float = xMarkerHeight
        for (item, idx) in zip(components.bottom, components.bottom.indices) {
            let itemSize = measuredSizes.bottom[idx]
            let rect = Rect(origin: Point(plotExternalRect.minX, plotExternalRect.minY - b_height - itemSize.height),
                            size: Size(width: plotExternalRect.width, height: itemSize.height))
            b_height += itemSize.height
            renderer.debug?.drawSolidRect(rect, fillColor: Color.random().withAlpha(1), hatchPattern: .none)
            item.draw(rect, measuredSize: itemSize, edge: .bottom, renderer: renderer)
        }
        // Right components.
        var r_width: Float = yMarkerWidth //results.plotMarkers.y2Markers.isEmpty ? 0 : yMarkerWidth
        for (item, idx) in zip(components.right, components.right.indices) {
            let itemSize = measuredSizes.right[idx]
            let rect = Rect(origin: Point(plotExternalRect.maxX + r_width, plotExternalRect.minY),
                            size: Size(width: itemSize.width, height: plotExternalRect.height))
            r_width += itemSize.width
            renderer.debug?.drawSolidRect(rect, fillColor: Color.random().withAlpha(1), hatchPattern: .none)
            item.draw(rect, measuredSize: itemSize, edge: .right, renderer: renderer)
        }
        // Left components.
        var l_width: Float = yMarkerWidth
        for (item, idx) in zip(components.left, components.left.indices) {
            let itemSize = measuredSizes.left[idx]
            let rect = Rect(origin: Point(plotExternalRect.minX - l_width - itemSize.width, plotExternalRect.minY),
                            size: Size(width: itemSize.width, height: plotExternalRect.height))
            l_width += itemSize.width
            renderer.debug?.drawSolidRect(rect, fillColor: Color.random().withAlpha(1), hatchPattern: .none)
            item.draw(rect, measuredSize: itemSize, edge: .left, renderer: renderer)
        }
    }
    
    private func drawBorder(_ plan: LayoutPlan, renderer: Renderer) {
      // The border should be drawn on the _outside_ of `plotBorderRect`.
        var rect = plan.plotBorderRect
        rect.contract(by: -plotBorder.thickness/2)
        renderer.drawRect(rect,
                          strokeWidth: plotBorder.thickness,
                          strokeColor: plotBorder.color)
    }
    
    private func drawGrid(_ plan: LayoutPlan, renderer: Renderer) {
        guard enablePrimaryAxisGrid || enablePrimaryAxisGrid else { return }
        let rect = plan.plotBorderRect
        for index in 0..<plan.plotMarkers.xMarkers.count {
          let p1 = Point(plan.plotMarkers.xMarkers[index] + rect.minX, rect.minY)
          let p2 = Point(plan.plotMarkers.xMarkers[index] + rect.minX, rect.maxY)
          guard rect.internalXCoordinates.contains(p1.x),
                rect.internalXCoordinates.contains(p2.x) else { continue }
          renderer.drawLine(startPoint: p1,
                            endPoint: p2,
                            strokeWidth: grid.thickness,
                            strokeColor: grid.color,
                            isDashed: false)
        }
    
        if (enablePrimaryAxisGrid) {
            for index in 0..<plan.plotMarkers.yMarkers.count {
              let p1 = Point(rect.minX, plan.plotMarkers.yMarkers[index] + rect.minY)
              let p2 = Point(rect.maxX, plan.plotMarkers.yMarkers[index] + rect.minY)
              guard rect.internalYCoordinates.contains(p1.y),
                    rect.internalYCoordinates.contains(p2.y) else { continue }
              renderer.drawLine(startPoint: p1,
                                endPoint: p2,
                                strokeWidth: grid.thickness,
                                strokeColor: grid.color,
                                isDashed: false)
            }
        }
        if (enableSecondaryAxisGrid) {
            for index in 0..<plan.plotMarkers.y2Markers.count {
              let p1 = Point(rect.minX, plan.plotMarkers.y2Markers[index] + rect.minY)
              let p2 = Point(rect.maxX, plan.plotMarkers.y2Markers[index] + rect.minY)
              guard rect.internalYCoordinates.contains(p1.y),
                    rect.internalYCoordinates.contains(p2.y) else { continue }
              renderer.drawLine(startPoint: p1,
                                endPoint: p2,
                                strokeWidth: grid.thickness,
                                strokeColor: grid.color,
                                isDashed: false)
            }
        }
    }

    private func drawMarkers(_ plan: LayoutPlan, renderer: Renderer) {
        let rect = plan.plotBorderRect
        let border = plotBorder.thickness
        for index in 0..<plan.plotMarkers.xMarkers.count {
            // Draw stem.
            let p1 = Point(plan.plotMarkers.xMarkers[index], -border) + rect.origin
            let p2 = Point(plan.plotMarkers.xMarkers[index], -border - Self.markerStemLength) + rect.origin
            renderer.drawLine(startPoint: p1,
                              endPoint: p2,
                              strokeWidth: markerThickness,
                              strokeColor: plotBorder.color,
                              isDashed: false)
            renderer.drawText(text: plan.plotMarkers.xMarkersText[index],
                              location: plan.xMarkersTextLocation[index] + rect.origin,
                              textSize: markerTextSize,
                              color: plotBorder.color,
                              strokeWidth: 0.7,
                              angle: 0)
        }

        for index in 0..<plan.plotMarkers.yMarkers.count {
            let p1 = Point(-border - Self.markerStemLength, plan.plotMarkers.yMarkers[index]) + rect.origin
            let p2 = Point(-border, plan.plotMarkers.yMarkers[index]) + rect.origin
            renderer.drawLine(startPoint: p1,
                              endPoint: p2,
                              strokeWidth: markerThickness,
                              strokeColor: plotBorder.color,
                              isDashed: false)
            renderer.drawText(text: plan.plotMarkers.yMarkersText[index],
                              location: plan.yMarkersTextLocation[index] + rect.origin,
                              textSize: markerTextSize,
                              color: plotBorder.color,
                              strokeWidth: 0.7,
                              angle: 0)
        }
        
        if !plan.plotMarkers.y2Markers.isEmpty {
            for index in 0..<plan.plotMarkers.y2Markers.count {
                let p1 = Point(rect.width + border, plan.plotMarkers.y2Markers[index]) + rect.origin
                let p2 = Point(rect.width + border + Self.markerStemLength, plan.plotMarkers.y2Markers[index]) + rect.origin
                renderer.drawLine(startPoint: p1,
                                  endPoint: p2,
                                  strokeWidth: markerThickness,
                                  strokeColor: plotBorder.color,
                                  isDashed: false)
                renderer.drawText(text: plan.plotMarkers.y2MarkersText[index],
                                  location: plan.y2MarkersTextLocation[index]  + rect.origin,
                                  textSize: markerTextSize,
                                  color: plotBorder.color,
                                  strokeWidth: 0.7,
                                  angle: 0)
            }
        }
    }
    
    private func drawLegend(_ entries: [(String, LegendIcon)], plan: LayoutPlan, renderer: Renderer) {
        
        guard let legendRect = plan.legendRect else { return }
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

    private func drawAnnotations(resolver: CoordinateResolver, renderer: Renderer) {
        for var annotation in annotations{
            annotation.draw(resolver: resolver, renderer: renderer)
        }
    }
}

protocol AdjustsPlotSize {
  var desiredPlotSize: Size { get }
}
public protocol HasGraphLayout {
    
    var layout: GraphLayout { get set }
    
    // Optional graph features (have default implementations).
    
    var legendLabels: [(String, LegendIcon)] { get }
    
    // Layout and drawing callbacks.
    
    /// The information this graph needs to draw - for example: scaled locations for data points.
    associatedtype DrawingData
    
    /// Lays out the chart's data within the rect `{ x: (0...size.width), y: (0...size.height) }`
    /// and produces a set of instructions for drawing by the `drawData` function, and optionally
    /// a set of axis markers for the `GraphLayout` to draw.
    /// - parameters:
    ///     - size: The size which the chart has to present its data.
    ///     - renderer: The renderer which will draw the chart. Useful for text-size calculations.
    /// - returns: A tuple containing data to be drawn and any axis markers the chart desires.
    func layoutData(size: Size, renderer: Renderer) -> (DrawingData, PlotMarkers?)
    
    /// Draws the data calculated by this chart's layout phase in the given renderer.
    /// - parameters:
    ///     - data: The data produced by this chart's `layoutData` method.
    ///     - size: The size which the chart has to present its data. The same size as was used to calculate `data`.
    ///             The chart must only draw within the rect `{ x: (0...size.width), y: (0...size.height) }`.
    ///     - renderer: The renderer in which to draw.
    func drawData(_ data: DrawingData, size: Size, renderer: Renderer)
}

extension HasGraphLayout {
    
    // Default implementation.
    public var legendLabels: [(String, LegendIcon)] {
        return []
    } 
    public var annotations: [Annotation] {
        get { layout.annotations }
        set { layout.annotations = newValue }
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
  
    public var markerThickness: Float {
      get { layout.markerThickness }
      set { layout.markerThickness = newValue }
    }
}

extension Plot where Self: HasGraphLayout {
    
    public func drawGraph(size: Size, renderer: Renderer) {
        let (drawingData, plan) = layout.layout(size: size, renderer: renderer) {
            size -> (DrawingData, PlotMarkers?, [(String, LegendIcon)]?) in
            let tup = layoutData(size: size, renderer: renderer)
            return (tup.0, tup.1, self.legendLabels)
        }
        layout.drawBackground(plan, renderer: renderer)
        renderer.withAdditionalOffset(plan.plotBorderRect.origin) { renderer in
            drawData(drawingData, size: plan.plotBorderRect.size, renderer: renderer)
        }
        layout.drawForeground(plan, renderer: renderer)
    }

    public mutating func addAnnotation(annotation: Annotation) {
        layout.annotations.append(annotation)
    }
}
