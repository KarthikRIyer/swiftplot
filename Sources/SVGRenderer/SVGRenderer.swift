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

    var LCARS_CHAR_SIZE_ARRAY: [Int]?

    var image: String

    public var xOffset: Float = 0
    public var yOffset: Float = 0

    public var plotDimensions: PlotDimensions {
        willSet{
            image = image.replacingOccurrences(of: "<svg height=\"\(plotDimensions.frameHeight)\" width=\"\(plotDimensions.frameWidth)\"", with: "<svg height=\"\(newValue.frameHeight)\" width=\"\(newValue.frameWidth)\"")
        }
    }

    var hatchingIncluded = Array(repeating: false,
                                 count: BarGraphSeriesOptions.Hatching.allCases.count)

    let forwardSlashHatch: String = "<defs><pattern id=\"forwardSlashHatch\" width=\"10\" height=\"10\" patternTransform=\"rotate(45 0 0)\" patternUnits=\"userSpaceOnUse\"><line x1=\"0\" y1=\"0\" x2=\"0\" y2=\"10\" style=\"stroke:black; stroke-width:1\" /></pattern></defs>"
    let backwardSlashHatch: String = "<defs><pattern id=\"backwardSlashHatch\" width=\"10\" height=\"10\" patternTransform=\"rotate(-45 0 0)\" patternUnits=\"userSpaceOnUse\"><line x1=\"0\" y1=\"0\" x2=\"0\" y2=\"10\" style=\"stroke:black; stroke-width:1\" /></pattern></defs>"
    let hollowCircleHatch: String = "<defs><pattern id=\"hollowCircleHatch\" width=\"10\" height=\"10\" patternUnits=\"userSpaceOnUse\"><circle cx=\"5\" cy=\"5\" r=\"3\" stroke=\"black\" stroke-width=\"1\" fill=\"none\"/></pattern></defs>"
    let filledCircleHatch: String = "<defs><pattern id=\"filledCircleHatch\" width=\"10\" height=\"10\" patternUnits=\"userSpaceOnUse\"><circle cx=\"5\" cy=\"5\" r=\"3\" stroke=\"black\" stroke-width=\"1\"/></pattern></defs>"
    let verticalHatch: String = "<defs><pattern id=\"verticalHatch\" width=\"10\" height=\"10\" patternUnits=\"userSpaceOnUse\"><line x1=\"5\" y1=\"0\" x2=\"5\" y2=\"10\" style=\"stroke:black; stroke-width:1\" /></pattern></defs>"
    let horizontalHatch: String = "<defs><pattern id=\"horizontalHatch\" width=\"10\" height=\"10\" patternUnits=\"userSpaceOnUse\"><line x1=\"0\" y1=\"5\" x2=\"10\" y2=\"5\" style=\"stroke:black; stroke-width:1\" /></pattern></defs>"
    let gridHatch: String = "<defs><pattern id=\"gridHatch\" width=\"10\" height=\"10\" patternUnits=\"userSpaceOnUse\"><line x1=\"0\" y1=\"5\" x2=\"10\" y2=\"5\" style=\"stroke:black; stroke-width:1\" /><line x1=\"5\" y1=\"0\" x2=\"5\" y2=\"10\" style=\"stroke:black; stroke-width:1\" /></pattern></defs>"
    let crossHatch: String = "<defs><pattern id=\"crossHatch\" width=\"10\" height=\"10\" patternUnits=\"userSpaceOnUse\"><line x1=\"0\" y1=\"0\" x2=\"10\" y2=\"10\" style=\"stroke:black; stroke-width:1\" /><line x1=\"0\" y1=\"10\" x2=\"10\" y2=\"0\" style=\"stroke:black; stroke-width:1\" /></pattern></defs>"
    var fontFamily: String = "Roboto"
    var font: String = ""
    public init(width w: Float = 1000, height h: Float = 660, fontFamily: String = "Roboto") {
        self.fontFamily = fontFamily
        plotDimensions = PlotDimensions(frameWidth: w, frameHeight: h)
        image = "<svg height=\"\(h)\" width=\"\(w)\" version=\"4.0\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink= \"http://www.w3.org/1999/xlink\">"
        image = image + "\n" + "<rect width=\"100%\" height=\"100%\" fill=\"white\"/>";
        font = "<defs><style>@import url(\"https://fonts.googleapis.com/css?family="+"\(fontFamily)\");</style></defs>"
        image = image + "\n" + font
        LCARS_CHAR_SIZE_ARRAY = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 17, 26, 46, 63, 42, 105, 45, 20, 25, 25, 47, 39, 21, 34, 26, 36, 36, 28, 36, 36, 36, 36, 36, 36, 36, 36, 27, 27, 36, 35, 36, 35, 65, 42, 43, 42, 44, 35, 34, 43, 46, 25, 39, 40, 31, 59, 47, 43, 41, 43, 44, 39, 28, 44, 43, 65, 37, 39, 34, 37, 42, 37, 50, 37, 32, 43, 43, 39, 43, 40, 30, 42, 45, 23, 25, 39, 23, 67, 45, 41, 43, 42, 30, 40, 28, 45, 33, 52, 33, 36, 31, 39, 26, 39, 55]
    }
    
    func convertToSVGCoordinates(_ rect: Rect) -> Rect {
        // Convert to SVG coordinate system (0,0 at top-left).
        var rect = rect.normalized
        rect.origin = Point(rect.origin.x + xOffset, rect.maxY - yOffset)
        return rect
    }

    public func drawRect(_ rect: Rect,
                         strokeWidth thickness: Float,
                         strokeColor: Color = Color.black,
                         isOriginShifted: Bool) {
        var rect = convertToSVGCoordinates(rect)
        if (isOriginShifted) {
            rect.origin.y += (0.1*plotDimensions.subHeight)
            rect.origin.y = plotDimensions.subHeight - rect.origin.y
            rect.origin.x += (0.1*plotDimensions.subWidth)
        }
        else {
            rect.origin.y = plotDimensions.subHeight - rect.origin.y
        }
        let rectStr = "<rect x=\"\(rect.origin.x)\" y=\"\(rect.origin.y)\" width=\"\(rect.size.width)\" height=\"\(rect.size.height)\" style=\"fill:rgb(255,255,255);stroke-width:\(thickness);stroke:\(strokeColor.svgColorString);opacity:1;fill-opacity:0;\" />"
        image = image + "\n" + rectStr
    }

    public func drawSolidRect(_ rect: Rect,
                              fillColor: Color = Color.white,
                              hatchPattern: BarGraphSeriesOptions.Hatching,
                              isOriginShifted: Bool) {
        var rect = convertToSVGCoordinates(rect)
        if (isOriginShifted) {
            rect.origin.y += (0.1*plotDimensions.subHeight) - yOffset
            rect.origin.x += xOffset + (0.1*plotDimensions.subWidth)
            rect.origin.y = plotDimensions.subHeight - rect.origin.y
        }
        else {
            rect.origin.y = plotDimensions.subHeight - rect.origin.y
        }
        let rectStr = "<rect x=\"\(rect.origin.x)\" y=\"\(rect.origin.y)\" width=\"\(rect.size.width)\" height=\"\(rect.size.height)\" style=\"fill:\(fillColor.svgColorString);stroke-width:0;stroke:rgb(0,0,0);opacity:\(fillColor.a)\" />"
        image = image + "\n" + rectStr
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
                image = image + forwardSlashHatch;
                hatchingIncluded[hatchPattern.rawValue] = true
            }
            patternName = "url(#forwardSlashHatch)"
        case .backwardSlash:
            if (!hatchingIncluded[hatchPattern.rawValue]) {
                image = image + backwardSlashHatch;
                hatchingIncluded[hatchPattern.rawValue] = true
            }
            patternName = "url(#backwardSlashHatch)"
        case .hollowCircle:
            if (!hatchingIncluded[hatchPattern.rawValue]) {
                image = image + hollowCircleHatch;
                hatchingIncluded[hatchPattern.rawValue] = true
            }
            patternName = "url(#hollowCircleHatch)"
        case .filledCircle:
            if (!hatchingIncluded[hatchPattern.rawValue]) {
                image = image + filledCircleHatch;
                hatchingIncluded[hatchPattern.rawValue] = true
            }
            patternName = "url(#filledCircleHatch)"
        case .vertical:
            if (!hatchingIncluded[hatchPattern.rawValue]) {
                image = image + verticalHatch;
                hatchingIncluded[hatchPattern.rawValue] = true
            }
            patternName = "url(#verticalHatch)"
        case .horizontal:
            if (!hatchingIncluded[hatchPattern.rawValue]) {
                image = image + horizontalHatch;
                hatchingIncluded[hatchPattern.rawValue] = true
            }
            patternName = "url(#horizontalHatch)"
        case .grid:
            if (!hatchingIncluded[hatchPattern.rawValue]) {
                image = image + gridHatch;
                hatchingIncluded[hatchPattern.rawValue] = true
            }
            patternName = "url(#gridHatch)"
        case .cross:
            if (!hatchingIncluded[hatchPattern.rawValue]) {
                image = image + crossHatch;
                hatchingIncluded[hatchPattern.rawValue] = true
            }
            patternName = "url(#crossHatch)"
        }
        let rectStr = "<rect x=\"\(rect.origin.x)\" y=\"\(rect.origin.y)\" width=\"\(rect.size.width)\" height=\"\(rect.size.height)\" style=\"fill:\(patternName);opacity:\(1)\" />"
        image = image + rectStr
    }

    public func drawSolidRectWithBorder(_ rect: Rect,
                                        strokeWidth thickness: Float,
                                        fillColor: Color = Color.white,
                                        borderColor: Color = Color.black,
                                        isOriginShifted: Bool) {
        var rect = convertToSVGCoordinates(rect)
        if (isOriginShifted) {
            rect.origin.y += (0.1*plotDimensions.subHeight)
            rect.origin.y = plotDimensions.subHeight - rect.origin.y
            rect.origin.x += (0.1*plotDimensions.subWidth)
        }
        else {
            rect.origin.y = plotDimensions.subHeight - rect.origin.y
        }

        let rectStr = "<rect x=\"\(rect.origin.x)\" y=\"\(rect.origin.y)\" width=\"\(rect.size.width)\" height=\"\(rect.size.height)\" style=\"fill:\(fillColor.svgColorString);stroke-width:\(thickness);stroke:\(borderColor.svgColorString);opacity:\(fillColor.a)\" />"
        image = image + "\n" + rectStr
    }

    public func drawSolidCircle(center c: Point,
                                radius r: Float,
                                fillColor: Color,
                                isOriginShifted: Bool) {
        var x = c.x + xOffset;
        var y = c.y - yOffset;
        if (isOriginShifted) {
            x = x + 0.1*plotDimensions.subWidth
            y = y + 0.1*plotDimensions.subHeight
        }
        y = plotDimensions.subHeight - y
        let circle: String = "<circle cx=\"\(x)\" cy=\"\(y)\" r=\"\(r)\"  style=\"fill:(\(fillColor.svgColorString);opacity:\(fillColor.a)\" />"
        image = image + "\n" + circle
    }

    public func drawSolidTriangle(point1: Point,
                                  point2: Point,
                                  point3: Point,
                                  fillColor: Color,
                                  isOriginShifted: Bool) {
        var x1 = point1.x + xOffset
        var x2 = point2.x + xOffset
        var x3 = point3.x + xOffset
        var y1 = point1.y - yOffset
        var y2 = point2.y - yOffset
        var y3 = point3.y - yOffset
        if (isOriginShifted) {
            x1 = x1 + 0.1*plotDimensions.subWidth
            x2 = x2 + 0.1*plotDimensions.subWidth
            x3 = x3 + 0.1*plotDimensions.subWidth
            y1 = y1 + 0.1*plotDimensions.subHeight
            y2 = y2 + 0.1*plotDimensions.subHeight
            y3 = y3 + 0.1*plotDimensions.subHeight
        }
        y1 = plotDimensions.subHeight - y1
        y2 = plotDimensions.subHeight - y2
        y3 = plotDimensions.subHeight - y3
        let triangle = "<polygon points=\"\(x1),\(y1) \(x2),\(y2) \(x3),\(y3)\" style=\"fill:\(fillColor.svgColorString);opacity:\(fillColor.a)\" />"
        image = image + "\n" + triangle
    }

    public func drawSolidPolygon(points: [Point],
                                 fillColor: Color,
                                 isOriginShifted: Bool) {
        var pts = [Point]()
        if (isOriginShifted) {
            for index in 0..<points.count {
                let x = points[index].x + 0.1*plotDimensions.subWidth + xOffset
                var y = points[index].y + 0.1*plotDimensions.subHeight - yOffset
                y = plotDimensions.subHeight - y
                pts.append(Point(x, y))
            }
        }
        else {
          for index in 0..<points.count {
              let x = points[index].x + xOffset
              var y = points[index].y - yOffset
              y = plotDimensions.subHeight - y
              pts.append(Point(x, y))
          }
        }
        var pointsString = ""
        for index in 0..<pts.count {
            pointsString = pointsString + "\(pts[index].x),\(pts[index].y) "
        }
        let polygon = "<polygon points=\"" + pointsString + "\" style=\"fill:\(fillColor.svgColorString);opacity:\(fillColor.a)\" />"
        image = image + "\n" + polygon
    }

    public func drawLine(startPoint p1: Point,
                         endPoint p2: Point,
                         strokeWidth thickness: Float,
                         strokeColor: Color = Color.black,
                         isDashed: Bool,
                         isOriginShifted: Bool) {
        var x0 = p1.x
        var y0 = p1.y
        var x1 = p2.x
        var y1 = p2.y
        if (isOriginShifted) {
            x0 = x0 + (0.1*plotDimensions.subWidth)
            y0 = y0 + (0.1*plotDimensions.subHeight)
            x1 = x1 + (0.1*plotDimensions.subWidth)
            y1 = y1 + (0.1*plotDimensions.subHeight)
        }
        y0 = plotDimensions.subHeight - y0
        y1 = plotDimensions.subHeight - y1
        var line : String
        if (isDashed) {
            line = "<line x1=\"\(x0 + xOffset)\" y1=\"\(y0 + yOffset)\" x2=\"\(x1 + xOffset)\" y2=\"\(y1 + yOffset)\" style=\"stroke:\(strokeColor.svgColorString);stroke-width:\(thickness);opacity:\(strokeColor.a);stroke-linecap:round;stroke-dasharray:4 1\" />"
        }
        else {
            line = "<line x1=\"\(x0 + xOffset)\" y1=\"\(y0 + yOffset)\" x2=\"\(x1 + xOffset)\" y2=\"\(y1 + yOffset)\" style=\"stroke:\(strokeColor.svgColorString);stroke-width:\(thickness);opacity:\(strokeColor.a);stroke-linecap:round\" />"
        }
        image = image + "\n" + line
    }

    public func drawPlotLines(points p: [Point],
                              strokeWidth thickness: Float,
                              strokeColor: Color,
                              isDashed: Bool) {
        for i in 0..<p.count-1 {
            drawLine(startPoint: p[i], endPoint: p[i+1], strokeWidth: thickness, strokeColor: strokeColor, isDashed: isDashed, isOriginShifted: true)
        }
    }

    public func drawText(text s: String,
                         location p: Point,
                         textSize size: Float,
                         color: Color,
                         strokeWidth thickness: Float,
                         angle: Float,
                         isOriginShifted: Bool){
        var x1 = p.x
        var y1 = plotDimensions.subHeight - p.y
        if (isOriginShifted) {
            x1 = x1 + 0.1*plotDimensions.subWidth
            y1 = y1 - 0.1*plotDimensions.subHeight
        }
        let text = #"<text font-size="\#(size)" font-family="\#(fontFamily)" x="\#(x1 + xOffset)" y="\#(y1 + yOffset)" style="stroke:\#(color.svgColorString);stroke-width:\#(thickness/4)" transform="rotate(\#(-angle),\#(x1+xOffset),\#(y1 + yOffset))">\#(s)</text>"#
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

}

extension Color {
    var svgColorString: String {
        return "rgb(\(r*255.0),\(g*255.0),\(b*255.0))"
    }
}
