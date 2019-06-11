// struct defining a data series
public struct Series {
    public var barGraphSeriesOptions = BarGraphSeriesOptions()
    public var scatterPlotSeriesOptions = ScatterPlotSeriesOptions()
    public var points = [Point]()
    public var scaledPoints = [Point]()
    public var maxY: Float = 0
    public var minY: Float = 0
    public var label = "Plot"
    public var color : Color = .blue
    public var startColor: Color? = nil
    public var endColor: Color? = nil
    public init() {}
    public init(points p: [Point], label l: String, color c: Color = Color.lightBlue, hatchPattern: BarGraphSeriesOptions.Hatching = .none, scatterPattern: ScatterPlotSeriesOptions.ScatterPattern = .circle){
        points = p
        label = l
        color = c
        barGraphSeriesOptions.hatchPattern = hatchPattern
        scatterPlotSeriesOptions.scatterPattern = scatterPattern
    }
    public init(points p: [Point], label l: String, startColor : Color = .lightBlue, endColor : Color = Color.lightBlue, hatchPattern: BarGraphSeriesOptions.Hatching = .none, scatterPattern: ScatterPlotSeriesOptions.ScatterPattern = .circle){
        points = p
        label = l
        self.startColor = startColor
        self.endColor = endColor
        barGraphSeriesOptions.hatchPattern = hatchPattern
        scatterPlotSeriesOptions.scatterPattern = scatterPattern
    }
}
