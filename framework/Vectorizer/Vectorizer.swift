public var RENDERER_AGG : Int = 0
public var RENDERER_SVG : Int = 1

public class Vectorizer {

  var w : Float
  var h : Float

  var agg_vectorizer : AGGVectorizer?
  var svg_vectorizer : SVGVectorizer?

  public var renderer = RENDERER_AGG

  public func setRenderer(renderer r: Int) {
    switch r {
      case RENDERER_AGG:
        renderer = RENDERER_AGG
        agg_vectorizer = AGGVectorizer(width : w, height : h)
      case RENDERER_SVG:
        renderer = RENDERER_SVG
        svg_vectorizer = SVGVectorizer(width : w, height : h)
      default:
        renderer = RENDERER_AGG
        agg_vectorizer = AGGVectorizer(width : w, height : h)
    }
  }


  public init(renderer r : Int = 0, width w : Float, height h : Float) {
    self.w = w
    self.h = h
    setRenderer(renderer : r)
  }

  public func drawRect(_ p1 : Point,_ p2 : Point,_ p3 : Point,_ p4 : Point, _ thickness : Float){
    switch renderer {
      case RENDERER_AGG:
        agg_vectorizer!.drawRect(p1, p2, p3, p4, thickness)
      case RENDERER_SVG:
        svg_vectorizer!.drawRect(p1, p2, p3, p4, thickness)
      default:
        agg_vectorizer!.drawRect(p1, p2, p3, p4, thickness)
    }
  }

  public func drawLine(_ p1 : Point, _ p2 : Point, _ thickness : Float){
    switch renderer {
      case RENDERER_AGG:
        agg_vectorizer!.drawLine(p1, p2, thickness)
      case RENDERER_SVG:
        svg_vectorizer!.drawLine(p1, p2, thickness)
      default:
        agg_vectorizer!.drawLine(p1, p2, thickness)
    }
  }

  public func drawTransformedLine(_ p1 : Point, _ p2 : Point, _ thickness : Float){
    switch renderer {
      case RENDERER_AGG:
        agg_vectorizer!.drawTransformedLine(p1, p2, thickness)
      case RENDERER_SVG:
        svg_vectorizer!.drawTransformedLine(p1, p2, thickness)
      default:
        agg_vectorizer!.drawTransformedLine(p1, p2, thickness)
    }
  }

  public func drawPlotLines(_ p : [Point], _ thickness : Float, _ c : Color){
    switch renderer {
      case RENDERER_AGG:
        agg_vectorizer!.drawPlotLines(p, thickness, c)
      case RENDERER_SVG:
        svg_vectorizer!.drawPlotLines(p, thickness, c)
      default:
        agg_vectorizer!.drawPlotLines(p, thickness, c)
    }
  }

  public func drawText(_ s : String, _ p : Point, _ size : Float, _ thickness : Float){
    switch renderer {
      case RENDERER_AGG:
        agg_vectorizer!.drawText(s, p, size, thickness)
      case RENDERER_SVG:
        svg_vectorizer!.drawText(s, p, size, thickness)
      default:
        agg_vectorizer!.drawText(s, p, size, thickness)
    }
  }

  public func drawTransformedText(_ s : String, _ p : Point, _ size : Float, _ thickness : Float){
    switch renderer {
      case RENDERER_AGG:
        agg_vectorizer!.drawTransformedText(s, p, size, thickness)
      case RENDERER_SVG:
        svg_vectorizer!.drawTransformedText(s, p, size, thickness)
      default:
        agg_vectorizer!.drawTransformedText(s, p, size, thickness)
    }
  }

  public func drawRotatedText(_ s : String, _ p : Point, _ size : Float, _ thickness : Float,_ angle : Float){
    switch renderer {
      case RENDERER_AGG:
        agg_vectorizer!.drawRotatedText(s, p, size, thickness, angle)
      case RENDERER_SVG:
        svg_vectorizer!.drawRotatedText(s, p, size, thickness, angle)
      default:
        agg_vectorizer!.drawRotatedText(s, p, size, thickness, angle)
    }
  }

  public func drawSolidRect(_ p1 : Point,_ p2 : Point,_ p3 : Point,_ p4 : Point,_ c : Color){
    switch renderer {
      case RENDERER_AGG:
        agg_vectorizer!.drawSolidRect(p1, p2, p3, p4, c)
      case RENDERER_SVG:
        svg_vectorizer!.drawSolidRect(p1, p2, p3, p4, c)
      default:
        agg_vectorizer!.drawSolidRect(p1, p2, p3, p4, c)
    }
  }

  public func drawSolidRectWithBorder(_ p1 : Point,_ p2 : Point,_ p3 : Point,_ p4 : Point, _ thickness : Float, _ c : Color){
    switch renderer {
      case RENDERER_AGG:
        agg_vectorizer!.drawSolidRectWithBorder(p1, p2, p3, p4, thickness, c)
      case RENDERER_SVG:
        svg_vectorizer!.drawSolidRectWithBorder(p1, p2, p3, p4, thickness, c)
      default:
        agg_vectorizer!.drawSolidRectWithBorder(p1, p2, p3, p4, thickness, c)
    }
  }

  public func getTextWidth(_ text : String, _ size : Float) -> Float{
    switch renderer {
      case RENDERER_AGG:
        return agg_vectorizer!.getTextWidth(text, size)
      case RENDERER_SVG:
        return svg_vectorizer!.getTextWidth(text, size)
      default:
        return agg_vectorizer!.getTextWidth(text, size)
    }
  }

  public func savePlotImage(_ name : String){
    switch renderer {
      case RENDERER_AGG:
        agg_vectorizer!.savePlotImage(name)
      case RENDERER_SVG:
        svg_vectorizer!.savePlotImage(name)
      default:
        agg_vectorizer!.savePlotImage(name)
    }
  }
}
