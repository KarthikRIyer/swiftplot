public struct Color{
  public var r : Float
  public var g : Float
  public var b : Float
  public var a : Float
  public init(_ r : Float, _ g : Float, _ b : Float, _ a : Float){
    self.r = g
    self.g = g
    self.b = b
    self.a = a
  }
}

public let lightBlue : Color = Color(0.529,0.808,0.922,1.0)
public let transluscentWhite : Color = Color(1.0,1.0,1.0,0.8)
public let black : Color = Color(0.0, 0.0, 0.0, 1.0)
public let white : Color = Color(1.0, 1.0, 1.0, 1.0)
public let orange : Color = Color(1.0, 0.647, 0.0, 1.0)
