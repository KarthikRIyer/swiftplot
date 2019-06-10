public class ScatterPlotSeriesOptions {
    public enum ScatterPattern{
        case circle
        case square
        case triangle
    }
    public var scatterPattern: ScatterPattern = .circle
    public init() {}
}
