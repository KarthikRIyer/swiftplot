import Foundation

public func clamp<T>(_ value: T, minValue: T, maxValue: T) -> T where T: Comparable {
    return min(max(value, minValue), maxValue)
}

public func niceRoundFloor(_ value: Float) -> Float {
    return floor(value*pow(10, -floor(log10(value)))) / pow(10, -floor(log10(value)))
}

public func niceRoundCeil(_ value: Float) -> Float {
    return ceil(value*pow(10, -floor(log10(value)))) / pow(10, -floor(log10(value)))
}

public func niceRound(_ value: Float) -> Float {
    if (value>0) {
        return niceRoundCeil(value)
    }
    else {
        return -niceRoundFloor(-value)
    }
}

public func roundCeil10(_ value: Float) -> Float {
    return ceil(value/10)*10
}

public func roundFloor10(_ value: Float) -> Float {
    return floor(value/10)*10
}

public func getNumberOfDigits(_ n: Float) -> Int{
    var x: Int = Int(n)
    var count: Int = 0
    while (x != 0){
        x /= 10;
        count += 1
    }
    return count
}

public func maxX<T,U>(points: [Pair<T,U>]) -> T where T:Comparable {
    var max = points[0].x
    for index in 1..<points.count {
        if (points[index].x > max) {
            max = points[index].x
        }
    }
    return max
}

public func maxY<T,U>(points: [Pair<T,U>]) -> U where U:Comparable {
    var max = points[0].y
    for index in 1..<points.count {
        if (points[index].y > max) {
            max = points[index].y
        }
    }
    return max
}

public func minX<T,U>(points: [Pair<T,U>]) -> T where T:Comparable {
    var min = points[0].x
    for index in 1..<points.count {
        if (points[index].x < min) {
            min = points[index].x
        }
    }
    return min
}

public func minY<T,U>(points: [Pair<T,U>]) -> U where U:Comparable {
    var min = points[0].y
    for index in 1..<points.count {
        if (points[index].y < min) {
            min = points[index].y
        }
    }
    return min
}

public func lerp(_ minValue: Float, _ maxValue: Float, _ t: Float) -> Float {
    return ((1.0-t)*minValue + t*maxValue)
}

public func lerp(startColor: Color, endColor: Color, _ t: Float) -> Color {
    let tClamped = clamp(t, minValue: 0, maxValue: 1)
    let r = lerp(startColor.r, endColor.r, tClamped)
    let g = lerp(startColor.g, endColor.g, tClamped)
    let b = lerp(startColor.b, endColor.b, tClamped)
    let a = lerp(startColor.a, endColor.a, tClamped)
    return Color(r, g, b, a)
}

public func rotatePoint(point: Point,
                        center: Point,
                      angleDegrees: Float) -> Point{
    let angle = angleDegrees * .pi/180.0
    let s = sin(angle)
    let c = cos(angle)
    var rotatedPoint = Point(point.x, point.y)
    rotatedPoint = Point(rotatedPoint.x - center.x,
                         rotatedPoint.y - center.y)
    let xNew = rotatedPoint.x * c - rotatedPoint.y * s
    let yNew = rotatedPoint.x * s + rotatedPoint.y * c
    rotatedPoint = Point(xNew + center.x,
                         yNew + center.y)
    return rotatedPoint
}

public func rotatePoint(point: Point,
                        center: Point,
                      angleRadians: Float) -> Point{
    let s = sin(angleRadians)
    let c = cos(angleRadians)
    var rotatedPoint = Point(point.x, point.y)
    rotatedPoint = Point(rotatedPoint.x - center.x,
                         rotatedPoint.y - center.y)
    let xNew = rotatedPoint.x * c - rotatedPoint.y * s
    let yNew = rotatedPoint.x * s + rotatedPoint.y * c
    rotatedPoint = Point(xNew + center.x,
                         yNew + center.y)
    return rotatedPoint
}
