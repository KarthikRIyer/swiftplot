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
    public func draw(renderer: Renderer) {
        renderer.drawText(text: text,
                          location: location,
                          textSize: size,
                          color: color,
                          strokeWidth: 1.2,
                          angle: 0)
    }
    public init(text: String = "", color: Color = .black, size: Float = 15, location: Point = Point(0.0, 0.0)) {
        self.text = text
        self.color = color
        self.size = size
        self.location = location
    }
}

struct Arrow : Annotation {
    public var color = Color.black
    public var start = Point(0.0, 0.0)
    public var end = Point(0.0, 0.0)
    public var width: Float = 5
    public var headLength: Float = 10
    public var headAngle: Float = 15
    public func draw(renderer: Renderer) {
        // Draws arrow body.
        renderer.drawLine(startPoint: start,
                          endPoint: end,
                          strokeWidth: width,
                          strokeColor: color,
                          isDashed: false)

        // Calculates arrow head points.
        var p1 = start + Point(cos(headAngle)*headLength, sin(headAngle)*headLength)
        var p2 = start + Point(cos(headAngle)*headLength, -sin(headAngle)*headLength)

        let rotateAngle = -atan2(end.x - start.x, end.y - start.y)
        p1 = rotatePoint(point: p1, center: start, angleRadians: rotateAngle + 0.5 * Float.pi)
        p2 = rotatePoint(point: p2, center: start, angleRadians: rotateAngle + 0.5 * Float.pi)

        // Draws arrow head points.
        renderer.drawLine(startPoint: start,
                          endPoint: p1,
                          strokeWidth: width,
                          strokeColor: color,
                          isDashed: false)
        renderer.drawLine(startPoint: start,
                          endPoint: p2,
                          strokeWidth: width,
                          strokeColor: color,
                          isDashed: false)
    }
    public init(color: Color = .black, start: Point = Point(0.0, 0.0), end: Point = Point(0.0, 0.0), width: Float = 5, headLength: Float = 10, headAngle: Float = 15) {
        self.color = color
        self.start = start
        self.end = end
        self.width = width
        self.headLength = headLength
        self.headAngle = headAngle * Float.pi / 180
    }
}
