// struct defining a data series
public struct Series<T,U> {
    public var barGraphSeriesOptions = BarGraphSeriesOptions()
    public var scatterPlotSeriesOptions = ScatterPlotSeriesOptions()
    public var values = [Pair<T,U>]()
    public var label = "Plot"
    public var color : Color = .blue
    public var startColor: Color? = nil
    public var endColor: Color? = nil
    public var count: Int {
        get {
          return values.count
        }
    }
    public init() {}
    public init(values: [Pair<T,U>],
                label: String,
                startColor: Color = .lightBlue,
                endColor: Color = .lightBlue,
                hatchPattern: BarGraphSeriesOptions.Hatching = .none,
                scatterPattern: ScatterPlotSeriesOptions.ScatterPattern = .circle){
        self.values = values
        self.label = label
        self.startColor = startColor
        self.endColor = endColor
        barGraphSeriesOptions.hatchPattern = hatchPattern
        scatterPlotSeriesOptions.scatterPattern = scatterPattern
    }
    public init(values: [Pair<T,U>],
                label: String,
                color: Color = .lightBlue,
                hatchPattern: BarGraphSeriesOptions.Hatching = .none,
                scatterPattern: ScatterPlotSeriesOptions.ScatterPattern = .circle){
        self.values = values
        self.label = label
        self.color = color
        barGraphSeriesOptions.hatchPattern = hatchPattern
        scatterPlotSeriesOptions.scatterPattern = scatterPattern
    }
    subscript(index: Int) -> Pair<T,U> {
        return values[index]
    }
}
