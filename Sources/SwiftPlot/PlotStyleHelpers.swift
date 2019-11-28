import Foundation

public struct PlotBorder {
    public var color = Color.black
    public var thickness: Float = 2
    public init() {}
}

public struct PlotTitle {
    public var title = "TITLE"
    public var color = Color.black
    public var size: Float = 20
    public init(_ title: String = "TITLE") {
      self.title = title
    }
}

extension PlotTitle: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

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

public struct PlotLegend {
    public var backgroundColor = Color.transluscentWhite
    public var borderColor = Color.black
    public var borderThickness: Float = 2
    public var textColor = Color.black
    public var textSize: Float = 10
    public init() {}
}
