// class defining a point
public struct Point {
    public let x: Float
    public let y: Float
    public let xString: String
    public let yString: String
    public init(_ x: Float, _ y: Float){
        self.x = x
        self.y = y
        xString = "\(x)"
        yString = "\(y)"
    }
    public init(_ xString: String, _ y: Float) {
        self.xString = xString
        self.y = y
        yString = "\(y)"
        x = 0.0
    }
    public init(_ x: Float, _ yString: String) {
        self.yString = yString
        self.x = x
        xString = "\(x)"
        y = 0.0
    }
    public static let zero = Point(0.0, 0.0)
}
