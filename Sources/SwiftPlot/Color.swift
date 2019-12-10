public struct Color {
    public var r: Float
    public var g: Float
    public var b: Float
    public var a: Float
    public init(_ r: Float, _ g: Float, _ b: Float, _ a: Float){
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }
    public static let transparent = Color(0, 0, 0, 0)
    public static let black: Color = Color(0.0, 0.0, 0.0, 1.0)
    public static let white: Color = Color(1.0, 1.0, 1.0, 1.0)
    public static let transluscentWhite: Color = Color(1.0, 1.0, 1.0, 0.7)
    public static let purple: Color = Color(0.5, 0.0, 0.5, 1.0)
    public static let lightBlue: Color = Color(0.529, 0.808, 0.922, 1.0)
    public static let blue: Color = Color(0.0, 0.0, 1.0, 1.0)
    public static let darkBlue: Color = Color(0.0, 0.0, 0.54, 1.0)
    public static let green: Color = Color(0.0, 0.5, 0.0, 1.0)
    public static let darkGreen: Color = Color(0.0, 0.39, 0.0, 1.0)
    public static let yellow: Color = Color(1.0, 1.0, 0.0, 1.0)
    public static let gold: Color = Color(1.0, 0.84, 0.0, 1.0)
    public static let orange: Color = Color(1.0, 0.647, 0.0, 1.0)
    public static let red: Color = Color(1.0, 0.0, 0.0, 1.0)
    public static let darkRed: Color = Color(0.54, 0.0, 0.0, 1.0)
    public static let brown: Color = Color(0.54, 0.27, 0.1, 1.0)
    public static let pink: Color = Color(1.0, 0.75, 0.79, 1.0)
    public static let gray: Color = Color(0.5, 0.5, 0.5, 1.0)
    public static let darkGray: Color = Color(0.66, 0.66, 0.66, 1.0)
}

extension Color {
  
  public func withAlpha(_ alpha: Float) -> Color {
    var color = self
    color.a = alpha
    return color
  }
  
  public func linearBlend(with other: Color, offset: Float) -> Color {
    return Color(
      (other.r - r) * offset + r,
      (other.g - g) * offset + g,
      (other.b - b) * offset + b,
      (other.a - a) * offset + a)
  }
}

#if canImport(CoreGraphics)
import CoreGraphics

fileprivate let RGBColorSpace = CGColorSpaceCreateDeviceRGB()

public extension Color {
    @available(tvOS 13.0, watchOS 6.0, *)
    var cgColor : CGColor {
        if #available(OSX 10.15, iOS 13.0, *) {
            return CGColor(srgbRed: CGFloat(r),
                           green: CGFloat(g),
                           blue: CGFloat(b),
                           alpha: CGFloat(a))
        } else {
            var tuple = (CGFloat(r), CGFloat(g), CGFloat(b), CGFloat(a))
            return withUnsafePointer(to: &tuple) { tupPtr in
                return tupPtr.withMemoryRebound(to: CGFloat.self, capacity: 4) { floatPtr in
                    return CGColor(colorSpace: RGBColorSpace, components:floatPtr)!
                }
            }
        }
    }
}
#endif
