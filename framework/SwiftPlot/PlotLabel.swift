public struct PlotLabel{
    public var xLabel   : String = "X-Axis"
    public var yLabel   : String = "Y-Axis"
    public var labelSize : Float       = 10
    public var xLabelLocation : Point = Point.zero
    public var yLabelLocation : Point = Point.zero
    public init(xLabel: String, yLabel: String) {
      self.xLabel = xLabel
      self.yLabel = yLabel
    }
}
