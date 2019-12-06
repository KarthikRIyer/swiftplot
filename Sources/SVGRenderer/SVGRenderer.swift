import Foundation
import SwiftPlot

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

    static let LCARS_CHAR_SIZE_ARRAY: [Int] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 17, 26, 46, 63, 42, 105, 45, 20, 25, 25, 47, 39, 21, 34, 26, 36, 36, 28, 36, 36, 36, 36, 36, 36, 36, 36, 27, 27, 36, 35, 36, 35, 65, 42, 43, 42, 44, 35, 34, 43, 46, 25, 39, 40, 31, 59, 47, 43, 41, 43, 44, 39, 28, 44, 43, 65, 37, 39, 34, 37, 42, 37, 50, 37, 32, 43, 43, 39, 43, 40, 30, 42, 45, 23, 25, 39, 23, 67, 45, 41, 43, 42, 30, 40, 28, 45, 33, 52, 33, 36, 31, 39, 26, 39, 55]

    static let forwardSlashHatch: String = #"<defs><pattern id="forwardSlashHatch" width="10" height="10" patternTransform="rotate(45 0 0)" patternUnits="userSpaceOnUse"><line x1="0" y1="0" x2="0" y2="10" style="stroke:black; stroke-width:1" /></pattern></defs>"#
    static let backwardSlashHatch: String = #"<defs><pattern id="backwardSlashHatch" width="10" height="10" patternTransform="rotate(-45 0 0)" patternUnits="userSpaceOnUse"><line x1="0" y1="0" x2="0" y2="10" style="stroke:black; stroke-width:1" /></pattern></defs>"#
    static let hollowCircleHatch: String = #"<defs><pattern id="hollowCircleHatch" width="10" height="10" patternUnits="userSpaceOnUse"><circle cx="5" cy="5" r="3" stroke="black" stroke-width="1" fill="none"/></pattern></defs>"#
    static let filledCircleHatch: String = #"<defs><pattern id="filledCircleHatch" width="10" height="10" patternUnits="userSpaceOnUse"><circle cx="5" cy="5" r="3" stroke="black" stroke-width="1"/></pattern></defs>"#
    static let verticalHatch: String = #"<defs><pattern id="verticalHatch" width="10" height="10" patternUnits="userSpaceOnUse"><line x1="5" y1="0" x2="5" y2="10" style="stroke:black; stroke-width:1" /></pattern></defs>"#
    static let horizontalHatch: String = #"<defs><pattern id="horizontalHatch" width="10" height="10" patternUnits="userSpaceOnUse"><line x1="0" y1="5" x2="10" y2="5" style="stroke:black; stroke-width:1" /></pattern></defs>"#
    static let gridHatch: String = #"<defs><pattern id="gridHatch" width="10" height="10" patternUnits="userSpaceOnUse"><line x1="0" y1="5" x2="10" y2="5" style="stroke:black; stroke-width:1" /><line x1="5" y1="0" x2="5" y2="10" style="stroke:black; stroke-width:1" /></pattern></defs>"#
    static let crossHatch: String = #"<defs><pattern id="crossHatch" width="10" height="10" patternUnits="userSpaceOnUse"><line x1="0" y1="0" x2="10" y2="10" style="stroke:black; stroke-width:1" /><line x1="0" y1="10" x2="10" y2="0" style="stroke:black; stroke-width:1" /></pattern></defs>"#
    public var offset: Point = .zero
    public var imageSize: Size

    var hatchingIncluded = Array(repeating: false,
                                 count: BarGraphSeriesOptions.Hatching.allCases.count)

    var lines: [String] = []
    var fontFamily: String = "Roboto"

    public init(width w: Float = 1000, height h: Float = 660, fontFamily: String = "Roboto") {
        self.imageSize = Size(width: w, height: h)
        self.fontFamily = fontFamily
    }

    func convertToSVGCoordinates(_ point: Point) -> Point {
        let x = point.x + xOffset
        var y = point.y + yOffset
        y = imageSize.height - y
        return Point(x, y)
    }

    func convertToSVGCoordinates(_ rect: Rect) -> Rect {
        // Convert to SVG coordinate system (0,0 at top-left).
        var rect = rect.normalized
        rect.origin = convertToSVGCoordinates(rect.origin)
        rect.size.height *= -1
        return rect.normalized
    }

    public func drawRect(_ rect: Rect,
                         strokeWidth thickness: Float,
                         strokeColor: Color = Color.black) {
        let rect = convertToSVGCoordinates(rect)
        let rectStr = #"<rect x="\#(rect.origin.x)" y="\#(rect.origin.y)" width="\#(rect.size.width)" height="\#(rect.size.height)" style="fill:rgb(255,255,255);stroke-width:\#(thickness);stroke:\#(strokeColor.svgColorString);opacity:1;fill-opacity:0;" />"#
        lines.append(rectStr)
    }

    public func drawSolidRect(_ rect: Rect,
                              fillColor: Color = Color.white,
                              hatchPattern: BarGraphSeriesOptions.Hatching) {
        let rect = convertToSVGCoordinates(rect)
        let rectStr = #"<rect x="\#(rect.origin.x)" y="\#(rect.origin.y)" width="\#(rect.size.width)" height="\#(rect.size.height)" style="fill:\#(fillColor.svgColorString);stroke-width:0;stroke:rgb(0,0,0);opacity:\#(fillColor.a)" />"#
        lines.append(rectStr)
        drawHatchingRect(rect, hatchPattern: hatchPattern)
    }

    func drawHatchingRect(_ rect: Rect,
                          hatchPattern: BarGraphSeriesOptions.Hatching) {
        let patternName: String
        switch (hatchPattern) {
        case .none:
            return
        case .forwardSlash:
            if (!hatchingIncluded[hatchPattern.rawValue]) {
                lines.append(Self.forwardSlashHatch)
                hatchingIncluded[hatchPattern.rawValue] = true
            }
            patternName = "url(#forwardSlashHatch)"
        case .backwardSlash:
            if (!hatchingIncluded[hatchPattern.rawValue]) {
                lines.append(Self.backwardSlashHatch)
                hatchingIncluded[hatchPattern.rawValue] = true
            }
            patternName = "url(#backwardSlashHatch)"
        case .hollowCircle:
            if (!hatchingIncluded[hatchPattern.rawValue]) {
                lines.append(Self.hollowCircleHatch)
                hatchingIncluded[hatchPattern.rawValue] = true
            }
            patternName = "url(#hollowCircleHatch)"
        case .filledCircle:
            if (!hatchingIncluded[hatchPattern.rawValue]) {
                lines.append(Self.filledCircleHatch)
                hatchingIncluded[hatchPattern.rawValue] = true
            }
            patternName = "url(#filledCircleHatch)"
        case .vertical:
            if (!hatchingIncluded[hatchPattern.rawValue]) {
                lines.append(Self.verticalHatch)
                hatchingIncluded[hatchPattern.rawValue] = true
            }
            patternName = "url(#verticalHatch)"
        case .horizontal:
            if (!hatchingIncluded[hatchPattern.rawValue]) {
                lines.append(Self.horizontalHatch)
                hatchingIncluded[hatchPattern.rawValue] = true
            }
            patternName = "url(#horizontalHatch)"
        case .grid:
            if (!hatchingIncluded[hatchPattern.rawValue]) {
                lines.append(Self.gridHatch)
                hatchingIncluded[hatchPattern.rawValue] = true
            }
            patternName = "url(#gridHatch)"
        case .cross:
            if (!hatchingIncluded[hatchPattern.rawValue]) {
                lines.append(Self.crossHatch)
                hatchingIncluded[hatchPattern.rawValue] = true
            }
            patternName = "url(#crossHatch)"
        }
        let rectStr = #"<rect x="\#(rect.origin.x)" y="\#(rect.origin.y)" width="\#(rect.size.width)" height="\#(rect.size.height)" style="fill:\#(patternName);opacity:\#(1)" />"#
        lines.append(rectStr)
    }

    public func drawSolidRectWithBorder(_ rect: Rect,
                                        strokeWidth thickness: Float,
                                        fillColor: Color = Color.white,
                                        borderColor: Color = Color.black) {
        let rect = convertToSVGCoordinates(rect)
        let rectStr = #"<rect x="\#(rect.origin.x)" y="\#(rect.origin.y)" width="\#(rect.size.width)" height="\#(rect.size.height)" style="fill:\#(fillColor.svgColorString);stroke-width:\#(thickness);stroke:\#(borderColor.svgColorString);opacity:\#(fillColor.a)" />"#
        lines.append(rectStr)
    }

    public func drawSolidCircle(center c: Point,
                                radius r: Float,
                                fillColor: Color) {
        let c = convertToSVGCoordinates(c)
        let circle: String = #"<circle cx="\#(c.x)" cy="\#(c.y)" r="\#(r)"  style="fill:\#(fillColor.svgColorString);opacity:\#(fillColor.a)" />"#
        lines.append(circle)
    }

    public func drawSolidEllipse(center c: Point,
                                 radiusX rx: Float,
                                 radiusY ry: Float,
                                 fillColor: Color) {
        let c = convertToSVGCoordinates(c)
        let circle: String = #"<ellipse cx="\#(c.x)" cy="\#(c.y)" rx="\#(rx)" ry="\#(ry)" style="fill:\#(fillColor.svgColorString);opacity:\#(fillColor.a)" />"#
        lines.append(circle)
    }

    public func drawSolidTriangle(point1: Point,
                                  point2: Point,
                                  point3: Point,
                                  fillColor: Color) {
        let p1 = convertToSVGCoordinates(point1)
        let p2 = convertToSVGCoordinates(point2)
        let p3 = convertToSVGCoordinates(point3)
        let triangle = #"<polygon points="\#(p1.x),\#(p1.y) \#(p2.x),\#(p2.y) \#(p3.x),\#(p3.y)" style="fill:\#(fillColor.svgColorString);opacity:\#(fillColor.a)" />"#
        lines.append(triangle)
    }
    
    public func drawSolidPolygon(_ polygon: SwiftPlot.Polygon,
                                 fillColor: Color) {
        var pointsString = ""
        for point in polygon.points {
            let convertedPoint = convertToSVGCoordinates(point)
            pointsString.append("\(convertedPoint.x),\(convertedPoint.y) ")
        }
        
        let polygonString = #"<polygon points="\#(pointsString)" style="fill:\#(fillColor.svgColorString);opacity:\#(fillColor.a)" />"#
        lines.append(polygonString)
    }

    public func drawLine(startPoint p1: Point,
                         endPoint p2: Point,
                         strokeWidth thickness: Float,
                         strokeColor: Color = Color.black,
                         isDashed: Bool) {
        let p1 = convertToSVGCoordinates(p1)
        let p2 = convertToSVGCoordinates(p2)
        var line : String
        if (isDashed) {
            line = #"<line x1="\#(p1.x)" y1="\#(p1.y)" x2="\#(p2.x)" y2="\#(p2.y)" style="stroke:\#(strokeColor.svgColorString);stroke-width:\#(thickness);opacity:\#(strokeColor.a);stroke-linecap:butt;stroke-dasharray:4 1" />"#
        }
        else {
            line = #"<line x1="\#(p1.x)" y1="\#(p1.y)" x2="\#(p2.x)" y2="\#(p2.y)" style="stroke:\#(strokeColor.svgColorString);stroke-width:\#(thickness);opacity:\#(strokeColor.a);stroke-linecap:butt" />"#
        }
        lines.append(line)
    }

    public func drawPolyline(_ polyline: Polyline,
                              strokeWidth thickness: Float,
                              strokeColor: Color,
                              isDashed: Bool) {
        let pointsString = polyline.points.lazy.map { point in
            let convertedPoint = self.convertToSVGCoordinates(point)
            return "\(convertedPoint.x),\(convertedPoint.y)"
        }.joined(separator: " ")

        let dashedString = isDashed ? "stroke-dasharray:4 1;" : ""

        lines.append(#"<polyline points="\#(pointsString)" style="stroke:\#(strokeColor.svgColorString);stroke-width:\#(thickness);opacity:\#(strokeColor.a);stroke-linecap:butt;fill:none;\#(dashedString)" />"#)
    }

    public func drawText(text s: String,
                         location p: Point,
                         textSize size: Float,
                         color: Color,
                         strokeWidth thickness: Float,
                         angle: Float){
        let p = convertToSVGCoordinates(p)
        let text = #"<text font-size="\#(size)" font-family="\#(fontFamily)" x="\#(p.x)" y="\#(p.y)" style="stroke:\#(color.svgColorString);stroke-width:\#(thickness/4);fill:\#(color.svgColorString);opacity:\#(color.a);" transform="rotate(\#(-angle),\#(p.x),\#(p.y))">\#(s)</text>"#
        lines.append(text)
    }

    public func getTextLayoutSize(text: String, textSize size: Float) -> Size {
        var width: Float = 0
        let scaleFactor = size/100.0

        for i in 0..<text.count {
          let index =  text.index(text.startIndex, offsetBy: i)
          guard let asciiVal = text[index].ascii else { continue }
          width = width + Float(Self.LCARS_CHAR_SIZE_ARRAY[Int(asciiVal)])
        }

        return Size(width: width*scaleFactor + 25, height: size)
    }

    public func drawOutput(fileName name: String) throws {
        try savePlotImage(fileName: name)
    }

    func savePlotImage(fileName name: String) throws {
        // Build the document.
        let header = #"<svg height="\#(imageSize.height)" width="\#(imageSize.width)" version="4.0" xmlns="http://www.w3.org/2000/svg" xmlns:xlink= "http://www.w3.org/1999/xlink">"#
            + "\n" + #"<rect width="100%" height="100%" fill="white"/>"#
        let font = #"<defs><style>@import url("https://fonts.googleapis.com/css?family=\#(fontFamily)");</style></defs>"#
        let image = header + "\n" + font + "\n" + lines.joined(separator: "\n") + "\n</svg>"

        let url = URL(fileURLWithPath: "\(name).svg")
        try image.write(to: url, atomically: true, encoding: .utf8)
    }

}

extension Color {
    var svgColorString: String {
        return "rgb(\(r*255.0),\(g*255.0),\(b*255.0))"
    }
}
