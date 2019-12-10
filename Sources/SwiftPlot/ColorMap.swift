
// This struct is a namespace for static functions and properties which return known color maps.
// All of these functions and properties also _return_ a `ColorMap`,
// instances of which are used as an interface type
// rather than existentials of `ColorMapProtocol` directly
// (again, so users can have access to convenient, known color maps).

public struct ColorMap: ColorMapProtocol {
  var base: ColorMapProtocol
  
  public init(_ base: ColorMapProtocol) {
    if let existing = base as? ColorMap { self = existing }
    else { self.base = base }
  }
  
  public func colorForOffset(_ offset: Float) -> Color {
    return base.colorForOffset(offset)
  }
}

public protocol ColorMapProtocol {
  func colorForOffset(_ offset: Float) -> Color
}

// Linear Gradients.

struct LinearGradient: ColorMapProtocol {
  struct Stop {
    var color: Color
    var position: Double
    
    init(_ color: Color, at pos: Double) {
      self.color = color; self.position = pos
    }
  }
  
  var stops: [Stop]
  
  init(stops: [Stop]) {
    self.stops = stops.sorted { $0.position < $1.position }
  }
  
  init(start: Color, end: Color) {
    self.init(stops: [Stop(start, at: 0), Stop(end, at: 1)])
  }
  
  func colorForOffset(_ offset: Float) -> Color {
    return colorForOffset(Double(offset))
  }
  
  func colorForOffset(_ offset: Double) -> Color {
    guard (0...1).contains(offset),
      let rightStopIdx = stops.firstIndex(where: { $0.position > offset }) else {
        return stops.last?.color ?? .black
    }
    let rightStop = stops[rightStopIdx]
    guard rightStopIdx > stops.startIndex else { return rightStop.color }
    let leftStop = stops[stops.index(before: rightStopIdx)]
    assert(leftStop.position <= offset)

    let distance = rightStop.position - leftStop.position
    guard distance > 0 else { return rightStop.color }
    
    let offset = Float((offset - leftStop.position) / distance)
    return leftStop.color.linearBlend(with: rightStop.color, offset: offset)
  }
}

extension ColorMap {
  
  public static func linear(_ start: Color, _ end: Color) -> ColorMap {
    return ColorMap(LinearGradient(start: start, end: end))
  }
  
  public static let fiveColorHeatMap = ColorMap(LinearGradient(stops: [
    LinearGradient.Stop(Color(0, 0, 1, 1), at: 0),
    LinearGradient.Stop(Color(0, 1, 1, 1), at: 0.25),
    LinearGradient.Stop(Color(0, 1, 0, 1), at: 0.5),
    LinearGradient.Stop(Color(1, 1, 0, 1), at: 0.75),
    LinearGradient.Stop(Color(1, 0, 0, 1), at: 1),
  ]))
  
  public static let sevenColorHeatMap = ColorMap(LinearGradient(stops: [
    LinearGradient.Stop(Color(0, 0, 0, 1), at: 0),
    LinearGradient.Stop(Color(0, 0, 1, 1), at: 0.1666666667),
    LinearGradient.Stop(Color(0, 1, 1, 1), at: 0.3333333333),
    LinearGradient.Stop(Color(0, 1, 0, 1), at: 0.5),
    LinearGradient.Stop(Color(1, 1, 0, 1), at: 0.6666666667),
    LinearGradient.Stop(Color(1, 0, 0, 1), at: 0.8333333333),
    LinearGradient.Stop(Color(1, 1, 1, 1), at: 1)
  ]))
}

// Transforming.

struct ColorTransformer<T>: ColorMapProtocol where T: ColorMapProtocol {
  var base: T
  var transform: (inout Color)->Void
  init(_ base: T, transform: @escaping (inout Color)->Void) {
    self.base = base; self.transform = transform
  }
  func colorForOffset(_ offset: Float) -> Color {
    var color = base.colorForOffset(offset)
    transform(&color)
    return color
  }
}

extension ColorMap {
  
  public func withAlpha(_ alpha: Float) -> ColorMap {
    return ColorMap(ColorTransformer(self) { $0.a = alpha })
  }
  
  public func lightened(by: Float) -> ColorMap {
    return ColorMap(ColorTransformer(self) { $0 = $0.linearBlend(with: .white, offset: by) })
  }
  
  public func darkened(by: Float) -> ColorMap {
    return ColorMap(ColorTransformer(self) { $0 = $0.linearBlend(with: .black, offset: by) })
  }
}
