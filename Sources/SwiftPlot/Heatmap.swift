
public struct Heatmap<SeriesType>
where SeriesType: Sequence, SeriesType.Element: Sequence,
      SeriesType.Element.Element: Comparable {
  
  public typealias Element = SeriesType.Element.Element

  public var layout = GraphLayout()
  public var values: SeriesType
  public var interpolator: Interpolator<Element>
  
  public init(values: SeriesType, interpolator: Interpolator<Element>) {
    self.values = values
    self.interpolator = interpolator
//    self.layout.yMarkerMaxWidth = 100
//    self.layout.enablePrimaryAxisGrid = false
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

// Layout and drawing.

extension Heatmap: HasGraphLayout, Plot {
  
  public struct DrawingData {
    var values: SeriesType?
    var range: ClosedRange<Element>?
    var itemSize = Size.zero
    var rows = 0
    var columns = 0
  }
  
  public func layoutData(size: Size, renderer: Renderer) -> (DrawingData, PlotMarkers?) {
    
    var results = DrawingData()
    var markers = PlotMarkers()
    
    // Extract the first (inner) element as a starting point.
    guard let firstElem = values.first(where: { _ in true })?.first(where: { _ in true }) else {
      return (results, nil)
    }
    var (maxValue, minValue) = (firstElem, firstElem)
    
    // Discover the maximum/minimum values and shape of the data.
    var totalRows = 0
    var maxColumns = 0
    for row in values {
      var columnsInRow = 0
      for column in row {
        maxValue = max(maxValue, column)
        minValue = min(minValue, column)
        columnsInRow += 1
      }
      maxColumns = max(maxColumns, columnsInRow)
      totalRows += 1
    }
    // Update results.
    results.values = values
    results.range = minValue...maxValue
    results.rows = totalRows
    results.columns = maxColumns
    results.itemSize = Size(
      width: size.width / Float(results.columns),
      height: size.height / Float(results.rows)
    )
    // Calculate markers.
    markers.xMarkers = (0..<results.columns).map {
      (Float($0) + 0.5) * results.itemSize.width
    }
    markers.yMarkers = (0..<results.rows).map {
      (Float($0) + 0.5) * results.itemSize.height
    }
    // TODO: Shift grid by -0.5 * itemSize.
    
    // TODO: Allow setting the marker text.
    markers.xMarkersText = (0..<results.columns).map { String($0) }
    markers.yMarkersText = (0..<results.rows).map    { String($0) }
    
    return (results, markers)
  }
  
  public func drawData(_ data: DrawingData, size: Size, renderer: Renderer) {
    
    
    guard let values = data.values, let range = data.range else { return }
    
    for (rowIdx, row) in values.enumerated() {
      for (columnIdx, column) in row.enumerated() {
        let rect = Rect(
          origin: Point(Float(columnIdx) * data.itemSize.width,
                        Float(rowIdx) * data.itemSize.height),
          size: data.itemSize)
        renderer.drawSolidRect(rect,
                               fillColor: getColor(of: column, range: range),
                               hatchPattern: .none)
//        renderer.drawText(text: String(describing: column),
//                          location: rect.origin + Point(50,50),
//                          textSize: 20,
//                          color: .white,
//                          strokeWidth: 2,
//                          angle: 0)
      }
    }
  }
  
  func getColor(of value: Element, range: ClosedRange<Element>) -> Color {
    let startColor = Color.orange
    let endColor = Color.purple
    let interp = interpolator.callAsFunction(value, in: range)
    
    return lerp(startColor: startColor, endColor: endColor, interp)
  }
}


// Interpolator.

public struct Interpolator<Element> where Element: Comparable {
  public var interpolate: (Element, ClosedRange<Element>) -> Float
  
  public init(_ block: @escaping (Element, ClosedRange<Element>)->Float) {
    self.interpolate = block
  }
  public func callAsFunction(_ item: Element, in range: ClosedRange<Element>) -> Float {
    interpolate(item, range)
  }
}

extension Interpolator where Element: FloatConvertible {
  public static var linear: Interpolator {
    Interpolator { value, range in
      let value = Float(value)
      let range = Float(range.lowerBound)...Float(range.upperBound)
      let totalDistance = range.lowerBound.distance(to: range.upperBound)
      let valueOffset   = range.lowerBound.distance(to: value)
      return valueOffset/totalDistance
    }
  }
}
extension Interpolator where Element: FixedWidthInteger {
  public static var linear: Interpolator {
    Interpolator { value, range in
      let distance = range.lowerBound.distance(to: range.upperBound)
      let valDist = range.lowerBound.distance(to: value)
      return Float(valDist)/Float(distance)
    }
  }
}

extension Interpolator {
  
  public static func linearByKeyPath<T>(_ kp: KeyPath<Element, T>) -> Interpolator<Element>
    where T: FloatConvertible {
      let i = Interpolator<T>.linear
      return Interpolator { value, range in
        let value = value[keyPath: kp]
        let range = range.lowerBound[keyPath: kp]...range.upperBound[keyPath: kp]
        return i.interpolate(value, range)
      }
  }
  
  public static func linearByKeyPath<T>(_ kp: KeyPath<Element, T>) -> Interpolator<Element>
    where T: FixedWidthInteger {
      let i = Interpolator<T>.linear
      return Interpolator { value, range in
        let value = value[keyPath: kp]
        let range = range.lowerBound[keyPath: kp]...range.upperBound[keyPath: kp]
        return i.interpolate(value, range)
      }
  }
  
}
