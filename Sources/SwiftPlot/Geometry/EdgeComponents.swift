
/// A container which has a value at each `RectEdge`.
///
public struct EdgeComponents<T> {
    public var left: T
    public var top: T
    public var right: T
    public var bottom: T
    
    public subscript(edge: RectEdge) -> T {
        get {
            switch edge {
            case .left:   return left
            case .right:  return right
            case .top:    return top
            case .bottom: return bottom
            }
        }
        set {
            switch edge {
            case .left:   left = newValue
            case .right:  right = newValue
            case .top:    top = newValue
            case .bottom: bottom = newValue
            }
        }
    }
    
    /// Returns an `EdgeComponents` which has the given `value` on every edge.
    ///
    public static func all(_ value: T) -> EdgeComponents<T> {
        EdgeComponents(left: value, top: value, right: value, bottom: value)
    }
        
    /// Returns a new `EdgeComponents` by applying the given closure to each edge.
    ///
    public func mapByEdge<U>(_ block: (RectEdge, T) throws -> U) rethrows -> EdgeComponents<U> {
        EdgeComponents<U>(left: try block(.left, left), top: try block(.top, top),
                          right: try block(.right, right), bottom: try block(.bottom, bottom))
    }
    
    /// Returns a new `EdgeComponents` by applying the given closure to each edge.
    ///
    public func map<U>(_ block: (T) throws -> U) rethrows -> EdgeComponents<U> {
        try mapByEdge { _, val in try block(val) }
    }
}

extension EdgeComponents where T: ExpressibleByIntegerLiteral {
    public static var zero: Self { .all(0) }
}

extension EdgeComponents where T: RangeReplaceableCollection {
    public static var empty: Self {
        EdgeComponents(left: .init(), top: .init(), right: .init(), bottom: .init())
    }
}

extension Rect {
    public func inset(by insets: EdgeComponents<Float>) -> Rect {
        var rect = self
        rect.height -= insets.top + insets.bottom
        rect.width  -= insets.left + insets.right
        rect.origin.x += insets.left
        rect.origin.y += insets.bottom
        return rect
    }
}
