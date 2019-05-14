import AGGRendererWrapper

class AGGVectorizer : VectorizerProtocol {

  var agg_renderer : UnsafeRawPointer

  var w : Float
  var h : Float

  init(width w : Float, height h : Float) {
    self.w = w
    self.h = h
    agg_renderer = UnsafeRawPointer(initializePlot(w, h))
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

    draw_rect(x, y, thickness, agg_renderer)
  }

  func drawLine(_ p1 : Point, _ p2 : Point, _ thickness : Float){
    var x = [Float]()
    var y = [Float]()

    x.append(p1.x)
    x.append(p2.x)
    y.append(p1.y)
    y.append(p2.y)

    draw_line(x, y, thickness, agg_renderer)
  }

  func drawTransformedLine(_ p1 : Point, _ p2 : Point, _ thickness : Float){
    var x = [Float]()
    var y = [Float]()

    x.append(p1.x)
    x.append(p2.x)
    y.append(p1.y)
    y.append(p2.y)

    draw_transformed_line(x, y, thickness, agg_renderer)
  }

  func drawPlotLines(_ p : [Point], _ thickness : Float, _ c : Color){
    var x = [Float]()
    var y = [Float]()

    for index in 0..<p.count {
        x.append(p[index].x)
        y.append(p[index].y)
    }

    draw_plot_lines(x, y, Int32(p.count), thickness, c.r, c.g, c.b, c.a, agg_renderer)
  }

  func drawText(_ s : String, _ p : Point, _ size : Float, _ thickness : Float){
    draw_text(s, p.x, p.y, size, thickness,agg_renderer)
  }

  func drawTransformedText(_ s : String, _ p : Point, _ size : Float, _ thickness : Float){
    draw_transformed_text(s, p.x, p.y, size, thickness,agg_renderer)
  }

  func drawRotatedText(_ s : String, _ p : Point, _ size : Float, _ thickness : Float,_ angle : Float){
    draw_rotated_text(s, p.x, p.y, size, thickness, angle, agg_renderer)
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

    draw_solid_rect(x, y, c.r, c.g, c.b, c.a, agg_renderer)
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

    draw_solid_rect(x, y, c.r, c.g, c.b, c.a, agg_renderer)
    draw_rect(x, y, thickness, agg_renderer)
  }

  func getTextWidth(_ text : String, _ size : Float) -> Float{
    return get_text_width(text, size, agg_renderer);
  }

  func savePlotImage(_ name : String){
    save_image(name, agg_renderer)
  }
}
