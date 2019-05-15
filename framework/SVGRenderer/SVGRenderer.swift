import Foundation

//extension to get ascii value of character
extension Character {
    var isAscii: Bool {
        return unicodeScalars.allSatisfy { $0.isASCII }
    }
    var ascii: UInt32? {
        return isAscii ? unicodeScalars.first?.value : nil
    }
}

public class SVGRenderer{

  var LCARS_CHAR_SIZE_ARRAY : [Int]?

  var image : String
  var width : Float
  var height : Float

  public init(width w : Float, height h : Float) {
    width = w
    height = h
    image = "<svg height=\"\(h)\" width=\"\(w)\" version=\"4.0\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink= \"http://www.w3.org/1999/xlink\">"
    image = image + "\n" + "<rect width=\"100%\" height=\"100%\" fill=\"white\"/>";
    LCARS_CHAR_SIZE_ARRAY = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 17, 26, 46, 63, 42, 105, 45, 20, 25, 25, 47, 39, 21, 34, 26, 36, 36, 28, 36, 36, 36, 36, 36, 36, 36, 36, 27, 27, 36, 35, 36, 35, 65, 42, 43, 42, 44, 35, 34, 43, 46, 25, 39, 40, 31, 59, 47, 43, 41, 43, 44, 39, 28, 44, 43, 65, 37, 39, 34, 37, 42, 37, 50, 37, 32, 43, 43, 39, 43, 40, 30, 42, 45, 23, 25, 39, 23, 67, 45, 41, 43, 42, 30, 40, 28, 45, 33, 52, 33, 36, 31, 39, 26, 39, 55]
  }

  public func draw_rect(_ x : [Float], _ y : [Float], _ thickness : Float) {
    let w : Float = abs(x[1] - x[0])
    let h : Float = abs(y[1] - y[2])
    let rect : String = "<rect x=\"\(x[0])\" y=\"\(height - y[0])\" width=\"\(w)\" height=\"\(h)\" style=\"fill:rgb(255,255,255);stroke-width:\(thickness);stroke:rgb(0,0,0)\" />"
    image = image + "\n" + rect
  }

  public func draw_solid_rect(_ x : [Float], _ y : [Float], _ r : Float, _ g : Float, _ b : Float, _ a : Float) {
    let w : Float = abs(x[1] - x[0])
    let h : Float = abs(y[1] - y[2])
    let rect : String = "<rect x=\"\(x[0])\" y=\"\(height - y[0])\" width=\"\(w)\" height=\"\(h)\" style=\"fill:rgb(\(r*255.0),\(g*255.0),\(b*255.0));stroke-width:0;stroke:rgb(0,0,0)\" />"
    image = image + "\n" + rect
  }

  public func draw_solid_rect_with_border(_ x : [Float], _ y : [Float], _ thickness : Float, _ r : Float, _ g : Float, _ b : Float, _ a : Float) {
    let w : Float = abs(x[1] - x[0])
    let h : Float = abs(y[1] - y[2])
    let rect : String = "<rect x=\"\(x[0])\" y=\"\(height - y[0])\" width=\"\(w)\" height=\"\(h)\" style=\"fill:rgb(\(r*255.0),\(g*255.0),\(b*255.0));stroke-width:\(thickness);stroke:rgb(0,0,0)\" />"
    image = image + "\n" + rect
  }

  public func draw_line(_ x : [Float], _ y : [Float], _ thickness : Float, _ r : Float = 0, _ g : Float = 0, _ b : Float = 0, _ a : Float = 1) {
      let x0 = x[0]
      var y0 = y[0]
      let x1 = x[1]
      var y1 = y[1]
      y0 = height - y0
      y1 = height - y1
      let line = "<line x1=\"\(x0)\" y1=\"\(y0)\" x2=\"\(x1)\" y2=\"\(y1)\" style=\"stroke:rgb(\(r*255.0),\(g*255.0),\(b*255.0));stroke-width:\(thickness)\" />"
      image = image + "\n" + line
  }

  public func draw_transformed_line(_ x : [Float], _ y : [Float], _ thickness : Float, _ r : Float = 0, _ g : Float = 0, _ b : Float = 0, _ a : Float = 1) {
      let x0 = x[0] + (0.1*width)
      var y0 = y[0] + (0.1*height)
      let x1 = x[1] + (0.1*width)
      var y1 = y[1] + (0.1*height)
      y0 = height - y0
      y1 = height - y1
      let line = "<line x1=\"\(x0)\" y1=\"\(y0)\" x2=\"\(x1)\" y2=\"\(y1)\" style=\"stroke:rgb(\(r*255.0),\(g*255.0),\(b*255.0));stroke-width:\(thickness)\" />"
      image = image + "\n" + line
  }

  public func draw_transformed_text(_ s : String, _ x : Float, _ y : Float, _ size : Float, _ thickness : Float, _ angle : Float = 0){
    let x1 = x + 0.1*width
    let y1 = height - y - 0.1*height
    let text = "<text x=\"\(x1)\" y=\"\(y1)\" stroke=\"#000000\" stroke-width=\"\(thickness)\" transform=\"rotate(\(angle),\(x1),\(y1))\">\(s)</text>"
    image = image + "\n" + text
  }

  public func draw_text(_ s : String, _ x : Float, _ y : Float, _ size : Float, _ thickness : Float){
    let y1 = height - y
    let text = "<text x=\"\(x)\" y=\"\(y1)\" stroke=\"#000000\" stroke-width=\"\(thickness)\"  transform=\"rotate(0,\(x),\(y1))\">\(s)</text>"
    image = image + "\n" + text
  }

  public func draw_rotated_text(_ s : String, _ x : Float, _ y : Float, _ size : Float, _ thickness : Float, _ angle : Float = 0){
    let y1 = height - y
    let text = "<text x=\"\(x)\" y=\"\(y1)\" stroke=\"#000000\" stroke-width=\"\(thickness)\"  transform=\"rotate(\(-angle),\(x),\(y1))\">\(s)</text>"
    image = image + "\n" + text
  }

  public func draw_plot_lines(_ x : [Float], _ y : [Float], _ thickness : Float, _ r : Float, _ g : Float, _ b : Float, _ a : Float) {
    for i in 0..<x.count-1 {
      let x1 : [Float] = [x[i], x[i+1]]
      let y1 : [Float] = [y[i], y[i+1]]
      draw_transformed_line(x1, y1, thickness, r, g, b, a)
    }
  }

  public func get_text_width(_ text : String, _ size : Float) -> Float {

    var width : Float = 0
    let scaleFactor = size/100.0

    for i in 0..<text.count {
      let index =  text.index(text.startIndex, offsetBy: i)
      width = width + Float(LCARS_CHAR_SIZE_ARRAY![Int(text[index].ascii!)])
    }
    // print("\(text) = \(width*scaleFactor)")

    return width*scaleFactor + 25

  }

  public func save_image(_ name : String) {
    image = image + "\n" + "</svg>"
    let url = URL(fileURLWithPath: "\(name).svg")
    do {
        try image.write(to: url, atomically: true, encoding: String.Encoding.utf8)
    } catch {
        print("Unable to save SVG image!")
    }
  }

}
