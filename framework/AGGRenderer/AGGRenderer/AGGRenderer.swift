import Foundation
import CAGGRenderer
import SwiftPlot

public class AGGRenderer: Renderer{

    var initialized = false
    public var xOffset: Float = 0
    public var yOffset: Float = 0

    public var plotDimensions: PlotDimensions {
        willSet {
            if (initialized) {
                agg_object = initializePlot(newValue.frameWidth, newValue.frameHeight, newValue.subWidth, newValue.subHeight)
            }
        }
    }

    var agg_object: UnsafeRawPointer

    public init(width w: Float = 1000, height h: Float = 660) {
        initialized = false
        plotDimensions = PlotDimensions(frameWidth: w, frameHeight: h)
        agg_object = initializePlot(plotDimensions.frameWidth, plotDimensions.frameHeight, plotDimensions.subWidth, plotDimensions.subHeight)
        initialized = true
    }

    public func drawRect(topLeftPoint p1: Point, topRightPoint p2: Point, bottomRightPoint p3: Point, bottomLeftPoint p4: Point, strokeWidth thickness: Float, strokeColor: Color = Color.black, isOriginShifted: Bool) {
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
        draw_rect(x, y, thickness, strokeColor.r, strokeColor.g, strokeColor.b, strokeColor.a, isOriginShifted, agg_object)
    }

    public func drawSolidRect(topLeftPoint p1: Point, topRightPoint p2: Point, bottomRightPoint p3: Point, bottomLeftPoint p4: Point, fillColor: Color = Color.white, hatchPattern: BarGraphSeriesOptions.Hatching, isOriginShifted: Bool) {
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
        draw_solid_rect(x, y, fillColor.r, fillColor.g, fillColor.b, fillColor.a, Int32(hatchPattern.rawValue), isOriginShifted, agg_object)
    }

    public func drawSolidRectWithBorder(topLeftPoint p1: Point,topRightPoint p2: Point,bottomRightPoint p3: Point,bottomLeftPoint p4: Point, strokeWidth thickness: Float, fillColor: Color = Color.white, borderColor: Color = Color.black, isOriginShifted: Bool) {
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

        draw_solid_rect(x, y, fillColor.r, fillColor.g, fillColor.b, fillColor.a, 0, isOriginShifted, agg_object)
        draw_rect(x, y, thickness, borderColor.r, borderColor.g, borderColor.b, borderColor.a, isOriginShifted, agg_object)
    }

    public func drawSolidCircle(center c: Point, radius r: Float, fillColor: Color, isOriginShifted: Bool) {
      draw_solid_circle(c.x, c.y, r, fillColor.r, fillColor.g, fillColor.b, fillColor.a, isOriginShifted, agg_object)
    }

    public func drawSolidTriangle(point1: Point, point2: Point, point3: Point, fillColor: Color, isOriginShifted: Bool) {
      draw_solid_triangle(point1.x, point2.x, point3.x, point1.y, point2.y, point3.y, fillColor.r, fillColor.g, fillColor.b, fillColor.a, isOriginShifted, agg_object);
    }

    public func drawSolidPolygon(points: [Point], fillColor: Color, isOriginShifted: Bool) {
        var x = [Float]()
        var y = [Float]()
        for index in 0..<points.count {
            x.append(points[index].x)
            y.append(points[index].y)
        }
        draw_solid_polygon(x, y, Int32(points.count), fillColor.r, fillColor.g, fillColor.b, fillColor.a, isOriginShifted, agg_object)
    }

    public func drawLine(startPoint p1: Point, endPoint p2: Point, strokeWidth thickness: Float, strokeColor: Color = Color.black, isDashed: Bool, isOriginShifted: Bool) {
        var x = [Float]()
        var y = [Float]()

        x.append(p1.x + xOffset)
        x.append(p2.x + xOffset)
        y.append(p1.y + yOffset)
        y.append(p2.y + yOffset)

        draw_line(x, y, thickness, strokeColor.r, strokeColor.g, strokeColor.b, strokeColor.a, isDashed, isOriginShifted, agg_object)
    }

    public func drawPlotLines(points p: [Point], strokeWidth thickness: Float, strokeColor: Color, isDashed: Bool) {
        var x = [Float]()
        var y = [Float]()

        for index in 0..<p.count {
            x.append(p[index].x + xOffset)
            y.append(p[index].y + yOffset)
        }

        draw_plot_lines(x, y, Int32(p.count), thickness, strokeColor.r, strokeColor.g, strokeColor.b, strokeColor.a, isDashed, agg_object)
    }

    public func drawText(text s: String, location p: Point, textSize size: Float, strokeWidth thickness: Float, angle: Float, isOriginShifted: Bool){
        draw_text(s, p.x + xOffset, p.y + yOffset, size, thickness, angle, isOriginShifted, agg_object)
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

    deinit {
        delete_buffer(agg_object)
    }

}
