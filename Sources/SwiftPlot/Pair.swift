// struct defining a Pair
public struct Pair<T,U> {
    public var x: T
    public var y: U

    public init(_ x: T, _ y: U){
        self.x = x
        self.y = y
    }
}
extension Pair: Equatable where T: Equatable, U: Equatable {}
extension Pair: Hashable where T: Hashable, U: Hashable {}

public typealias Point = Pair<Float,Float>

extension Point {
    public static let zero = Point(0.0, 0.0)
}

public func + (lhs: Point, rhs: Point) -> Point {
    return Point(lhs.x + rhs.x, lhs.y + rhs.y)
}
public func += (lhs: inout Point, rhs: Point) {
    lhs.x += rhs.x
    lhs.y += rhs.y
}
