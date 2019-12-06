
public struct Heatmap<SeriesType>
where SeriesType: Sequence, SeriesType.Element: Sequence,
//SeriesType.Element.Element: Comparable & Strideable,
SeriesType.Element.Element: FixedWidthInteger {
  
  typealias Element = SeriesType.Element.Element

  public var values: SeriesType
  public var layout = GraphLayout()
  
  public init(values: SeriesType) {
    self.values = values
    self.layout.yMarkerMaxWidth = 100
  }
}

extension Heatmap
  where SeriesType: ExpressibleByArrayLiteral, SeriesType.Element: ExpressibleByArrayLiteral,
        SeriesType.ArrayLiteralElement == SeriesType.Element {
  
  public init() {
    self.init(values: [[]])
  }
}

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
    
    var maxValue: Element
    var minValue: Element
    do {
      var outerIterator = values.makeIterator()
      var innerIterator = outerIterator.next()?.makeIterator()
      guard let firstElem = innerIterator?.next() else {
        return (results, nil)
      }
      (maxValue, minValue) = (firstElem, firstElem)
    }
    
    var numberOfColumns = 0
    var numberOfRows = 0
    for row in values {
      var columnsInThisRow = 0
      for column in row {
        maxValue = max(maxValue, column)
        minValue = min(minValue, column)
        columnsInThisRow += 1
      }
      if numberOfRows == 0 {
        numberOfColumns = columnsInThisRow
      } else {
        precondition(numberOfColumns == columnsInThisRow)
      }
      numberOfRows += 1
    }
        
    results.values = values
    results.range = minValue...maxValue
    results.rows = numberOfRows
    results.columns = numberOfColumns
    results.itemSize = Size(width: size.width / Float(results.columns),
                            height: size.height / Float(results.rows))
    
    markers.xMarkers = (0..<results.columns).map {
      (Float($0) + 0.5) * results.itemSize.width
    }
    markers.xMarkersText = (0..<results.columns).map {
      String($0)
    }
    
    markers.yMarkers = (0..<results.rows).map {
      (Float($0) + 0.5) * results.itemSize.height
    }
    markers.yMarkersText = (0..<results.rows).map {
      "The number " + String($0)
    }
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
        renderer.drawText(text: String(column),
                          location: rect.origin + Point(50,50),
                          textSize: 20,
                          color: .white,
                          strokeWidth: 2,
                          angle: 0)
      }
    }
  }
  
  func getColor(of value: Element, range: ClosedRange<Element>) -> Color {
    let startColor = Color.orange
    let endColor = Color.purple
    
    let distance = range.lowerBound.distance(to: range.upperBound)
    let valDist = range.lowerBound.distance(to: value)
    
    let interp = Float(valDist)/Float(distance)
    
    return lerp(startColor: startColor, endColor: endColor, interp)
  }
}
