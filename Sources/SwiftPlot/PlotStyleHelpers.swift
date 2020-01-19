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

public struct Coordinate {
    public enum CoordinateSpace {
        case figurePoints
        case figureFraction
        case axesPoints
        case axesFraction
    }
    public var coordinateSpace: CoordinateSpace = .figurePoints
    public var point: Point = Point(0.0, 0.0)
}

public protocol CoordinateResolver {
	func resolve(_ coordinate: Coordinate) -> Point
}

public protocol Annotation {
    mutating func draw(resolver: CoordinateResolver, renderer: Renderer)
}

struct Box: Annotation {
    public var color = Color.black
    public var location = Point(0.0, 0.0)
    public var size = Size(width: 0.0, height: 0.0)
    public func draw(resolver: CoordinateResolver, renderer: Renderer) {
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
    public mutating func draw(resolver: CoordinateResolver, renderer: Renderer) {
        if boundingBox != nil {
            var bboxSize = renderer.getTextLayoutSize(text: text, textSize: size)
            bboxSize.width += 2 * borderWidth
            bboxSize.height += 2 * borderWidth
            boundingBox?.location = Point(location.x - borderWidth, location.y - borderWidth)
            boundingBox?.size = bboxSize
            boundingBox?.draw(resolver: resolver, renderer: renderer)
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
        self.borderWidth = borderWidth
    }
}

struct Arrow : Annotation {
    public var color = Color.black
    public var start = Point(0.0, 0.0)
    public var end = Point(0.0, 0.0)
    public var strokeWidth: Float = 5
    public var headLength: Float = 10
    public var headAngle: Float = 20
    public var isDashed: Bool = false
    public var isFilled: Bool = false
    public var startAnnotation: Annotation?
    public var endAnnotation: Annotation?
    public mutating func draw(resolver: CoordinateResolver, renderer: Renderer) {
        // Draws arrow body.
        renderer.drawPlotLines(points: [start, end],
                               strokeWidth: strokeWidth,
                               strokeColor: color,
                               isDashed: isDashed)

        // Calculates arrow head points.
        var p1 = end + Point(cos(headAngle)*headLength, sin(headAngle)*headLength)
        var p2 = end + Point(cos(headAngle)*headLength, -sin(headAngle)*headLength)
        let rotateAngle = -atan2(start.x - end.x, start.y - end.y)
        p1 = rotatePoint(point: p1, center: end, angleRadians: rotateAngle + 0.5 * Float.pi)
        p2 = rotatePoint(point: p2, center: end, angleRadians: rotateAngle + 0.5 * Float.pi)

        // Draws arrow head points.
        if isFilled {
            renderer.drawSolidPolygon(points: [p1, end, p2],
                                      fillColor: color)
        }
        else {
            renderer.drawPlotLines(points: [p1, end, p2],
                                   strokeWidth: strokeWidth,
                                   strokeColor: color,
                                   isDashed: false)
        }

        //Draws start and end annotations if specified.
        startAnnotation?.draw(resolver: resolver, renderer: renderer)
        endAnnotation?.draw(resolver: resolver, renderer: renderer)

    }
    public init(color: Color = .black, start: Point = Point(0.0, 0.0), end: Point = Point(0.0, 0.0), strokeWidth: Float = 5, headLength: Float = 10, headAngle: Float = 20, isDashed: Bool = false, isFilled: Bool = false, startAnnotation: Annotation? = nil, endAnnotation: Annotation? = nil) {
        self.color = color
        self.start = start
        self.end = end
        self.strokeWidth = strokeWidth
        self.headLength = headLength
        self.headAngle = headAngle * Float.pi / 180
        self.isDashed = isDashed
        self.isFilled = isFilled
        self.startAnnotation = startAnnotation
        self.endAnnotation = endAnnotation
    }
}
