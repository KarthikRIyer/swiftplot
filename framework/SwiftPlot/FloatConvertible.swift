public protocol FloatConvertible {
    init(_ x: FloatConvertible)

    func toFloat() -> Float
}

extension Float: FloatConvertible {
    public init(_ x: FloatConvertible) {self = x.toFloat()}
    public func toFloat() -> Float {return Float(self)}
}
