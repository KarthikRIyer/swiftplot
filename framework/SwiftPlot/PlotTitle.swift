public struct PlotTitle {
    public var title : String = "TITLE"
    public var titleLocation   : Pair<FloatConvertible,FloatConvertible> = zeroPair
    public var titleSize : Float = 15
    public init(_ title: String = "TITLE") {
      self.title = title
    }
}
