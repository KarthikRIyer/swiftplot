// struct defining a data series
public struct Series<T,U> {
    public var barGraphSeriesOptions = BarGraphSeriesOptions()
    public var scatterPlotSeriesOptions = ScatterPlotSeriesOptions()
    public var pairs = [Pair<T,U>]()
    public var scaledPairs = [Pair<T,U>]()
    public var maxY: Float = 0
    public var minY: Float = 0
    public var label = "Plot"
    public var color : Color = .blue
    public var startColor: Color? = nil
    public var endColor: Color? = nil
    public init() {}

    public init(pairs : [Pair<T,U>],
                label l: String,
                startColor : Color = .lightBlue,
                endColor : Color = Color.lightBlue,
                hatchPattern: BarGraphSeriesOptions.Hatching = .none,
                scatterPattern: ScatterPlotSeriesOptions.ScatterPattern = .circle){
        self.pairs = pairs
        label = l
        self.startColor = startColor
        self.endColor = endColor
        barGraphSeriesOptions.hatchPattern = hatchPattern
        scatterPlotSeriesOptions.scatterPattern = scatterPattern
    }
    public init(pairs : [Pair<T,U>],
                label l: String,
                color c: Color = Color.lightBlue,
                hatchPattern: BarGraphSeriesOptions.Hatching = .none,
                scatterPattern: ScatterPlotSeriesOptions.ScatterPattern = .circle){
        self.pairs = pairs
        label = l
        color = c
        barGraphSeriesOptions.hatchPattern = hatchPattern
        scatterPlotSeriesOptions.scatterPattern = scatterPattern
    }
}
