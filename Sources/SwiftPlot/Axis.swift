public struct Axis<T,U>{

    public var series = [Series<T,U>]()
    public init(){}

    public enum Location {
        case primaryAxis
        case secondaryAxis
    }
}
