public class HistogramSeries<T> where T: Comparable {
    public var data = [T]() { didSet { isSorted = false } }
    /// `isSorted`: if `data` is in a sorted. Set to false if the user sets `data` manually.
    internal var isSorted: Bool = false
    public var bins: Int = 0
    public var label = ""
    public var color: Color = .lightBlue
    public var histogramSeriesOptions = HistogramSeriesOptions()
    public init() {}
    public init(data: [T],
                bins: Int,
                label: String,
                color: Color,
                histogramType: HistogramSeriesOptions.HistogramType) {
        self.data = data.sorted()
        self.isSorted = true
        self.bins = bins
        self.label = label
        self.color = color
        histogramSeriesOptions.histogramType = histogramType
    }
}
