import Foundation

public enum LegendIcon {
    case square(Color)
    case shape(ScatterPlotSeriesOptions.ScatterPattern, Color)
}

public protocol PlotElement {
  func measure(_ renderer: Renderer) -> Size
  func draw(_ rect: Rect, renderer: Renderer)
}
struct PaddedPlotElement<T: PlotElement>: PlotElement {
    var base: T
    var padding: EdgeComponents<Float> = .zero
    func measure(_ renderer: Renderer) -> Size {
        var size = base.measure(renderer)
        size.width += padding.left + padding.right
        size.height += padding.top + padding.bottom
        return size
    }
    func draw(_ rect: Rect, renderer: Renderer) {
        base.draw(rect.inset(by: padding), renderer: renderer)
    }
}
extension PlotElement {
    func withPadding(_ padding: EdgeComponents<Float>) -> PlotElement {
    	return PaddedPlotElement(base: self, padding: padding)
    }
}

public struct Label: PlotElement {
  var text: String = ""
  var size: Float  = 12
  var color: Color = .black
    
  public func measure(_ renderer: Renderer) -> Size {
    return renderer.getTextLayoutSize(text: text, textSize: size)
  }
  public func draw(_ rect: Rect, renderer: Renderer) {
    renderer.drawText(text: text,
                      location: rect.origin,
                      textSize: size,
                      color: color,
                      strokeWidth: 1.2,
                      angle: 0) // TODO: 90 for vertical text.
  }
}

public struct EdgeComponents<T> {
    public var left: T
    public var top: T
    public var right: T
    public var bottom: T
    
    static func all(_ value: T) -> EdgeComponents<T> {
        EdgeComponents(left: value, top: value, right: value, bottom: value)
    }
    
    public func map<U>(_ block: (T) throws -> U) rethrows -> EdgeComponents<U> {
        EdgeComponents<U>(left: try block(left), top: try block(top),
                          right: try block(right), bottom: try block(bottom))
    }
}
extension EdgeComponents where T: ExpressibleByIntegerLiteral {
    static var zero: Self { .all(0) }
}
extension EdgeComponents where T: RangeReplaceableCollection {
    static var empty: Self {
        EdgeComponents(left: .init(), top: .init(), right: .init(), bottom: .init())
    }
    mutating func append<S>(contentsOf other: EdgeComponents<S>) where S: Sequence, S.Element == T.Element {
        left.append(contentsOf: other.left)
        top.append(contentsOf: other.top)
        right.append(contentsOf: other.right)
        bottom.append(contentsOf: other.bottom)
    }
}
extension Rect {
    func inset(by insets: EdgeComponents<Float>) -> Rect {
        var rect = self
        rect.height -= insets.top + insets.bottom
        rect.width  -= insets.left + insets.right
        rect.origin.x += insets.left
        rect.origin.y += insets.bottom
        return rect
    }
}


/// A component for laying-out and rendering rectangular graphs.
///
/// The principle 3 components of a `GraphLayout` are:
/// - The rectangular plot area itself,
/// - Any `PlotElement`s that surround the plot and take up space (e.g. the title, axis markers and labels), and
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
    
    struct Results : CoordinateResolver {
        /// The size these results have been calculated for; the entire size of the plot.
        let totalSize: Size
        
        /// The region of the plot which will actually be filled with chart data.
        var plotBorderRect: Rect
        
        var elements: EdgeComponents<[PlotElement]>
        /// The sizes of various labels outside the chart area.
        /// These must be measured _before_ the `plotBorderRect` can be calculated.
        var sizes: EdgeComponents<[Size]>
        var rects: EdgeComponents<[Rect]>
        
        var plotMarkers = PlotMarkers()
        var xMarkersTextLocation = [Point]()
        var yMarkersTextLocation = [Point]()
        var y2MarkersTextLocation = [Point]()
        
        var legendLabels: [(String, LegendIcon)] = []
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
    
    // TODO: refactor "calculateMarkers":
    // - Should be called "layoutContent" or something like that.
    // - PlotMarkers return value should be an array of `PlotElement`s.
    // - Legend info should be handled by an annotation.
    // - Possibly wrap T inside `Results` (as a generic parameter).
    // - Rename `Results` to `LayoutPlan` or something like that.
    
    func layout<T>(size: Size, renderer: Renderer,
                   calculateMarkers: (Size)->(T, PlotMarkers?, [(String, LegendIcon)]?) ) -> (T, Results) {
        
        // 1. Calculate the plot size. To do that, we first have measure everything outside of the plot.
        let elements = makePlotElements()
        let sizes = elements.map { edgeElements in edgeElements.map { $0.measure(renderer) } }
        var plotSize = calcPlotSize(totalSize: size, plotElements: sizes)
        
        // 2. Call back to the plot to lay out its data. It may ask to adjust the plot size.
        let (drawingData, markers, legendInfo) = calculateMarkers(plotSize)
        (drawingData as? AdjustsPlotSize).map { plotSize = adjustPlotSize(plotSize, info: $0) }
        
        // 3. Now that we have the final sizes of everything, we can calculate their locations.
        var results = Results(totalSize: size, plotBorderRect: Rect(origin: .zero, size: plotSize),
                              elements: elements, sizes: sizes, rects: .empty)
        markers.map {
            var markers = $0
            roundMarkers(&markers)
            results.plotMarkers = markers
        }
        legendInfo.map { results.legendLabels = $0 }
        
        layoutObjects(renderer, &results)
        calcMarkerTextLocations(renderer: renderer, results: &results)
        calcLegend(results.legendLabels, renderer: renderer, results: &results)
        return (drawingData, results)
    }
    
    static let xLabelPadding: Float = 10
    static let yLabelPadding: Float = 10
    static let titleLabelPadding: Float = 14
    
    // FIXME: To be removed. These items should already be PlotElements.
    private func makePlotElements() -> EdgeComponents<[PlotElement]> {
        var elements = EdgeComponents<[PlotElement]>(left: [], top: [], right: [], bottom: [])
        // TODO: Currently, only labels are "PlotElements".
        if !plotLabel.xLabel.isEmpty {
            let label = Label(text: plotLabel.xLabel, size: plotLabel.size)
                          .withPadding(.all(Self.xLabelPadding))
            elements.bottom.append(label)
        }
        if !plotLabel.yLabel.isEmpty {
            let label = Label(text: plotLabel.yLabel, size: plotLabel.size)
                          .withPadding(.all(Self.yLabelPadding))
            elements.left.append(label)
        }
        if !plotLabel.y2Label.isEmpty {
            let label = Label(text: plotLabel.y2Label, size: plotLabel.size)
                          .withPadding(.all(Self.yLabelPadding))
            elements.right.append(label)
        }
        if !plotTitle.title.isEmpty {
            let label = Label(text: plotTitle.title, size: plotTitle.size)
                          .withPadding(.all(Self.titleLabelPadding))
            elements.top.append(label)
        }
        return elements
    }
    
    /// Calculates the region of the plot which is used for displaying the plot's data (inside all of the chrome).
    private func calcPlotSize(totalSize: Size, plotElements: EdgeComponents<[Size]>) -> Size {
        var plotSize = totalSize
        
        // Subtract space for the plot elements.
        plotElements.left.forEach  { plotSize.width -= $0.width }
        plotElements.right.forEach { plotSize.width -= $0.width }
        plotElements.top.forEach    { plotSize.height -= $0.height }
        plotElements.bottom.forEach { plotSize.height -= $0.height }
        
        // Subtract space for the markers.
        // TODO: Make this more accurate.
        plotSize.height -= (2 * markerTextSize) + 10 // X markers
        plotSize.width -= yMarkerMaxWidth + 10 // Y markers
        plotSize.width -= yMarkerMaxWidth + 10 // Y2 markers
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
  
    private func layoutObjects(_ renderer: Renderer, _ results: inout Results) {
        renderer.drawSolidRect(.init(origin: .zero, size: results.totalSize),
                               fillColor: Color.random().withAlpha(0.5), hatchPattern: .none)
        // 1. Calculate the plotBorderRect.
        // We already have the size, so we only need to calculate the origin.
        var plotOrigin = Point.zero
        
        // Offset by the left/bottom PlotElements.
        plotOrigin.x += results.sizes.left.reduce(into: 0) { $0 += $1.width }
        plotOrigin.y += results.sizes.bottom.reduce(into: 0) { $0 += $1.height }
        // Offset by marker sizes (TODO: they are not PlotElements yet, so not handled above).
        let xMarkerHeight = (2 * markerTextSize) + 10 // X markers
        let yMarkerWidth  = yMarkerMaxWidth + 10      // Y markers
        plotOrigin.y += xMarkerHeight
        plotOrigin.x += yMarkerWidth
        // Offset by plot thickness.
        plotOrigin.x += plotBorder.thickness
        plotOrigin.y += plotBorder.thickness

        // These are the final coordinates of the plot's internal space, so update `results`.
        results.plotBorderRect = Rect(origin: plotOrigin, size: results.plotBorderRect.size)

        // 2. Lay out the PlotElements.
        var plotExternalRect = results.plotBorderRect
        plotExternalRect.contract(by: -1 * plotBorder.thickness)
        
        // Elements are laid out so that [0] is closest to the plot.
        // Top elements.
        var t_height: Float = 0
        for itemSize in results.sizes.top {
            let rect = Rect(origin: Point(plotExternalRect.minX, plotExternalRect.maxY + t_height),
                            size: Size(width: plotExternalRect.width, height: itemSize.height))
            results.rects.top.append(rect)
            t_height += itemSize.height
            renderer.drawSolidRect(rect, fillColor: Color.random().withAlpha(1), hatchPattern: .none)
        }
        // Bottom elements.
        var b_height: Float = xMarkerHeight
        for itemSize in results.sizes.bottom {
            let rect = Rect(origin: Point(plotExternalRect.minX, plotExternalRect.minY - b_height - itemSize.height),
                            size: Size(width: plotExternalRect.width, height: itemSize.height))
            results.rects.bottom.append(rect)
            b_height += itemSize.height
            renderer.drawSolidRect(rect, fillColor: Color.random().withAlpha(1), hatchPattern: .none)
        }
        // Right elements.
        var r_width: Float = results.plotMarkers.y2Markers.isEmpty ? 0 : yMarkerWidth
        for itemSize in results.sizes.right {
            let rect = Rect(origin: Point(plotExternalRect.maxX + r_width, plotExternalRect.minY),
                            size: Size(width: itemSize.width, height: plotExternalRect.height))
            results.rects.right.append(rect)
            r_width += itemSize.width
            renderer.drawSolidRect(rect, fillColor: Color.random().withAlpha(1), hatchPattern: .none)
        }
        // Left elements.
        var l_width: Float = yMarkerWidth
        for itemSize in results.sizes.left {
            let rect = Rect(origin: Point(plotExternalRect.minX - l_width - itemSize.width, plotExternalRect.minY),
                            size: Size(width: itemSize.width, height: plotExternalRect.height))
            results.rects.left.append(rect)
            l_width += itemSize.width
            renderer.drawSolidRect(rect, fillColor: Color.random().withAlpha(1), hatchPattern: .none)
        }
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
  
    /// Rounds the given markers to integer pixel locations, for sharper gridlines.
    private func roundMarkers(_ markers: inout PlotMarkers) {
//      for i in markers.xMarkers.indices {
//        markers.xMarkers[i].round(.down)
//      }
//      for i in markers.yMarkers.indices {
//        markers.yMarkers[i].round(.down)
//      }
//      for i in markers.y2Markers.indices {
//        markers.y2Markers[i].round(.down)
//      }
    }
    
    private func calcMarkerTextLocations(renderer: Renderer, results: inout Results) {
        
        for i in 0..<results.plotMarkers.xMarkers.count {
            let textWidth = renderer.getTextWidth(text: results.plotMarkers.xMarkersText[i], textSize: markerTextSize)
            let markerLocation = results.plotMarkers.xMarkers[i]
            var textLocation   = Point(0, -2.0 * markerTextSize)
            switch markerLabelAlignment {
            case .atMarker:
              textLocation.x = markerLocation - (textWidth/2)
            case .betweenMarkers:
              let nextMarkerLocation: Float
              if i < results.plotMarkers.xMarkers.endIndex - 1 {
                nextMarkerLocation = results.plotMarkers.xMarkers[i + 1]
              } else {
                nextMarkerLocation = results.plotBorderRect.width
              }
              let midpoint = markerLocation + (nextMarkerLocation - markerLocation)/2
              textLocation.x = midpoint - (textWidth/2)
            }
            results.xMarkersTextLocation.append(textLocation)
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
              nextMarkerLocation = results.plotBorderRect.height
            }
            let midpoint = markerLocation + (nextMarkerLocation - markerLocation)/2
            return midpoint - (textSize.height/2)
          }
        }
      
        for i in 0..<results.plotMarkers.yMarkers.count {
            var textSize = renderer.getTextLayoutSize(text: results.plotMarkers.yMarkersText[i],
                                                      textSize: markerTextSize)
            textSize.width = min(textSize.width, yMarkerMaxWidth)
            var textLocation = Point(-textSize.width - 8, 0)
            textLocation.y = alignYLabel(markers: results.plotMarkers.yMarkers, index: i, textSize: textSize)
            results.yMarkersTextLocation.append(textLocation)
        }
        
        for i in 0..<results.plotMarkers.y2Markers.count {
            var textSize = renderer.getTextLayoutSize(text: results.plotMarkers.y2MarkersText[i],
                                                      textSize: markerTextSize)
            textSize.width = min(textSize.width, yMarkerMaxWidth)
            var textLocation = Point(results.plotBorderRect.width + 8, 0)
            textLocation.y = alignYLabel(markers: results.plotMarkers.y2Markers, index: i, textSize: textSize)
            results.y2MarkersTextLocation.append(textLocation)
        }
    }
    
    private func calcLegend(_ labels: [(String, LegendIcon)], renderer: Renderer, results: inout Results) {
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
}

// Drawing.

extension GraphLayout {
    
    fileprivate func drawBackground(results: Results, renderer: Renderer) {
        renderer.drawSolidRect(Rect(origin: .zero, size: results.totalSize),
                               fillColor: backgroundColor, hatchPattern: .none)
        if let plotBackgroundColor = plotBackgroundColor {
            renderer.drawSolidRect(results.plotBorderRect, fillColor: plotBackgroundColor, hatchPattern: .none)
        }
        if !drawsGridOverForeground {
          drawGrid(results: results, renderer: renderer)
        }
        drawBorder(results: results, renderer: renderer)
        drawMarkers(results: results, renderer: renderer)
    }
    
    fileprivate func drawForeground(results: Results, renderer: Renderer) {
        if drawsGridOverForeground {
          drawGrid(results: results, renderer: renderer)
        }
        drawPlotElements(results: results, renderer: renderer)
        drawLegend(results.legendLabels, results: results, renderer: renderer)
        drawAnnotations(resolver: results, renderer: renderer)
    }
    
    private func drawPlotElements(results: Results, renderer: Renderer) {
        for (idx, plotElement) in results.elements.left.enumerated() {
            plotElement.draw(results.rects.left[idx], renderer: renderer)
        }
        for (idx, plotElement) in results.elements.top.enumerated() {
            plotElement.draw(results.rects.top[idx], renderer: renderer)
        }
        for (idx, plotElement) in results.elements.right.enumerated() {
            plotElement.draw(results.rects.right[idx], renderer: renderer)
        }
        for (idx, plotElement) in results.elements.bottom.enumerated() {
            plotElement.draw(results.rects.bottom[idx], renderer: renderer)
        }
    }
    
    private func drawBorder(results: Results, renderer: Renderer) {
      // The border should be drawn on the _outside_ of `plotBorderRect`.
        var rect = results.plotBorderRect
        rect.contract(by: -plotBorder.thickness/2)
        renderer.drawRect(rect,
                          strokeWidth: plotBorder.thickness,
                          strokeColor: plotBorder.color)
    }
    
    private func drawGrid(results: Results, renderer: Renderer) {
        guard enablePrimaryAxisGrid || enablePrimaryAxisGrid else { return }
        let rect = results.plotBorderRect
        for index in 0..<results.plotMarkers.xMarkers.count {
          let p1 = Point(results.plotMarkers.xMarkers[index] + rect.minX, rect.minY)
          let p2 = Point(results.plotMarkers.xMarkers[index] + rect.minX, rect.maxY)
          guard rect.internalXCoordinates.contains(p1.x),
                rect.internalXCoordinates.contains(p2.x) else { continue }
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
            for index in 0..<results.plotMarkers.y2Markers.count {
              let p1 = Point(rect.minX, results.plotMarkers.y2Markers[index] + rect.minY)
              let p2 = Point(rect.maxX, results.plotMarkers.y2Markers[index] + rect.minY)
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

    private func drawMarkers(results: Results, renderer: Renderer) {
        let rect = results.plotBorderRect
        let border = plotBorder.thickness
        for index in 0..<results.plotMarkers.xMarkers.count {
            let p1 = Point(results.plotMarkers.xMarkers[index], -border - 6) + rect.origin
            let p2 = Point(results.plotMarkers.xMarkers[index], -border) + rect.origin
            renderer.drawLine(startPoint: p1,
                              endPoint: p2,
                              strokeWidth: markerThickness,
                              strokeColor: plotBorder.color,
                              isDashed: false)
            renderer.drawText(text: results.plotMarkers.xMarkersText[index],
                              location: results.xMarkersTextLocation[index] + rect.origin + Pair(0, -border),
                              textSize: markerTextSize,
                              color: plotBorder.color,
                              strokeWidth: 0.7,
                              angle: 0)
        }

        for index in 0..<results.plotMarkers.yMarkers.count {
            let p1 = Point(-border - 6, results.plotMarkers.yMarkers[index]) + rect.origin
            let p2 = Point(-border, results.plotMarkers.yMarkers[index]) + rect.origin
            renderer.drawLine(startPoint: p1,
                              endPoint: p2,
                              strokeWidth: markerThickness,
                              strokeColor: plotBorder.color,
                              isDashed: false)
            renderer.drawText(text: results.plotMarkers.yMarkersText[index],
                              location: results.yMarkersTextLocation[index] + rect.origin + Pair(-border, 0),
                              textSize: markerTextSize,
                              color: plotBorder.color,
                              strokeWidth: 0.7,
                              angle: 0)
        }
        
        if !results.plotMarkers.y2Markers.isEmpty {
            for index in 0..<results.plotMarkers.y2Markers.count {
                let p1 = Point(results.plotBorderRect.width + border,
                               (results.plotMarkers.y2Markers[index])) + rect.origin
                let p2 = Point(results.plotBorderRect.width + border + 6,
                               (results.plotMarkers.y2Markers[index])) + rect.origin
                renderer.drawLine(startPoint: p1,
                                  endPoint: p2,
                                  strokeWidth: markerThickness,
                                  strokeColor: plotBorder.color,
                                  isDashed: false)
                renderer.drawText(text: results.plotMarkers.y2MarkersText[index],
                                  location: results.y2MarkersTextLocation[index]  + rect.origin + Pair(border, 0),
                                  textSize: markerTextSize,
                                  color: plotBorder.color,
                                  strokeWidth: 0.7,
                                  angle: 0)
            }
        }
    }
    
    private func drawLegend(_ entries: [(String, LegendIcon)], results: Results, renderer: Renderer) {
        
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
        let (drawingData, results) = layout.layout(size: size, renderer: renderer) {
            size -> (DrawingData, PlotMarkers?, [(String, LegendIcon)]?) in
            let tup = layoutData(size: size, renderer: renderer)
            return (tup.0, tup.1, self.legendLabels)
        }
        layout.drawBackground(results: results, renderer: renderer)
        renderer.withAdditionalOffset(results.plotBorderRect.origin) { renderer in
            drawData(drawingData, size: results.plotBorderRect.size, renderer: renderer)
        }
        layout.drawForeground(results: results, renderer: renderer)
    }

    public mutating func addAnnotation(annotation: Annotation) {
        layout.annotations.append(annotation)
    }
}
