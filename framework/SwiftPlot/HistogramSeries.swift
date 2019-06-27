public class HistogramSeries {
  public var data = [Float]()
  public var bins: Int = 0
  public var binFrequency = [Int]()
  public var scaledBinFrequency = [Float]()
  public var maximumFrequency: Int = 0
  public var minimumX: Float = 0
  public var maximumX: Float = 0
  public var binInterval: Float = 0
  public var label = ""
  public var color: Color = .lightBlue
  public init() {}
  public init(data: [Float], bins: Int, label: String, color: Color) {
    self.data = data
    self.bins = bins
    self.label = label
    self.color = color
    self.data.sort()
    minimumX = roundFloor10(self.data[0])
    maximumX = roundCeil10(self.data[data.count-1])
    binInterval = (maximumX-minimumX)/Float(bins)
    var dataIndex: Int = 0
    var binStart: Float = minimumX
    var binEnd: Float = minimumX + binInterval
    for _ in 1...bins {
      var count: Int = 0
      while (dataIndex<self.data.count && self.data[dataIndex] >= binStart && self.data[dataIndex] < binEnd) {
        count+=1
        dataIndex+=1
      }
      if (count > maximumFrequency) {
        maximumFrequency = count
      }
      binFrequency.append(count)
      binStart+=binInterval
      binEnd+=binInterval
    }
  }
}
