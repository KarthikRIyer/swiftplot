import Util
public protocol Renderer: AnyObject{

	var xOffset: Float { get set }
	var yOffset: Float { get set }
	var plotDimensions: PlotDimensions { get set }

	func drawRect(topLeftPoint p1: Point, topRightPoint p2: Point, bottomRightPoint p3: Point, bottomLeftPoint p4: Point, strokeWidth thickness: Float, strokeColor: Color)
	func drawSolidRect(topLeftPoint p1: Point, topRightPoint p2: Point, bottomRightPoint p3: Point, bottomLeftPoint p4: Point, fillColor: Color)
	func drawLine(startPoint p1: Point, endPoint p2: Point, strokeWidth thickness: Float, strokeColor: Color)
	func drawTransformedLine(startPoint p1: Point, endPoint p2: Point, strokeWidth thickness: Float, strokeColor: Color)
	func drawPlotLines(points p: [Point], strokeWidth thickness: Float, strokeColor: Color)
	func drawText(text s: String, location p: Point, textSize size: Float, strokeWidth thickness: Float)
	func drawTransformedText(text s: String, location p: Point, textSize size: Float, strokeWidth thickness: Float, angle: Float)
	func drawRotatedText(text s: String, location p: Point, textSize size: Float, strokeWidth thickness: Float, angle: Float)
	func drawSolidRectWithBorder(topLeftPoint p1: Point,topRightPoint p2: Point,bottomRightPoint p3: Point,bottomLeftPoint p4: Point, strokeWidth thickness: Float, fillColor: Color, borderColor: Color)
	func getTextWidth(text: String, textSize size: Float) -> Float
	func drawOutput(fileName name: String)

}
