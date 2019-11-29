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
                agg_object = initializePlot(newValue.frameWidth,
                                            newValue.frameHeight,
                                            newValue.subWidth,
                                            newValue.subHeight,
                                            fontPath)
            }
        }
    }
    var agg_object: UnsafeRawPointer
    var fontPath = ""

    public init(width w: Float = 1000, height h: Float = 660, fontPath: String = "") {
        initialized = false
        self.fontPath = fontPath
        plotDimensions = PlotDimensions(frameWidth: w, frameHeight: h)
        agg_object = initializePlot(plotDimensions.frameWidth,
                                    plotDimensions.frameHeight,
                                    plotDimensions.subWidth,
                                    plotDimensions.subHeight,
                                    fontPath)
        initialized = true
    }
    
    func getPoints(from rect: Rect) -> (tL: Point, tR: Point, bL: Point, bR: Point) {
        let rect = rect.normalized
        return (
            Point(rect.origin.x, rect.maxY),
            Point(rect.maxX, rect.maxY),
            rect.origin,
            Point(rect.maxX, rect.origin.y)
        )
    }

    public func drawRect(_ rect: Rect,
                         strokeWidth thickness: Float,
                         strokeColor: Color = Color.black) {
        var x = [Float]()
        var y = [Float]()
        let pts = getPoints(from: rect)
        x.append(pts.tL.x + xOffset)
        x.append(pts.tR.x + xOffset)
        x.append(pts.bR.x + xOffset)
        x.append(pts.bL.x + xOffset)
        y.append(pts.tL.y + yOffset)
        y.append(pts.tR.y + yOffset)
        y.append(pts.bR.y + yOffset)
        y.append(pts.bL.y + yOffset)
        draw_rect(x,
                  y,
                  thickness,
                  strokeColor.r,
                  strokeColor.g,
                  strokeColor.b,
                  strokeColor.a,
                  agg_object)
    }

    public func drawSolidRect(_ rect: Rect,
                              fillColor: Color = Color.white,
                              hatchPattern: BarGraphSeriesOptions.Hatching) {
        var x = [Float]()
        var y = [Float]()
        let pts = getPoints(from: rect)
        x.append(pts.tL.x + xOffset)
        x.append(pts.tR.x + xOffset)
        x.append(pts.bR.x + xOffset)
        x.append(pts.bL.x + xOffset)
        y.append(pts.tL.y + yOffset)
        y.append(pts.tR.y + yOffset)
        y.append(pts.bR.y + yOffset)
        y.append(pts.bL.y + yOffset)
        draw_solid_rect(x,
                        y,
                        fillColor.r,
                        fillColor.g,
                        fillColor.b,
                        fillColor.a,
                        Int32(hatchPattern.rawValue),
                        agg_object)
    }

    public func drawSolidRectWithBorder(_ rect: Rect,
                                        strokeWidth thickness: Float,
                                        fillColor: Color = Color.white,
                                        borderColor: Color = Color.black) {
        var x = [Float]()
        var y = [Float]()

        let pts = getPoints(from: rect)
        x.append(pts.tL.x + xOffset)
        x.append(pts.tR.x + xOffset)
        x.append(pts.bR.x + xOffset)
        x.append(pts.bL.x + xOffset)
        y.append(pts.tL.y + yOffset)
        y.append(pts.tR.y + yOffset)
        y.append(pts.bR.y + yOffset)
        y.append(pts.bL.y + yOffset)

        draw_solid_rect(x,
                        y,
                        fillColor.r,
                        fillColor.g,
                        fillColor.b,
                        fillColor.a,
                        0,
                        agg_object)
        draw_rect(x,
                  y,
                  thickness,
                  borderColor.r,
                  borderColor.g,
                  borderColor.b,
                  borderColor.a,
                  agg_object)
    }

    public func drawSolidCircle(center c: Point,
                                radius r: Float,
                                fillColor: Color) {
      draw_solid_circle(c.x + xOffset,
                        c.y + yOffset,
                        r,
                        fillColor.r,
                        fillColor.g,
                        fillColor.b,
                        fillColor.a,
                        agg_object)
    }

    public func drawSolidTriangle(point1: Point,
                                  point2: Point,
                                  point3: Point,
                                  fillColor: Color) {
      draw_solid_triangle(point1.x + xOffset,
                          point2.x + xOffset,
                          point3.x + xOffset,
                          point1.y + yOffset,
                          point2.y + yOffset,
                          point3.y + yOffset,
                          fillColor.r,
                          fillColor.g,
                          fillColor.b,
                          fillColor.a,
                          agg_object);
    }

    public func drawSolidPolygon(points: [Point],
                                 fillColor: Color) {
        var x = [Float]()
        var y = [Float]()
        for index in 0..<points.count {
            x.append(points[index].x + xOffset)
            y.append(points[index].y + yOffset)
        }
        draw_solid_polygon(x,
                           y,
                           Int32(points.count),
                           fillColor.r,
                           fillColor.g,
                           fillColor.b,
                           fillColor.a,
                           agg_object)
    }

    public func drawLine(startPoint p1: Point,
                         endPoint p2: Point,
                         strokeWidth thickness: Float,
                         strokeColor: Color = Color.black,
                         isDashed: Bool) {
        var x = [Float]()
        var y = [Float]()

        x.append(p1.x + xOffset)
        x.append(p2.x + xOffset)
        y.append(p1.y + yOffset)
        y.append(p2.y + yOffset)

        draw_line(x,
                  y,
                  thickness,
                  strokeColor.r,
                  strokeColor.g,
                  strokeColor.b,
                  strokeColor.a,
                  isDashed,
                  agg_object)
    }

    public func drawPlotLines(points p: [Point],
                              strokeWidth thickness: Float,
                              strokeColor: Color,
                              isDashed: Bool) {
        var x = [Float]()
        var y = [Float]()

        for index in 0..<p.count {
            x.append(p[index].x + xOffset)
            y.append(p[index].y + yOffset)
        }

        draw_plot_lines(x,
                        y,
                        Int32(p.count),
                        thickness,
                        strokeColor.r,
                        strokeColor.g,
                        strokeColor.b,
                        strokeColor.a,
                        isDashed,
                        agg_object)
    }

    public func drawText(text s: String,
                         location p: Point,
                         textSize size: Float,
                         color: Color,
                         strokeWidth thickness: Float,
                         angle: Float){
        draw_text(s,
                  p.x + xOffset,
                  p.y + yOffset,
                  size,
                  color.r,
                  color.g,
                  color.b,
                  color.a,
                  thickness,
                  angle,
                  agg_object)
    }

    public func getTextLayoutSize(text: String, textSize size: Float) -> Size {
        var width: Float = 0, height: Float = 0
        get_text_size(text, size, &width, &height, agg_object)
        return Size(width: width, height: height)
    }

    public func drawOutput(fileName name: String) {
        save_image(name, agg_object)
    }

    public func base64Png() -> String{
        let pngBufferPointer: UnsafePointer<UInt8> = get_png_buffer(agg_object)
        let bufferSize: Int = Int(get_png_buffer_size(agg_object))
        return encodeBase64PNG(pngBufferPointer: pngBufferPointer,
                               bufferSize: bufferSize)
    }

    deinit {
        delete_buffer(agg_object)
    }

}