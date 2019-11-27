public struct PlotLabel{
    public var xLabel = "X-Axis"
    public var yLabel = "Y-Axis"
    public var color = Color.black
    public var size: Float = 15
    public init(xLabel: String, yLabel: String, labelSize: Float = 15) {
      self.xLabel = xLabel
      self.yLabel = yLabel
      self.size = labelSize
    }
}
