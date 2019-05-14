protocol VectorizerProtocol {

  func drawRect(_ p1 : Point,_ p2 : Point,_ p3 : Point,_ p4 : Point, _ thickness : Float)
  func drawLine(_ p1 : Point, _ p2 : Point, _ thickness : Float)
  func drawTransformedLine(_ p1 : Point, _ p2 : Point, _ thickness : Float)
  func drawPlotLines(_ p : [Point], _ thickness : Float, _ c : Color)
  func drawText(_ s : String, _ p : Point, _ size : Float, _ thickness : Float)
  func drawTransformedText(_ s : String, _ p : Point, _ size : Float, _ thickness : Float)
  func drawRotatedText(_ s : String, _ p : Point, _ size : Float, _ thickness : Float,_ angle : Float)
  func drawSolidRect(_ p1 : Point,_ p2 : Point,_ p3 : Point,_ p4 : Point,_ c : Color)
  func drawSolidRectWithBorder(_ p1 : Point,_ p2 : Point,_ p3 : Point,_ p4 : Point, _ thickness : Float, _ c : Color)
  func getTextWidth(_ text : String, _ size : Float) -> Float
  func savePlotImage(_ name : String)

}
