public struct PlotLabel{
    public var xLabel   : String = "X-Axis"
    public var yLabel   : String = "Y-Axis"
    public var labelSize : Float       = 10
    public var xLabelLocation : Pair<FloatConvertible,FloatConvertible> = zeroPair
    public var yLabelLocation : Pair<FloatConvertible,FloatConvertible> = zeroPair
    public init(xLabel: String, yLabel: String) {
      self.xLabel = xLabel
      self.yLabel = yLabel
    }
}
