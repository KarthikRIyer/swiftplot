// struct defining a Pair
public struct Pair<T,U> {
    public var x: T
    public var y: U

    public init(_ x: T, _ y: U){
        self.x = x
        self.y = y
    }
}

public typealias Point = Pair<Float,Float>
public let zeroPoint = Point(0.0, 0.0)

public struct Size {
    public var width: Float
    public var height: Float
    
    public init(width: Float, height: Float) {
        self.width = width
        self.height = height
    }
}
extension Size {
    public static let zero = Size(width: 0, height: 0)
}

/// A Rectangle in a bottom-left coordinate space.
///
public struct Rect {
    public var origin: Point
    public var size: Size
    
    public init(origin: Point, size: Size) {
        self.origin = origin
        self.size = size
    }
}
extension Rect {
    
    public static let empty = Rect(origin: zeroPoint, size: .zero)
    
    public var normalized: Rect {
        let normalizedOrigin = Point(origin.x + (size.width < 0 ? size.width : 0),
                                     origin.y + (size.height < 0 ? size.height : 0))
        let normalizedSize = Size(width: abs(size.width), height: abs(size.height))
        return Rect(origin: normalizedOrigin, size: normalizedSize)
    }
    
    public var minX: Float {
        return normalized.origin.x
    }
    
    public var minY: Float {
        return normalized.origin.y
    }
    
    public var midX: Float {
        return origin.x + (size.width/2)
    }
    
    public var midY: Float {
        return origin.y + (size.height/2)
    }

    public var maxX: Float {
        let norm = normalized
        return norm.origin.x + norm.size.width
    }
    
    public var maxY: Float {
        let norm = normalized
        return norm.origin.y + norm.size.height
    }
    
    public init(size: Size, centeredOn center: Point) {
        self = Rect(
            origin: Point(center.x - size.width/2, center.y - size.height/2),
            size: size
        )
    }
}
