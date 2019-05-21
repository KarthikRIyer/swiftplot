import Foundation
public func cap<T :Numeric & Comparable>(value v : T, min a : T, max b : T) -> T {
  var minimum : T = min(a,b)
  var maximum : T = max(a,b)
    if v >= maximum {
        return maximum
    }
    if v <= minimum {
        return minimum
    }
    return v
}
