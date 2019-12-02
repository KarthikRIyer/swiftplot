public struct ScatterPlotSeriesOptions {
    public enum ScatterPattern{
        case circle
        case square
        case triangle
        case diamond
        case hexagon
        case pentagon
        case star
    }
    public var scatterPattern: ScatterPattern = .circle
    public init() {}
}
