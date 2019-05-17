// class defining a point
public struct Point {
  public let x : Float
  public let y : Float
  public init(_ x : Float, _ y : Float){
    self.x = x
    self.y = y
  }
  public static let zero = Point(0.0, 0.0)
}
