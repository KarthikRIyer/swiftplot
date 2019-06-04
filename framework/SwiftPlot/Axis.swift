public class Axis{
    public var scaleX: Float = 1
    public var scaleY: Float = 1
    public var plotMarkers: PlotMarkers = PlotMarkers()
    public var series = [Series]()
    public init(){}
  
    public enum Location {
        case primaryAxis
        case secondaryAxis
    }
}
