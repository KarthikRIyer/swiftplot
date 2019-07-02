// struct defining a Pair
public struct Pair<T,U> {
    public let x: T
    public let y: U

    public init(_ x: T, _ y: U){
        self.x = x
        self.y = y
    }
}

let zeroPair = Pair<FloatConvertible,FloatConvertible>(0.0, 0.0)
