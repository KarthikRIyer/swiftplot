import SVGRenderer

class SVGVectorizer {

  var svg_renderer : SVGRenderer

  var width : Float
  var height : Float

  init( width w : Float, height h : Float) {
    width = w
    height = h
    svg_renderer = SVGRenderer(width : w, height : h)
  }

  func drawRect(_ p1 : Point,_ p2 : Point,_ p3 : Point,_ p4 : Point, _ thickness : Float){
    var x = [Float]()
    var y = [Float]()

    x.append(p1.x)
    x.append(p2.x)
    x.append(p3.x)
    x.append(p4.x)
    y.append(p1.y)
    y.append(p2.y)
    y.append(p3.y)
    y.append(p4.y)

    svg_renderer.draw_rect(x, y, thickness)
  }

  func drawLine(_ p1 : Point, _ p2 : Point, _ thickness : Float){
    var x = [Float]()
    var y = [Float]()

    x.append(p1.x)
    x.append(p2.x)
    y.append(p1.y)
    y.append(p2.y)

    svg_renderer.draw_line(x, y, thickness)
  }

  func drawTransformedLine(_ p1 : Point, _ p2 : Point, _ thickness : Float){
    var x = [Float]()
    var y = [Float]()

    x.append(p1.x)
    x.append(p2.x)
    y.append(p1.y)
    y.append(p2.y)

    svg_renderer.draw_transformed_line(x, y, thickness)
  }

  func drawPlotLines(_ p : [Point], _ thickness : Float, _ c : Color){

    var x = [Float]()
    var y = [Float]()

    for index in 0..<p.count {
        x.append(p[index].x)
        y.append(p[index].y)
    }

    svg_renderer.draw_plot_lines(x, y, thickness, c.r, c.g, c.b, c.a)
  }

  func drawText(_ s : String, _ p : Point, _ size : Float, _ thickness : Float){
    svg_renderer.draw_text(s, p.x, p.y, size, thickness)
  }

  func drawTransformedText(_ s : String, _ p : Point, _ size : Float, _ thickness : Float){
    svg_renderer.draw_transformed_text(s, p.x, p.y, size, thickness)
  }

  func drawRotatedText(_ s : String, _ p : Point, _ size : Float, _ thickness : Float,_ angle : Float){
    svg_renderer.draw_rotated_text(s, p.x, p.y, size, thickness, angle)
  }

  func drawSolidRect(_ p1 : Point,_ p2 : Point,_ p3 : Point,_ p4 : Point,_ c : Color){
    var x = [Float]()
    var y = [Float]()

    x.append(p1.x)
    x.append(p2.x)
    x.append(p3.x)
    x.append(p4.x)
    y.append(p1.y)
    y.append(p2.y)
    y.append(p3.y)
    y.append(p4.y)

    svg_renderer.draw_solid_rect(x, y, c.r, c.g, c.b, c.a)
  }

  func drawSolidRectWithBorder(_ p1 : Point,_ p2 : Point,_ p3 : Point,_ p4 : Point, _ thickness : Float, _ c : Color){
    var x = [Float]()
    var y = [Float]()

    x.append(p1.x)
    x.append(p2.x)
    x.append(p3.x)
    x.append(p4.x)
    y.append(p1.y)
    y.append(p2.y)
    y.append(p3.y)
    y.append(p4.y)

    svg_renderer.draw_solid_rect(x, y, c.r, c.g, c.b, c.a)
    svg_renderer.draw_rect(x, y, thickness)
  }

  func getTextWidth(_ text : String, _ size : Float) -> Float{
    return svg_renderer.get_text_width(text, size);
  }

  func savePlotImage(_ name : String){
    svg_renderer.save_image(name)
  }

  ///////////////////////////////////////////////r//////////////////////////////////////////////////////////////////////////////////////


}
