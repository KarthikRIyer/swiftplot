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
public func getMaxX(points p: [Point]) -> Float {
    var max = p[0].x
    for index in 1..<p.count {
        if (p[index].x > max) {
            max = p[index].x
        }
    }
    return max
}

public func getMaxY(points p: [Point]) -> Float {
    var max = p[0].y
    for index in 1..<p.count {
        if (p[index].y > max) {
            max = p[index].y
        }
    }
    return max
}

public func getMinX(points p: [Point]) -> Float {
    var min = p[0].x
    for index in 1..<p.count {
        if (p[index].x < min) {
            min = p[index].x
        }
    }
    return min
}

public func getMinY(points p: [Point]) -> Float {
    var min = p[0].y
    for index in 1..<p.count {
        if (p[index].y < min) {
            min = p[index].y
        }
    }
    return min
}
