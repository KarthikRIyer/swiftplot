public class Axis<T,U>{
    public var scaleX: Float = 1
    public var scaleY: Float = 1
    public var series = [Series<T,U>]()
    public init(){}

    public enum Location {
        case primaryAxis
        case secondaryAxis
    }
}
