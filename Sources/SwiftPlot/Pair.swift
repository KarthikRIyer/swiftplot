// struct defining a Pair
public struct Pair<T,U> {
    public var x: T
    public var y: U

    public init(_ x: T, _ y: U){
        self.x = x
        self.y = y
    }
}

public typealias Point = Pair<Float,Float>
public let zeroPoint = Point(0.0, 0.0)

public struct Size {
    public var width: Float
    public var height: Float
}

public struct Rect {
    public var origin: Point
    public var size: Size
}
