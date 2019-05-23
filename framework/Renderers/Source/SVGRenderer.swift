import Foundation
import Util

//extension to get ascii value of character
extension Character {
	var isAscii: Bool {
		return unicodeScalars.allSatisfy { $0.isASCII }
	}
	var ascii: UInt32? {
		return isAscii ? unicodeScalars.first?.value: nil
	}
}

public class SVGRenderer: Renderer{

	var LCARS_CHAR_SIZE_ARRAY: [Int]?

	var image: String
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

	public init(width w: Float = 1000, height h: Float = 660) {
		width = w
		height = h
		plotDimensions = PlotDimensions(frameWidth: width, frameHeight: height)
		image = "<svg height=\"\(h)\" width=\"\(w)\" version=\"4.0\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink= \"http://www.w3.org/1999/xlink\">"
		image = image + "\n" + "<rect width=\"100%\" height=\"100%\" fill=\"white\"/>";
		LCARS_CHAR_SIZE_ARRAY = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 17, 26, 46, 63, 42, 105, 45, 20, 25, 25, 47, 39, 21, 34, 26, 36, 36, 28, 36, 36, 36, 36, 36, 36, 36, 36, 27, 27, 36, 35, 36, 35, 65, 42, 43, 42, 44, 35, 34, 43, 46, 25, 39, 40, 31, 59, 47, 43, 41, 43, 44, 39, 28, 44, 43, 65, 37, 39, 34, 37, 42, 37, 50, 37, 32, 43, 43, 39, 43, 40, 30, 42, 45, 23, 25, 39, 23, 67, 45, 41, 43, 42, 30, 40, 28, 45, 33, 52, 33, 36, 31, 39, 26, 39, 55]
	}

	public func drawRect(topLeftPoint p1: Point, topRightPoint p2: Point, bottomRightPoint p3: Point, bottomLeftPoint p4: Point, strokeWidth thickness: Float, strokeColor: Color = Color.black) {
		let w: Float = abs(p2.x - p1.x)
		let h: Float = abs(p2.y - p3.y)
		let rect: String = "<rect x=\"\(p1.x + xOffset)\" y=\"\(height - p1.y + yOffset)\" width=\"\(w)\" height=\"\(h)\" style=\"fill:rgb(255,255,255);stroke-width:\(thickness);stroke:rgb(\(strokeColor.r*255.0),\(strokeColor.g*255.0),\(strokeColor.b*255.0))\" />"
		image = image + "\n" + rect
	}

	public func drawSolidRect(topLeftPoint p1: Point, topRightPoint p2: Point, bottomRightPoint p3: Point, bottomLeftPoint p4: Point, fillColor: Color = Color.white) {
		let w: Float = abs(p2.x - p1.x)
		let h: Float = abs(p2.y - p3.y)
		let rect: String = "<rect x=\"\(p1.x + xOffset)\" y=\"\(height - p1.y + yOffset)\" width=\"\(w)\" height=\"\(h)\" style=\"fill:rgb(\(fillColor.r*255.0),\(fillColor.g*255.0),\(fillColor.b*255.0));stroke-width:0;stroke:rgb(0,0,0);opacity:\(fillColor.a)\" />"
		image = image + "\n" + rect
	}

	public func drawSolidRectWithBorder(topLeftPoint p1: Point,topRightPoint p2: Point,bottomRightPoint p3: Point,bottomLeftPoint p4: Point, strokeWidth thickness: Float, fillColor: Color = Color.white, borderColor: Color = Color.black) {
		let w: Float = abs(p2.x - p1.x)
		let h: Float = abs(p2.y - p3.y)
		let rect: String = "<rect x=\"\(p1.x + xOffset)\" y=\"\(height - p1.y + yOffset)\" width=\"\(w)\" height=\"\(h)\" style=\"fill:rgb(\(fillColor.r*255.0),\(fillColor.g*255.0),\(fillColor.b*255.0));stroke-width:\(thickness);stroke:rgb(\(borderColor.r*255.0),\(borderColor.g*255.0),\(borderColor.b*255.0));opacity:\(fillColor.a)\" />"
		image = image + "\n" + rect
	}

	public func drawLine(startPoint p1: Point, endPoint p2: Point, strokeWidth thickness: Float, strokeColor: Color = Color.black) {
		let x0 = p1.x
		var y0 = p1.y
		let x1 = p2.x
		var y1 = p2.y
		y0 = height - y0
		y1 = height - y1
		let line = "<line x1=\"\(x0 + xOffset)\" y1=\"\(y0 + yOffset)\" x2=\"\(x1 + xOffset)\" y2=\"\(y1 + yOffset)\" style=\"stroke:rgb(\(strokeColor.r*255.0),\(strokeColor.g*255.0),\(strokeColor.b*255.0));stroke-width:\(thickness);opacity:\(strokeColor.a);stroke-linecap:round\" />"
		image = image + "\n" + line
	}

	public func drawTransformedLine(startPoint p1: Point, endPoint p2: Point, strokeWidth thickness: Float, strokeColor: Color = Color.black) {
		let x0 = p1.x + (0.1*width)
		var y0 = p1.y + (0.1*height)
		let x1 = p2.x + (0.1*width)
		var y1 = p2.y + (0.1*height)
		y0 = height - y0
		y1 = height - y1
		let line = "<line x1=\"\(x0 + xOffset)\" y1=\"\(y0 + yOffset)\" x2=\"\(x1 + xOffset)\" y2=\"\(y1 + yOffset)\" style=\"stroke:rgb(\(strokeColor.r*255.0),\(strokeColor.g*255.0),\(strokeColor.b*255.0));stroke-width:\(thickness);opacity:\(strokeColor.a);stroke-linecap:round\" />"
		image = image + "\n" + line
	}

	public func drawPlotLines(points p: [Point], strokeWidth thickness: Float, strokeColor: Color) {
		for i in 0..<p.count-1 {
			drawTransformedLine(startPoint: p[i], endPoint: p[i+1], strokeWidth: thickness, strokeColor: strokeColor)
		}
	}

	public func drawText(text s: String, location p: Point, textSize size: Float, strokeWidth thickness: Float){
		let y1 = height - p.y
		let text = "<text x=\"\(p.x + xOffset)\" y=\"\(y1 + yOffset)\" stroke=\"#000000\" stroke-width=\"\(thickness)\"  transform=\"rotate(0,\(p.x+xOffset),\(y1 + yOffset))\">\(s)</text>"
		image = image + "\n" + text
	}

	public func drawTransformedText(text s: String, location p: Point, textSize size: Float, strokeWidth thickness: Float, angle: Float = 0){
		let x1 = p.x + 0.1*width
		let y1 = height - p.y - 0.1*height
		let text = "<text x=\"\(x1 + xOffset)\" y=\"\(y1 + yOffset)\" stroke=\"#000000\" stroke-width=\"\(thickness)\" transform=\"rotate(\(-angle),\(x1+xOffset),\(y1 + yOffset))\">\(s)</text>"
		image = image + "\n" + text
	}

	public func drawRotatedText(text s: String, location p: Point, textSize size: Float, strokeWidth thickness: Float, angle: Float = 0){
		let y1 = height - p.y
		let text = "<text x=\"\(p.x + xOffset)\" y=\"\(y1 + yOffset)\" stroke=\"#000000\" stroke-width=\"\(thickness)\"  transform=\"rotate(\(-angle),\(p.x+xOffset),\(y1 + yOffset))\">\(s)</text>"
		image = image + "\n" + text
	}

	public func getTextWidth(text: String, textSize size: Float) -> Float {
		var width: Float = 0
		let scaleFactor = size/100.0

		for i in 0..<text.count {
			let index =  text.index(text.startIndex, offsetBy: i)
			width = width + Float(LCARS_CHAR_SIZE_ARRAY![Int(text[index].ascii!)])
		}

		return width*scaleFactor + 25
	}

	public func drawOutput(fileName name: String) {
		savePlotImage(fileName: name)
	}

	func savePlotImage(fileName name: String) {
		image = image + "\n" + "</svg>"
		let url = URL(fileURLWithPath: "\(name).svg")
		do {
			try image.write(to: url, atomically: true, encoding: String.Encoding.utf8)
		} catch {
			print("Unable to save SVG image!")
		}
	}

	public func base64Png(fileName name : String = "svg_plot") -> String{
		return "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"
	}

}
