public class HistogramSeriesOptions {
    public enum HistogramType: CaseIterable{
        case bar
        case step
    }
    public var histogramType: HistogramType = .bar
    public init() {}
}
