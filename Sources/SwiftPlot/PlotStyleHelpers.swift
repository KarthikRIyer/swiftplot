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

public enum Direction {
    case north
    case east
    case south
    case west
}

public protocol AnchorableAnnotation : Annotation {
    var direction: Direction { get set }
    var margin: Float { get set }
    mutating func resolve(renderer: Renderer, center: Point)
}

struct Box: Annotation, AnchorableAnnotation {
    public var color = Color.black
    public var location = Point(0.0, 0.0)
    public var size = Size(width: 0.0, height: 0.0)
    public var direction  = Direction.north
    public var margin: Float = 5
    public mutating func resolve(renderer: Renderer, center: Point) {
        switch(direction) {
            case .north:
                location = Point(center.x - size.width/2, center.y + margin)
            case .east:
                location = Point(center.x + margin, center.y - size.height/2)
            case .south:
                location = Point(center.x - size.width/2, center.y - size.height - margin)
            case .west:
                location = Point(center.x - size.width - margin, center.y - size.height/2)
        }
    }
    public func draw(renderer: Renderer) {
        renderer.drawSolidRect(Rect(origin: location, size: size),
                               fillColor: color,
                               hatchPattern: .none)
    }
    public init(color: Color = .black, location: Point = Point(0.0, 0.0), size: Size = Size(width: 0.0, height: 0.0), direction: Direction = .north, margin: Float = 5) {
        self.color = color
        self.location = location
        self.size = size
        self.direction = direction
        self.margin = margin
    }
}

struct Text : Annotation, AnchorableAnnotation {
    public var text = ""
    public var color = Color.black
    public var size: Float = 15
    public var location = Point(0.0, 0.0)
    public var boundingBox: Box?
    public var borderWidth: Float = 5
    public var direction  = Direction.north
    public var margin: Float = 5
    public mutating func resolve(renderer: Renderer, center: Point) {
        let width = renderer.getTextWidth(text: text, textSize: size)
        switch(direction) {
            case .north:
                location = Point(center.x - width/2, center.y + margin)
            case .east:
                location = Point(center.x + margin, center.y - size/2)
            case .south:
                location = Point(center.x - width/2, center.y - size - margin)
            case .west:
                location = Point(center.x - width - margin, center.y - size/2)
        }
    }
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
    public init(text: String = "", color: Color = .black, size: Float = 15, location: Point = Point(0.0, 0.0), boundingBox: Box? = nil, borderWidth: Float = 5, direction: Direction = .north, margin: Float = 5) {
        self.text = text
        self.color = color
        self.size = size
        self.location = location
        self.boundingBox = boundingBox
        self.borderWidth = borderWidth
        self.direction = direction
        self.margin = margin
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
    public var overrideAnchor: Bool = false
    public mutating func draw(renderer: Renderer) {
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
        if var startAnchor = startAnnotation as? AnchorableAnnotation {
            if !overrideAnchor {
                // Calculate anchor point
                var startAnchorPoint = start + Point(0.0, strokeWidth/2)
                let startAnchorRotateAngle = -atan2(end.x - start.x, end.y - start.y)
                startAnchorPoint = rotatePoint(point: startAnchorPoint, center: start, angleRadians: startAnchorRotateAngle + 0.5 * Float.pi)
                startAnchor.resolve(renderer: renderer, center: startAnchorPoint)
            }
            startAnchor.draw(renderer: renderer)
        }
        else {
            startAnnotation?.draw(renderer: renderer)
        }
        if var endAnchor = endAnnotation as? AnchorableAnnotation {
            if !overrideAnchor {
                // Calculate anchor point
                var endAnchorPoint = end + Point(0.0, strokeWidth/2)
                let endAnchorRotateAngle = -atan2(start.x - end.x, start.y - end.y)
                endAnchorPoint = rotatePoint(point: endAnchorPoint, center: end, angleRadians: endAnchorRotateAngle + 0.5 * Float.pi)
                endAnchor.resolve(renderer: renderer, center: endAnchorPoint)
            }
            endAnchor.draw(renderer: renderer)
        }
        else {
            endAnnotation?.draw(renderer: renderer)
        }
    }
    public init(color: Color = .black, start: Point = Point(0.0, 0.0), end: Point = Point(0.0, 0.0), strokeWidth: Float = 5, headLength: Float = 10, headAngle: Float = 20, isDashed: Bool = false, isFilled: Bool = false, startAnnotation: Annotation? = nil, endAnnotation: Annotation? = nil, overrideAnchor: Bool = false) {
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
        self.overrideAnchor = overrideAnchor
    }
}
