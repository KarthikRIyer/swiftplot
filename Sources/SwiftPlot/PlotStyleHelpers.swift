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
    mutating func draw(renderer: Renderer)
}

struct Box: Annotation {
    public var color = Color.black
    public var location = Point(0.0, 0.0)
    public var size = Size(width: 0.0, height: 0.0)
    public func draw(renderer: Renderer) {
        renderer.drawSolidRect(Rect(origin: location, size: size),
                               fillColor: color,
                               hatchPattern: .none)
    }
    public init(color: Color = .black, location: Point = Point(0.0, 0.0), size: Size = Size(width: 0.0, height: 0.0)) {
        self.color = color
        self.location = location
        self.size = size
    }
}

struct Text : Annotation {
    public var text = ""
    public var color = Color.black
    public var size: Float = 15
    public var location = Point(0.0, 0.0)
    public var boundingBox: Box?
    public var borderWidth: Float = 5
    public mutating func draw(renderer: Renderer) {
        if boundingBox != nil {
            var bboxSize = renderer.getTextLayoutSize(text: text, textSize: size)
            bboxSize.width += 2 * borderWidth
            bboxSize.height += 2 * borderWidth
            boundingBox?.location = Point(location.x - borderWidth, location.y - borderWidth)
            boundingBox?.size = bboxSize
            boundingBox?.draw(renderer: renderer)
        }
        renderer.drawText(text: text,
                          location: location,
                          textSize: size,
                          color: color,
                          strokeWidth: 1.2,
                          angle: 0)
    }
    public init(text: String = "", color: Color = .black, size: Float = 15, location: Point = Point(0.0, 0.0), boundingBox: Box? = nil, borderWidth: Float = 5) {
        self.text = text
        self.color = color
        self.size = size
        self.location = location
        self.boundingBox = boundingBox
    }
}
