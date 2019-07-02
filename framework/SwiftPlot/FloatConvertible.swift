public protocol FloatConvertible {
    init(_ other: Float)
    init(_ other: Double)
    // init(_ other: Int)
    init(_ x: FloatConvertible)

    func _asOther<T:FloatConvertible>() -> T
}

extension FloatConvertible {
    public init(_ x:FloatConvertible) {self = x._asOther()}
}
// note that we have to implement these for each extension,
// so that Swift uses the concrete types of self, preventing an infinite loop
extension Float: FloatConvertible {
    public func _asOther<T:FloatConvertible>() -> T {return T(self)}
}

extension Double: FloatConvertible {
    public func _asOther<T:FloatConvertible>() -> T {return T(self)}
}

// extension Int: FloatConvertible {
//     public func _asOther<T:FloatConvertible>() -> T {return T(self)}
// }
