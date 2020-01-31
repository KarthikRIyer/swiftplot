
extension Mapping {
    
    /// An adapter which maps values to a continuum between 0 and 1
    ///
    public struct Heatmap<Element> {
        
        /// Returns whether or not the two elements are in increasing order.
        ///
        public var compare: (Element, Element) -> Bool
        
        /// Maps a value to an offset within an overall value space.
        ///
        /// - parameters:
        ///		- value:		The value to map. Must be within `lowerBound...upperBound`.
        ///		- lowerBound:	The lower bound of the value space. Must be `<= upperBound`.
        ///		- upperBound:	The upper bound of the value space.
        ///	- returns:			The value's offset within the value space.
        ///
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

extension Mapping.Heatmap where Element: Comparable {
  public init(interpolate: @escaping (Element, Element, Element)->Float) {
    self.init(compare: <, interpolate: interpolate)
  }
}

// Linear mapping for numeric types.

/// ** For internal use only **
///
/// Swift doesn't have constraint aliases. However, we can emulate it with a generic typealias:
///  ```
///  typealias IsInteger<T> = T where T: X, T.Element == Y,...
///  ```
///
/// and to use it, we use a constraint that `IsInteger<X>:Any`:
///  ```
///  func doThing<Number>(_: Number) where IsInteger<Number>: Any
///  ```
///
public enum HeatmapConstraints {
    public typealias IsFloat<T> = T where T: Strideable, T.Stride: BinaryFloatingPoint
    public typealias IsInteger<T> = T where T: FixedWidthInteger
}

extension Mapping.Heatmap where HeatmapConstraints.IsFloat<Element>: Any {
    public static var linear: Self {
        Self { value, min, max in
            let totalDistance = min.distance(to: max)
            let valueOffset   = min.distance(to: value)
            guard totalDistance != 0 else { return 0 } // value == min == max
            return Float(valueOffset/totalDistance)
        }
    }
}
extension Mapping.Heatmap where HeatmapConstraints.IsInteger<Element>: Any {
    public static var linear: Self {
        Self { value, min, max in
            let totalDistance = min.distance(to: max)
            let valueOffset   = min.distance(to: value)
            guard totalDistance != 0 else { return 0 } // value == min == max
            return Float(valueOffset)/Float(totalDistance)
        }
    }
}

// Mapping by key-paths.

extension Mapping.Heatmap {
    
    public static func keyPath<T>(_ kp: KeyPath<Element, T>) -> Mapping.Heatmap<Element>
        where HeatmapConstraints.IsFloat<T>: Any {
            let i = Mapping.Heatmap<T>.linear
            return Mapping.Heatmap(
                compare: { $0[keyPath: kp] < $1[keyPath: kp] },
                interpolate: { value, min, max in
                    return i.interpolate(value[keyPath: kp], min[keyPath: kp], max[keyPath: kp])
            })
    }
    
    public static func keyPath<T>(_ kp: KeyPath<Element, T>) -> Mapping.Heatmap<Element>
        where HeatmapConstraints.IsInteger<T>: Any {
            let i = Mapping.Heatmap<T>.linear
            return Mapping.Heatmap(
                compare: { $0[keyPath: kp] < $1[keyPath: kp] },
                interpolate: { value, min, max in
                    return i.interpolate(value[keyPath: kp], min[keyPath: kp], max[keyPath: kp])
            })
    }
    
}


extension Mapping.Heatmap {
    
    public var inverted: Self {
        Self(
            compare: { self.compare($0, $1) },
            interpolate: { 1 - self.interpolate($0, $1, $2) }
        )
    }
}
