import Foundation
import Util

//extension to get ascii value of character
extension Character {
    var isAscii: Bool {
        return unicodeScalars.allSatisfy { $0.isASCII }
    }
    var ascii: UInt32? {
        return isAscii ? unicodeScalars.first?.value : nil
    }
}

public class SVGRenderer : Renderer{

  var LCARS_CHAR_SIZE_ARRAY : [Int]?

  var image : String
  var width : Float
  var height : Float

  public var xOffset : Float = 0
  public var yOffset : Float = 0

  public var plotDimensions : PlotDimensions {
    willSet{
      width = newValue.subWidth
      height = newValue.subHeight
    }
  }

  public init(width w : Float = 1000, height h : Float = 660) {
    width = w
    height = h
    plotDimensions = PlotDimensions(frameWidth : width, frameHeight : height)
    image = "<svg height=\"\(h)\" width=\"\(w)\" version=\"4.0\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink= \"http://www.w3.org/1999/xlink\">"
    image = image + "\n" + "<rect width=\"100%\" height=\"100%\" fill=\"white\"/>";
    LCARS_CHAR_SIZE_ARRAY = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 17, 26, 46, 63, 42, 105, 45, 20, 25, 25, 47, 39, 21, 34, 26, 36, 36, 28, 36, 36, 36, 36, 36, 36, 36, 36, 27, 27, 36, 35, 36, 35, 65, 42, 43, 42, 44, 35, 34, 43, 46, 25, 39, 40, 31, 59, 47, 43, 41, 43, 44, 39, 28, 44, 43, 65, 37, 39, 34, 37, 42, 37, 50, 37, 32, 43, 43, 39, 43, 40, 30, 42, 45, 23, 25, 39, 23, 67, 45, 41, 43, 42, 30, 40, 28, 45, 33, 52, 33, 36, 31, 39, 26, 39, 55]
  }

  public func drawRect(topLeftPoint p1 : Point, topRightPoint p2 : Point, bottomRightPoint p3 : Point, bottomLeftPoint p4 : Point, strokeWidth thickness : Float, strokeColor strokeColor : Color = Color.black) {
    let w : Float = abs(p2.x - p1.x)
    let h : Float = abs(p2.y - p3.y)
    let rect : String = "<rect x=\"\(p1.x + xOffset)\" y=\"\(height - p1.y + yOffset)\" width=\"\(w)\" height=\"\(h)\" style=\"fill:rgb(255,255,255);stroke-width:\(thickness);stroke:rgb(\(strokeColor.r*255.0),\(strokeColor.g*255.0),\(strokeColor.b*255.0))\" />"
    image = image + "\n" + rect
  }

  public func drawSolidRect(topLeftPoint p1 : Point, topRightPoint p2 : Point, bottomRightPoint p3 : Point, bottomLeftPoint p4 : Point, fillColor fillColor : Color = Color.white) {
    let w : Float = abs(p2.x - p1.x)
    let h : Float = abs(p2.y - p3.y)
    let rect : String = "<rect x=\"\(p1.x + xOffset)\" y=\"\(height - p1.y + yOffset)\" width=\"\(w)\" height=\"\(h)\" style=\"fill:rgb(\(fillColor.r*255.0),\(fillColor.g*255.0),\(fillColor.b*255.0));stroke-width:0;stroke:rgb(0,0,0)\" />"
    image = image + "\n" + rect
  }

  public func drawSolidRectWithBorder(topLeftPoint p1 : Point,topRightPoint p2 : Point,bottomRightPoint p3 : Point,bottomLeftPoint p4 : Point, strokeWidth thickness : Float, fillColor fillColor : Color = Color.white, borderColor borderColor : Color = Color.black) {
    let w : Float = abs(p2.x - p1.x)
    let h : Float = abs(p2.y - p3.y)
    let rect : String = "<rect x=\"\(p1.x + xOffset)\" y=\"\(height - p1.y + yOffset)\" width=\"\(w)\" height=\"\(h)\" style=\"fill:rgb(\(fillColor.r*255.0),\(fillColor.g*255.0),\(fillColor.b*255.0));stroke-width:\(thickness);stroke:rgb(\(borderColor.r*255.0),\(borderColor.g*255.0),\(borderColor.b*255.0))\" />"
    image = image + "\n" + rect
  }

  public func drawLine(startPoint p1 : Point, endPoint p2 : Point, strokeWidth thickness : Float, strokeColor strokeColor : Color = Color.black) {
      let x0 = p1.x
      var y0 = p1.y
      let x1 = p2.x
      var y1 = p2.y
      y0 = height - y0
      y1 = height - y1
      let line = "<line x1=\"\(x0 + xOffset)\" y1=\"\(y0 + yOffset)\" x2=\"\(x1 + xOffset)\" y2=\"\(y1 + yOffset)\" style=\"stroke:rgb(\(strokeColor.r*255.0),\(strokeColor.g*255.0),\(strokeColor.b*255.0));stroke-width:\(thickness)\" />"
      image = image + "\n" + line
  }

  public func drawTransformedLine(startPoint p1 : Point, endPoint p2 : Point, strokeWidth thickness : Float, strokeColor strokeColor : Color = Color.black) {
      let x0 = p1.x + (0.1*width)
      var y0 = p1.y + (0.1*height)
      let x1 = p2.x + (0.1*width)
      var y1 = p2.y + (0.1*height)
      y0 = height - y0
      y1 = height - y1
      let line = "<line x1=\"\(x0 + xOffset)\" y1=\"\(y0 + yOffset)\" x2=\"\(x1 + xOffset)\" y2=\"\(y1 + yOffset)\" style=\"stroke:rgb(\(strokeColor.r*255.0),\(strokeColor.g*255.0),\(strokeColor.b*255.0));stroke-width:\(thickness)\" />"
      image = image + "\n" + line
  }

  public func drawPlotLines(points p : [Point], strokeWidth thickness : Float, strokeColor strokeColor : Color) {
    for i in 0..<p.count-1 {
      drawTransformedLine(startPoint : p[i], endPoint : p[i+1], strokeWidth: thickness, strokeColor : strokeColor)
    }
  }

  public func drawText(text s : String, location p : Point, textSize size : Float, strokeWidth thickness : Float){
    let y1 = height - p.y
    let text = "<text x=\"\(p.x + xOffset)\" y=\"\(y1 + yOffset)\" stroke=\"#000000\" stroke-width=\"\(thickness)\"  transform=\"rotate(0,\(p.x+xOffset),\(y1 + yOffset))\">\(s)</text>"
    image = image + "\n" + text
  }

  public func drawTransformedText(text s : String, location p : Point, textSize size : Float, strokeWidth thickness : Float, angle angle : Float = 0){
    let x1 = p.x + 0.1*width
    let y1 = height - p.y - 0.1*height
    let text = "<text x=\"\(x1 + xOffset)\" y=\"\(y1 + yOffset)\" stroke=\"#000000\" stroke-width=\"\(thickness)\" transform=\"rotate(\(-angle),\(x1+xOffset),\(y1 + yOffset))\">\(s)</text>"
    image = image + "\n" + text
  }

  public func drawRotatedText(text s : String, location p : Point, textSize size : Float, strokeWidth thickness : Float, angle angle : Float = 0){
    let y1 = height - p.y
    let text = "<text x=\"\(p.x + xOffset)\" y=\"\(y1 + yOffset)\" stroke=\"#000000\" stroke-width=\"\(thickness)\"  transform=\"rotate(\(-angle),\(p.x+xOffset),\(y1 + yOffset))\">\(s)</text>"
    image = image + "\n" + text
  }

  public func getTextWidth(text text : String, textSize size : Float) -> Float {
    var width : Float = 0
    let scaleFactor = size/100.0

    for i in 0..<text.count {
      let index =  text.index(text.startIndex, offsetBy: i)
      width = width + Float(LCARS_CHAR_SIZE_ARRAY![Int(text[index].ascii!)])
    }

    return width*scaleFactor + 25
  }

  public func drawOutput(fileName name : String) {
      savePlotImage(fileName : name)
  }

  func savePlotImage(fileName name : String) {
    image = image + "\n" + "</svg>"
    let url = URL(fileURLWithPath: "\(name).svg")
    do {
        try image.write(to: url, atomically: true, encoding: String.Encoding.utf8)
    } catch {
        print("Unable to save SVG image!")
    }
  }

}
