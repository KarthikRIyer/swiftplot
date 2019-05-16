import Util
public protocol Renderer {

  mutating func drawRect(topLeftPoint p1 : Point, topRightPoint p2 : Point, bottomRightPoint p3 : Point, bottomLeftPoint p4 : Point, strokeWidth thickness : Float, strokeColor strokeColor : Color)
  mutating func drawSolidRect(topLeftPoint p1 : Point, topRightPoint p2 : Point, bottomRightPoint p3 : Point, bottomLeftPoint p4 : Point, fillColor fillColor : Color)
  mutating func drawLine(startPoint p1 : Point, endPoint p2 : Point, strokeWidth thickness : Float, strokeColor strokeColor : Color)
  mutating func drawTransformedLine(startPoint p1 : Point, endPoint p2 : Point, strokeWidth thickness : Float, strokeColor strokeColor : Color)
  mutating func drawPlotLines(points p : [Point], strokeWidth thickness : Float, strokeColor strokeColor : Color)
  mutating func drawText(text s : String, location p : Point, textSize size : Float, strokeWidth thickness : Float)
  mutating func drawTransformedText(text s : String, location p : Point, textSize size : Float, strokeWidth thickness : Float, angle angle : Float)
  mutating func drawRotatedText(text s : String, location p : Point, textSize size : Float, strokeWidth thickness : Float, angle angle : Float)
  mutating func drawSolidRectWithBorder(topLeftPoint p1 : Point,topRightPoint p2 : Point,bottomRightPoint p3 : Point,bottomLeftPoint p4 : Point, strokeWidth thickness : Float, fillColor fillColor : Color, borderColor borderColor : Color)
  func getTextWidth(text text : String, textSize size : Float) -> Float
  mutating func drawOutput(fileName name : String)

}
