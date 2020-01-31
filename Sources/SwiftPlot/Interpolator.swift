
extension Adapters {
    
    /// An `Interpolator` maps values to a continuum between 0 and 1
    public struct Heatmap<Element> {
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
}

extension Adapters.Heatmap where Element: Comparable {
  public init(interpolate: @escaping (Element, Element, Element)->Float) {
    self.init(compare: <, interpolate: interpolate)
  }
}

// Linear mapping for numeric types.

extension Adapters.Heatmap where Element: Strideable, Element.Stride: BinaryFloatingPoint {
    public static var linear: Self {
        Self { value, min, max in
            let totalDistance = min.distance(to: max)
            let valueOffset   = min.distance(to: value)
            return Float(valueOffset/totalDistance)
        }
    }
}
extension Adapters.Heatmap where Element: FixedWidthInteger {
    public static var linear: Self {
        Self { value, min, max in
            let totalDistance = min.distance(to: max)
            let valueOffset   = min.distance(to: value)
            return Float(valueOffset)/Float(totalDistance)
        }
    }
}

// Mapping by key-paths.

extension Adapters.Heatmap {
    
    public static func keyPath<T>(_ kp: KeyPath<Element, T>) -> Adapters.Heatmap<Element>
        where T: Strideable, T.Stride: BinaryFloatingPoint {
            let i = Adapters.Heatmap<T>.linear
            return Adapters.Heatmap(
                compare: { $0[keyPath: kp] < $1[keyPath: kp] },
                interpolate: { value, min, max in
                    return i.interpolate(value[keyPath: kp], min[keyPath: kp], max[keyPath: kp])
            })
    }
    
    public static func keyPath<T>(_ kp: KeyPath<Element, T>) -> Adapters.Heatmap<Element>
        where T: FixedWidthInteger {
            let i = Adapters.Heatmap<T>.linear
            return Adapters.Heatmap(
                compare: { $0[keyPath: kp] < $1[keyPath: kp] },
                interpolate: { value, min, max in
                    return i.interpolate(value[keyPath: kp], min[keyPath: kp], max[keyPath: kp])
            })
    }
    
}


extension Adapters.Heatmap {
    
    public var inverted: Self {
        Self(
            compare: { self.compare($0, $1) },
            interpolate: { 1 - self.interpolate($0, $1, $2) }
        )
    }
}
