
/// A visual element which occupies space in a layout object.
///
public protocol LayoutComponent {
    
    /// Returns the minimum size required to display this element.
    ///
    /// - parameters:
    ///        - edge:        The edge on which the element will be displayed.
    ///        - renderer:    The renderer which will be used to draw the element. Helpful for measuring text.
    /// - note: The return value's `width` and `height` always correspond to x and y distances, respectively.
    ///            Rectangular elements will want to swap their horizontal widths and heights when displayed on vertical edges.
    ///
    func measure(edge: RectEdge, _ renderer: Renderer) -> Size
    
    /// Draws the element in the given `Rect`.
    ///
    /// - parameters:
    ///        - rect:            The region to draw in.
    ///        - measuredSize:    The minimum size calculated by the last call to `measure`. Helpful if the size is expensive to calculate.
    ///     - edge:         The edge on which the element will be displayed.
    ///        - renderer:        The renderer to use when drawing the element.
    ///
    func draw(_ rect: Rect, measuredSize: Size, edge: RectEdge, renderer: Renderer)
}

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
