public class HistogramSeries<T> {
    public var data = [T]()
    public var bins: Int = 0
    public var binFrequency = [Float]()
    public var scaledBinFrequency = [Float]()
    public var maximumFrequency: Float = 0
    public var minimumX: T?
    public var maximumX: T?
    public var binInterval: T?
    public var label = ""
    public var color: Color = .lightBlue
    public var histogramSeriesOptions = HistogramSeriesOptions()
    public var isNormalized = false
    public init() {}
    public init(data: [T],
                bins: Int,
                isNormalized: Bool,
                label: String,
                color: Color,
                histogramType: HistogramSeriesOptions.HistogramType,
                binFrequency: [Float],
                maximumFrequency: Float,
                minimumX: T,
                maximumX: T,
                binInterval: T) {
        self.data = data
        self.bins = bins
        self.isNormalized = isNormalized
        self.label = label
        self.color = color
        histogramSeriesOptions.histogramType = histogramType
        self.binFrequency = binFrequency
        self.maximumFrequency = maximumFrequency
        self.minimumX = minimumX
        self.maximumX = maximumX
        self.binInterval = binInterval
    }
    // public init(data: [T],
    //             bins: Int,
    //             isNormalized: Bool,
    //             label: String,
    //             color: Color,
    //             histogramType: HistogramSeriesOptions.HistogramType = .bar) {
    //     self.data = data
    //     self.bins = bins
    //     self.label = label
    //     self.color = color
    //     self.isNormalized = isNormalized
    //     histogramSeriesOptions.histogramType = histogramType
    //     self.data.sort()
    //     minimumX = roundFloor10(self.data[0])
    //     maximumX = roundCeil10(self.data[data.count-1])
    //     binInterval = (Float(maximumX)-Float(minimumX))/Float(bins)
    //     var dataIndex: Int = 0
    //     var binStart = Float(minimumX)
    //     var binEnd = Float(minimumX) + binInterval
    //     for _ in 1...bins {
    //         var count: Float = 0
    //         while (dataIndex<self.data.count && self.data[dataIndex] >= binStart && self.data[dataIndex] < binEnd) {
    //             count+=1
    //             dataIndex+=1
    //         }
    //         if (count > maximumFrequency) {
    //             maximumFrequency = count
    //         }
    //         binFrequency.append(count)
    //         binStart+=binInterval
    //         binEnd+=binInterval
    //     }
    //     if (isNormalized) {
    //         let factor = Float(self.data.count)*binInterval
    //         for index in 0..<bins {
    //             binFrequency[index]/=factor
    //         }
    //         maximumFrequency/=factor
    //     }
    // }
    // public func recalculateBins<T>(binStart: T,
    //                                binEnd: T,
    //                                binInterval: T) {
    //     binFrequency.removeAll()
    //     maximumFrequency = 0
    //     // TODO: Do this in better than O(n^2)
    //     for start in stride(from: binStart, through: binEnd, by: binInterval){
    //         let end = start + binInterval
    //         var count: Float = 0
    //         for d in data {
    //             if(d<end && d>=start) {
    //                 count += 1
    //             }
    //         }
    //         if (count > maximumFrequency) {
    //             maximumFrequency = count
    //         }
    //         binFrequency.append(count)
    //     }
    //     if (isNormalized) {
    //         let factor = Float(data.count)*binInterval
    //         for index in 0..<bins {
    //             binFrequency[index]/=factor
    //         }
    //         maximumFrequency/=factor
    //     }
    // }
}
