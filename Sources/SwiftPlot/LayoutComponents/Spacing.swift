
/// A `LayoutComponent` wrapper which adds padding to an internal `LayoutComponent`
///
private struct _Padded<T: LayoutComponent>: LayoutComponent {
    var base: T
    var padding: EdgeComponents<Float> = .zero
    
    func measure(edge: RectEdge, _ renderer: Renderer) -> Size {
        var size = base.measure(edge: edge, renderer)
        size.width  += padding.left + padding.right
        size.height += padding.top + padding.bottom
        return size
    }
    func draw(_ rect: Rect, measuredSize: Size, edge: RectEdge, renderer: Renderer) {
        var adjustedMeasuredSize = measuredSize
        adjustedMeasuredSize.width  -= padding.left + padding.right
        adjustedMeasuredSize.height -= padding.top + padding.bottom
        let adjustedRect = rect.inset(by: padding)
        base.draw(adjustedRect, measuredSize: adjustedMeasuredSize, edge: edge, renderer: renderer)
    }
}
extension LayoutComponent {
    
    /// Returns a new `LayoutComponent` which adds the given padding to this `LayoutComponent`.
    ///
    public func padding(_ padding: EdgeComponents<Float>) -> LayoutComponent {
        return _Padded(base: self, padding: padding)
    }
}

struct FixedSpace: LayoutComponent {
    var size: Float
    func measure(edge: RectEdge, _ renderer: Renderer) -> Size {
        if edge.isHorizontal {
            // Only the height is important, so we can say width = 1.
            return Size(width: 1, height: size)
        } else {
            return Size(width: size, height: 1)
        }
    }
    func draw(_ rect: Rect, measuredSize: Size, edge: RectEdge, renderer: Renderer) { }
}
