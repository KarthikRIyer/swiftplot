import Foundation
import Util
import CAGGRenderer

public class AGGRenderer: Renderer{

	var width: Float
	var height: Float

	public var xOffset: Float = 0
	public var yOffset: Float = 0

	public var plotDimensions: PlotDimensions {
		willSet{
			width = newValue.subWidth
			height = newValue.subHeight
		}
	}

	var agg_object: UnsafeRawPointer

	public init(width w: Float = 1000, height h: Float = 660) {
		width = w
		height = h
		plotDimensions = PlotDimensions(frameWidth: width, frameHeight: height)
		agg_object = initializePlot(width, height)
	}

	public func drawRect(topLeftPoint p1: Point, topRightPoint p2: Point, bottomRightPoint p3: Point, bottomLeftPoint p4: Point, strokeWidth thickness: Float, strokeColor: Color = Color.black) {
		var x = [Float]()
		var y = [Float]()
		x.append(p1.x + xOffset)
		x.append(p2.x + xOffset)
		x.append(p3.x + xOffset)
		x.append(p4.x + xOffset)
		y.append(p1.y + yOffset)
		y.append(p2.y + yOffset)
		y.append(p3.y + yOffset)
		y.append(p4.y + yOffset)
		draw_rect(x, y, thickness, strokeColor.r, strokeColor.g, strokeColor.b, strokeColor.a, agg_object)
	}

	public func drawSolidRect(topLeftPoint p1: Point, topRightPoint p2: Point, bottomRightPoint p3: Point, bottomLeftPoint p4: Point, fillColor: Color = Color.white) {
		var x = [Float]()
		var y = [Float]()
		x.append(p1.x + xOffset)
		x.append(p2.x + xOffset)
		x.append(p3.x + xOffset)
		x.append(p4.x + xOffset)
		y.append(p1.y + yOffset)
		y.append(p2.y + yOffset)
		y.append(p3.y + yOffset)
		y.append(p4.y + yOffset)
		draw_solid_rect(x, y, fillColor.r, fillColor.g, fillColor.b, fillColor.a, agg_object)
	}

	public func drawSolidRectWithBorder(topLeftPoint p1: Point,topRightPoint p2: Point,bottomRightPoint p3: Point,bottomLeftPoint p4: Point, strokeWidth thickness: Float, fillColor: Color = Color.white, borderColor: Color = Color.black) {
		var x = [Float]()
		var y = [Float]()

		x.append(p1.x + xOffset)
		x.append(p2.x + xOffset)
		x.append(p3.x + xOffset)
		x.append(p4.x + xOffset)
		y.append(p1.y + yOffset)
		y.append(p2.y + yOffset)
		y.append(p3.y + yOffset)
		y.append(p4.y + yOffset)

		draw_solid_rect(x, y, fillColor.r, fillColor.g, fillColor.b, fillColor.a, agg_object)
		draw_rect(x, y, thickness, borderColor.r, borderColor.g, borderColor.b, borderColor.a, agg_object)
	}

	public func drawLine(startPoint p1: Point, endPoint p2: Point, strokeWidth thickness: Float, strokeColor: Color = Color.black) {
		var x = [Float]()
		var y = [Float]()

		x.append(p1.x + xOffset)
		x.append(p2.x + xOffset)
		y.append(p1.y + yOffset)
		y.append(p2.y + yOffset)

		draw_line(x, y, thickness, strokeColor.r, strokeColor.g, strokeColor.b, strokeColor.a, agg_object)
	}

	public func drawTransformedLine(startPoint p1: Point, endPoint p2: Point, strokeWidth thickness: Float, strokeColor: Color = Color.black) {
		var x = [Float]()
		var y = [Float]()

		x.append(p1.x + xOffset)
		x.append(p2.x + xOffset)
		y.append(p1.y + yOffset)
		y.append(p2.y + yOffset)

		draw_transformed_line(x, y, thickness, strokeColor.r, strokeColor.g, strokeColor.b, strokeColor.a, agg_object)
	}

	public func drawPlotLines(points p: [Point], strokeWidth thickness: Float, strokeColor: Color) {
		var x = [Float]()
		var y = [Float]()

		for index in 0..<p.count {
			x.append(p[index].x + xOffset)
			y.append(p[index].y + yOffset)
		}

		draw_plot_lines(x, y, Int32(p.count), thickness, strokeColor.r, strokeColor.g, strokeColor.b, strokeColor.a, agg_object)
	}

	public func drawText(text s: String, location p: Point, textSize size: Float, strokeWidth thickness: Float){
		draw_text(s, p.x + xOffset, p.y + yOffset, size, thickness, agg_object)
	}

	public func drawTransformedText(text s: String, location p: Point, textSize size: Float, strokeWidth thickness: Float, angle: Float = 0){
		draw_transformed_text(s, p.x + xOffset, p.y + yOffset, size, thickness, agg_object)
	}

	public func drawRotatedText(text s: String, location p: Point, textSize size: Float, strokeWidth thickness: Float, angle: Float = 0){
		draw_rotated_text(s, p.x + xOffset, p.y + yOffset, size, thickness, angle, agg_object)
	}

	public func getTextWidth(text: String, textSize size: Float) -> Float {
		return get_text_width(text, size, agg_object)
	}

	public func drawOutput(fileName name: String) {
		save_image(name, agg_object)
	}

	public func base64Png() -> String{
		let pngBufferPointer: UnsafePointer<UInt8> = get_png_buffer(agg_object)
		let bufferSize: Int = Int(get_png_buffer_size(agg_object))
		return encodeBase64PNG(pngBufferPointer: pngBufferPointer, bufferSize: bufferSize)
	}

}
