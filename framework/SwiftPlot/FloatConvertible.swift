public protocol FloatConvertible : Comparable{
    init<T: FloatConvertible>(_ x: T)
    init(_ other: Float)
    init(_ other: Double)
    init(_ other: Int)

    func toFloat() -> Float
    static func +(lhs: Self, rhs: Self) -> Self
    static func -(lhs: Self, rhs: Self) -> Self
    static func *(lhs: Self, rhs: Self) -> Self
    static func /(lhs: Self, rhs: Self) -> Self
}

extension Float: FloatConvertible {
    public init<T: FloatConvertible>(_ x: T) {self = x.toFloat()}
    public func toFloat() -> Float {return Float(self)}
}
