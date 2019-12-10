
// Todo list for Heatmap:
// - Spacing between blocks
// - Setting X/Y axis labels
// - Displaying colormap next to plot
// - Collection slicing by filter closure?

/// A heatmap is a plot of 2-dimensional data, where each value is assigned a colour value along a gradient.
///
/// Use the `interpolator` property to control how values are graded. For example, if your data structure has
/// a salient integer or floating-point property, `Interpolator.linearByKeyPath` will allow you to grade values by that property.
public struct Heatmap<SeriesType> where SeriesType: Sequence, SeriesType.Element: Sequence {
  
  public typealias Element = SeriesType.Element.Element

  public var layout = GraphLayout()
  
  public var values: SeriesType
  public var interpolator: Interpolator<Element>
  public var colorMap: ColorMap = .fiveColorHeatMap
  
  public init(values: SeriesType, interpolator: Interpolator<Element>) {
    self.values = values
    self.interpolator = interpolator
    self.layout.drawsGridOverForeground = true
    self.layout.markerLabelAlignment = .betweenMarkers
    self.showGrid = false
  }
}

// Customisation properties.

extension Heatmap {
  
  public var showGrid: Bool {
    get { layout.enablePrimaryAxisGrid }
    set { layout.enablePrimaryAxisGrid = newValue }
  }
}

// Layout and drawing.

extension Heatmap: HasGraphLayout, Plot {
  
  public struct DrawingData: AdjustsPlotSize {
    var values: SeriesType?
    var range: (min: Element, max: Element)?
    var itemSize = Size.zero
    var rows = 0
    var columns = 0
    
    var desiredPlotSize = Size.zero
  }
  
  public func layoutData(size: Size, renderer: Renderer) -> (DrawingData, PlotMarkers?) {
    
    var results = DrawingData()
    var markers = PlotMarkers()
    // Extract the first (inner) element as a starting point.
    guard let firstElem = values.first(where: { _ in true })?.first(where: { _ in true }) else {
      return (results, nil)
    }
    var (maxValue, minValue) = (firstElem, firstElem)
    
    // - Discover the maximum/minimum values and shape of the data.
    var totalRows = 0
    var maxColumns = 0
    for row in values {
      var columnsInRow = 0
      for column in row {
        maxValue = interpolator.compare(maxValue, column) ? column : maxValue
        minValue = interpolator.compare(minValue, column) ? minValue : column
        columnsInRow += 1
      }
      maxColumns = max(maxColumns, columnsInRow)
      totalRows += 1
    }
    
    // - Calculate the element size.
    var elementSize = Size(
      width: size.width / Float(maxColumns),
      height: size.height / Float(totalRows)
    )
    // We prefer showing smaller elements with integer dimensions to avoid aliasing.
    if elementSize.width > 1  { elementSize.width.round(.down)  }
    if elementSize.height > 1 { elementSize.height.round(.down) }
    
    // Update results.
    results.values = values
    results.range = (minValue, maxValue)
    results.rows = totalRows
    results.columns = maxColumns
    results.itemSize = elementSize
    // The size rounding may leave a gap between the data and the border,
    // so let the layout know we desire a smaller plot.
    results.desiredPlotSize = Size(width: Float(results.columns) * results.itemSize.width,
                                   height: Float(results.rows) * results.itemSize.height)
    
    // Calculate markers.
    markers.xMarkers = (0..<results.columns).map {
      Float($0) * results.itemSize.width
    }
    markers.yMarkers = (0..<results.rows).map {
      Float($0) * results.itemSize.height
    }
    
    // TODO: Allow setting the marker text.
    markers.xMarkersText = (0..<results.columns).map { String($0) }
    markers.yMarkersText = (0..<results.rows).map    { String($0) }
    
    return (results, markers)
  }
  
  public func drawData(_ data: DrawingData, size: Size, renderer: Renderer) {
    guard let values = data.values, let range = data.range else { return }
    
    for (rowIdx, row) in values.enumerated() {
      for (columnIdx, element) in row.enumerated() {
        let rect = Rect(
          origin: Point(Float(columnIdx) * data.itemSize.width,
                        Float(rowIdx) * data.itemSize.height),
          size: data.itemSize
        )
        let offset = interpolator.interpolate(element, range.min, range.max)
        let color = colorMap.colorForOffset(offset)
        renderer.drawSolidRect(rect, fillColor: color, hatchPattern: .none)
//        renderer.drawText(text: String(describing: element),
//                          location: rect.origin + Point(50,50),
//                          textSize: 20,
//                          color: .white,
//                          strokeWidth: 2,
//                          angle: 0)
      }
    }
  }
}

// Initialisers with default arguments.

extension Heatmap
  where SeriesType: ExpressibleByArrayLiteral, SeriesType.Element: ExpressibleByArrayLiteral,
        SeriesType.ArrayLiteralElement == SeriesType.Element {
  
  public init(interpolator: Interpolator<Element>) {
    self.init(values: [[]], interpolator: interpolator)
  }
}

extension Heatmap
  where SeriesType: ExpressibleByArrayLiteral, SeriesType.Element: ExpressibleByArrayLiteral,
        SeriesType.ArrayLiteralElement == SeriesType.Element, Element: FloatConvertible {
  
  public init(values: SeriesType) {
    self.init(values: values, interpolator: .linear)
  }
  
  public init() {
    self.init(interpolator: .linear)
  }
}

extension Heatmap
  where SeriesType: ExpressibleByArrayLiteral, SeriesType.Element: ExpressibleByArrayLiteral,
        SeriesType.ArrayLiteralElement == SeriesType.Element, Element: FixedWidthInteger {
  
  public init(values: SeriesType) {
    self.init(values: values, interpolator: .linear)
  }
  
  public init() {
    self.init(interpolator: .linear)
  }
}

// Collection construction shorthand.

extension SequencePlots where Base.Element: Sequence {
  
  /// Returns a heatmap of values from this 2-dimensional sequence.
  /// - parameters:
  ///   - interpolator: A function or `KeyPath` which maps values to a continuum between 0 and 1.
  /// - returns: A heatmap plot of the sequence's inner items.
  public func heatmap(
    interpolator: Interpolator<Base.Element.Element>,
    style: (inout Heatmap<Base>)->Void = { _ in }
  ) -> Heatmap<Base> {
    
    var graph = Heatmap(values: base, interpolator: interpolator)
    style(&graph)
    return graph
  }
}

extension SequencePlots where Base: Collection {
  
  /// Returns a heatmap of this collection's values, generated by slicing rows with the given width.
  /// - parameters:
  ///   - width:        The width of the heatmap to generate. Must be greater than 0.
  ///   - interpolator: A function or `KeyPath` which maps values to a continuum between 0 and 1.
  /// - returns: A heatmap plot of the collection's values.
  /// - complexity: O(n). Consider though, that rendering a heatmap or copying to a `RamdomAccessCollection`
  ///               is also at least O(n), and this does not copy the data.
  public func heatmap(
    width: Int,
    interpolator: Interpolator<Base.Element>,
    style: (inout Heatmap<[Base.SubSequence]>)->Void = { _ in }
  ) -> Heatmap<[Base.SubSequence]> {
    
    precondition(width > 0, "Cannot build a histogram with zero or negative width")
    var rows = [Base.SubSequence]()
    var rowStart = base.startIndex
    while rowStart != base.endIndex {
      guard let rowEnd = base.index(rowStart, offsetBy: width, limitedBy: base.endIndex) else {
        rows.append(base[rowStart..<base.endIndex])
        break
      }
      rows.append(base[rowStart..<rowEnd])
      rowStart = rowEnd
    }
    return rows.plots.heatmap(interpolator: interpolator, style: style)
  }
}

extension SequencePlots where Base: RandomAccessCollection {
  
  /// Returns a heatmap of this collection's values, generated by slicing rows with the given width.
  /// - parameters:
  ///   - width:        The width of the heatmap to generate. Must be greater than 0.
  ///   - interpolator: A function or `KeyPath` which maps values to a continuum between 0 and 1.
  /// - returns: A heatmap plot of the collection's values.
  public func heatmap(
    width: Int,
    interpolator: Interpolator<Base.Element>,
    style: (inout Heatmap<[Base.SubSequence]>)->Void = { _ in }
  ) -> Heatmap<[Base.SubSequence]> {
    
    precondition(width > 0, "Cannot build a histogram with zero or negative width")
    let height = Int((Float(base.count) / Float(width)).rounded(.up))
    return (0..<height)
      .map { base._sliceForRow($0, width: width) }
      .plots.heatmap(interpolator: interpolator, style: style)
  }
  
  /// Returns a heatmap of this collection's values, generated by the data in to `height` rows.
  /// - parameters:
  ///   - height:        The height of the heatmap to generate. Must be greater than 0.
  ///   - interpolator: A function or `KeyPath` which maps values to a continuum between 0 and 1.
  /// - returns: A heatmap plot of the collection's values.
  public func heatmap(
    height: Int,
    interpolator: Interpolator<Base.Element>,
    style: (inout Heatmap<[Base.SubSequence]>)->Void = { _ in }
  ) -> Heatmap<[Base.SubSequence]> {
    
    precondition(height > 0, "Cannot build a histogram with zero or negative height")
    let width = Int((Float(base.count) / Float(height)).rounded(.up))
    return (0..<height)
      .map { base._sliceForRow($0, width: width) }
      .plots.heatmap(interpolator: interpolator, style: style)
  }
}

extension RandomAccessCollection {
  fileprivate func _sliceForRow(_ row: Int, width: Int) -> SubSequence {
    guard let start = index(startIndex, offsetBy: row * width, limitedBy: endIndex) else {
      return self[startIndex..<startIndex]
    }
    guard let end = index(start, offsetBy: width, limitedBy: endIndex) else {
      return self[start..<endIndex]
    }
    return self[start..<end]
  }
}
