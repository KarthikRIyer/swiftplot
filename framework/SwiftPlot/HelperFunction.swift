import Foundation

public func clamp<T>(_ value: T, minValue: T, maxValue: T) -> T where T: Comparable {
    return min(max(value, minValue), maxValue)
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

public func getMaxX<T>(pairs : [Pair<FloatConvertible,T>]) -> Float {
    var max = Float(pairs[0].x)
    for index in 1..<pairs.count {
        if (Float(pairs[index].x) > max) {
            max = Float(pairs[index].x)
        }
    }
    return max
}

public func getMaxY<T>(pairs: [Pair<T,FloatConvertible>]) -> Float {
    var max = Float(pairs[0].y)
    for index in 1..<pairs.count {
        if (Float(pairs[index].y) > max) {
            max = Float(pairs[index].y)
        }
    }
    return max
}

public func getMinX<T>(pairs: [Pair<FloatConvertible,T>]) -> Float {
    var min = Float(pairs[0].x)
    for index in 1..<pairs.count {
        if (Float(pairs[index].x) < min) {
            min = Float(pairs[index].x)
        }
    }
    return min
}

public func getMinY<T>(pairs: [Pair<T,FloatConvertible>]) -> Float {
    var min = Float(pairs[0].y)
    for index in 1..<pairs.count {
        if (Float(pairs[index].y) < min) {
            min = Float(pairs[index].y)
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

public func rotatePoint(point: Pair<FloatConvertible,FloatConvertible>,
                        center: Pair<FloatConvertible,FloatConvertible>,
                        angleDegrees: Float) -> Pair<FloatConvertible,FloatConvertible>{
    let angle = angleDegrees * .pi/180.0
    let s = sin(angle)
    let c = cos(angle)
    var rotatedPoint = Pair<FloatConvertible,FloatConvertible>(Float(point.x), Float(point.y))
    rotatedPoint = Pair<FloatConvertible,FloatConvertible>(Float(rotatedPoint.x) - Float(center.x),
                                                           Float(rotatedPoint.y) - Float(center.y))
    let xNew = Float(rotatedPoint.x) * c - Float(rotatedPoint.y) * s
    let yNew = Float(rotatedPoint.x) * s + Float(rotatedPoint.y) * c
    rotatedPoint = Pair<FloatConvertible,FloatConvertible>(xNew + Float(center.x),
                                                           yNew + Float(center.y))
    return rotatedPoint
}

public func rotatePoint(point: Pair<FloatConvertible,FloatConvertible>,
                        center: Pair<FloatConvertible,FloatConvertible>,
                        angleRadians: Float) -> Pair<FloatConvertible,FloatConvertible>{
    let s = sin(angleRadians)
    let c = cos(angleRadians)
    var rotatedPoint = Pair<FloatConvertible,FloatConvertible>(Float(point.x), Float(point.y))
    rotatedPoint = Pair<FloatConvertible,FloatConvertible>(Float(rotatedPoint.x) - Float(center.x),
                                                           Float(rotatedPoint.y) - Float(center.y))
    let xNew = Float(rotatedPoint.x) * c - Float(rotatedPoint.y) * s
    let yNew = Float(rotatedPoint.x) * s + Float(rotatedPoint.y) * c
    rotatedPoint = Pair<FloatConvertible,FloatConvertible>(xNew + Float(center.x),
                                                           yNew + Float(center.y))
    return rotatedPoint
}
