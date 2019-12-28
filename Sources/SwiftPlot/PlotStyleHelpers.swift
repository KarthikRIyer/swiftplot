import Foundation

public struct PlotBorder {
    public var color = Color.black
    public var thickness: Float = 2
    public init() {}
}

public struct Grid {
    public var color = Color.gray
    public var thickness: Float = 0.5
}

public struct PlotTitle {
    public var title = ""
    public var color = Color.black
    public var size: Float = 20
    public init(_ title: String = "") {
      self.title = title
    }
}

public struct PlotLabel {
    public var xLabel = ""
    public var yLabel = ""
    public var y2Label = ""
    public var color = Color.black
    public var size: Float = 15
    public init(xLabel: String = "", yLabel: String = "", y2Label: String = "", labelSize: Float = 15) {
      self.xLabel = xLabel
      self.yLabel = yLabel
      self.y2Label = y2Label
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

public protocol Annotation {
    func draw(renderer: Renderer)
}

struct Text : Annotation {
    public var text = ""
    public var color = Color.black
    public var size: Float = 15
    public var location = Point(0.0, 0.0)
    public var drawBackgroundRect: Bool = false
    public var backgroundRectBorderSize: Float = 5
    public var backgroundRectColor = Color.white
    public func draw(renderer: Renderer){
        if drawBackgroundRect {
            var backgroundRectSize = renderer.getTextLayoutSize(text: text, textSize: size)
            backgroundRectSize.width += 2 * backgroundRectBorderSize
            backgroundRectSize.height += 2 * backgroundRectBorderSize
            let backgroundRectRect = Rect(origin: Point(location.x - backgroundRectBorderSize, location.y - backgroundRectBorderSize),
                            size: backgroundRectSize)
            renderer.drawSolidRect(backgroundRectRect,
                                   fillColor: backgroundRectColor,
                                   hatchPattern: .none)
        }
        renderer.drawText(text: text,
                          location: location,
                          textSize: size,
                          color: color,
                          strokeWidth: 1.2,
                          angle: 0)
    }
    public init(text: String = "", color: Color = .black, size: Float = 15, location: Point = Point(0.0, 0.0), drawBackgroundRect: Bool = false, backgroundRectBorderSize: Float = 5, backgroundRectColor: Color = .white) {
        self.text = text
        self.color = color
        self.size = size
        self.location = location
        self.drawBackgroundRect = drawBackgroundRect
        self.backgroundRectBorderSize = backgroundRectBorderSize
        self.backgroundRectColor = backgroundRectColor
    }
}
