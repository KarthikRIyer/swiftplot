public protocol FloatConvertible : Comparable{
    init<T: FloatConvertible>(_ x: T)
    init(_ other: Float)
    init(_ other: Double)
    init(_ other: Int)

    func toFloat() -> Float
    func toDouble() -> Double
    func toInt() -> Int
    static func +(lhs: Self, rhs: Self) -> Self
    static func -(lhs: Self, rhs: Self) -> Self
    static func *(lhs: Self, rhs: Self) -> Self
    static func /(lhs: Self, rhs: Self) -> Self
}

extension Float: FloatConvertible {
    public init<T: FloatConvertible>(_ x: T) {self = x.toFloat()}
    public func toFloat() -> Float {return Float(self)}
    public func toDouble() -> Double {return Double(self)}
    public func toInt() -> Int {return Int(self)}
}

extension Double: FloatConvertible {
   public init<T: FloatConvertible>(_ x: T) {self = x.toDouble()}
   public func toFloat() -> Float {return Float(self)}
   public func toDouble() -> Double {return Double(self)}
   public func toInt() -> Int {return Int(self)}
}


// extension Int: FloatConvertible {
//    public init<T: FloatConvertible>(_ x: T) {self = x.toInt()}
//    public func toFloat() -> Float {return Float(self)}
//    public func toDouble() -> Double {return Double(self)}
//    public func toInt() -> Int {return Int(self)}
// }
