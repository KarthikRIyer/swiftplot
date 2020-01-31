
public struct Label: LayoutComponent {
    var text: String = ""
    var size: Float  = 12
    var color: Color = .black

    public func measure(edge: RectEdge, _ renderer: Renderer) -> Size {
        let hSize = renderer.getTextLayoutSize(text: text, textSize: size)
        return edge.isHorizontal ? hSize : hSize.swappingComponents()
    }
    public func draw(_ rect: Rect, measuredSize: Size, edge: RectEdge, renderer: Renderer) {
        var origin = rect.center + Point(-measuredSize.width/2, -measuredSize.height/2)
        let angle: Float
        if edge.isHorizontal {
            angle = 0
        } else {
            angle = 90
            origin += Point(rect.width, 0)
        }
        renderer.drawText(text: text, location: origin, textSize: size,
                          color: color, strokeWidth: 1.2, angle: angle)
    }
}
