
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
  var start: Color
  var end: Color
  func colorForOffset(_ offset: Float) -> Color {
    return lerp(startColor: start, endColor: end, offset)
  }
}

extension ColorMap {
  public static func linear(_ start: Color, _ end: Color) -> ColorMap {
    return ColorMap(LinearGradient(start: start, end: end))
  }
}
