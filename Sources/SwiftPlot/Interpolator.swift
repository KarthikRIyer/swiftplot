
/// An `Interpolator` maps values to a continuum between 0 and 1
public struct Interpolator<Element> {
  public var compare: (Element, Element) -> Bool
  public var interpolate: (Element, Element, Element) -> Float
  
  public init(
    compare areInIncreasingOrder: @escaping (Element, Element) -> Bool,
    interpolate: @escaping (Element, Element, Element)->Float
  ) {
    self.compare = areInIncreasingOrder
    self.interpolate = interpolate
  }
}

extension Interpolator {
  
  public var inverted: Interpolator<Element> {
    Interpolator(
      compare: { self.compare($0, $1) },
      interpolate: { 1 - self.interpolate($0, $1, $2) }
    )
  }
}

extension Interpolator where Element: Comparable {
  public init(interpolate: @escaping (Element, Element, Element)->Float) {
    self.init(compare: <, interpolate: interpolate)
  }
}

// Linear mapping for numeric types.

extension Interpolator where Element: FloatConvertible {
  public static var linear: Interpolator {
    Interpolator { value, min, max in
      let value = Float(value)
      let range = Float(min)...Float(max)
      let totalDistance = range.lowerBound.distance(to: range.upperBound)
      let valueOffset   = range.lowerBound.distance(to: value)
      return valueOffset/totalDistance
    }
  }
}
extension Interpolator where Element: FixedWidthInteger {
  public static var linear: Interpolator {
    Interpolator { value, min, max in
      let distance = min.distance(to: max)
      let valDist = min.distance(to: value)
      return Float(valDist)/Float(distance)
    }
  }
}

// Mapping by key-paths.

extension Interpolator {
  
  public static func linearByKeyPath<T>(_ kp: KeyPath<Element, T>) -> Interpolator<Element>
    where T: FloatConvertible {
      let i = Interpolator<T>.linear
      return Interpolator(
        compare: { $0[keyPath: kp] < $1[keyPath: kp] },
        interpolate: { value, min, max in
          return i.interpolate(value[keyPath: kp], min[keyPath: kp], max[keyPath: kp])
      })
  }
  
  public static func linearByKeyPath<T>(_ kp: KeyPath<Element, T>) -> Interpolator<Element>
    where T: FixedWidthInteger {
      let i = Interpolator<T>.linear
      return Interpolator(
        compare: { $0[keyPath: kp] < $1[keyPath: kp] },
        interpolate: { value, min, max in
          return i.interpolate(value[keyPath: kp], min[keyPath: kp], max[keyPath: kp])
      })
  }
  
}
