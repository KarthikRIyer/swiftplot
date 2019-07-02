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
                                            newValue.subHeight)
            }
        }
    }

    var agg_object: UnsafeRawPointer

    public init(width w: Float = 1000, height h: Float = 660) {
        initialized = false
        plotDimensions = PlotDimensions(frameWidth: w, frameHeight: h)
        agg_object = initializePlot(plotDimensions.frameWidth,
                                    plotDimensions.frameHeight,
                                    plotDimensions.subWidth,
                                    plotDimensions.subHeight)
        initialized = true
    }

    public func drawRect(topLeftPoint p1: Pair<FloatConvertible,FloatConvertible>,
                         topRightPoint p2: Pair<FloatConvertible,FloatConvertible>,
                         bottomRightPoint p3: Pair<FloatConvertible,FloatConvertible>,
                         bottomLeftPoint p4: Pair<FloatConvertible,FloatConvertible>,
                         strokeWidth thickness: Float,
                         strokeColor: Color = Color.black,
                         isOriginShifted: Bool) {
        var x = [Float]()
        var y = [Float]()
        x.append(Float(p1.x) + xOffset)
        x.append(Float(p2.x) + xOffset)
        x.append(Float(p3.x) + xOffset)
        x.append(Float(p4.x) + xOffset)
        y.append(Float(p1.y) + yOffset)
        y.append(Float(p2.y) + yOffset)
        y.append(Float(p3.y) + yOffset)
        y.append(Float(p4.y) + yOffset)
        draw_rect(x,
                  y,
                  thickness,
                  strokeColor.r,
                  strokeColor.g,
                  strokeColor.b,
                  strokeColor.a,
                  isOriginShifted,
                  agg_object)
    }

    public func drawSolidRect(topLeftPoint p1: Pair<FloatConvertible,FloatConvertible>,
                              topRightPoint p2: Pair<FloatConvertible,FloatConvertible>,
                              bottomRightPoint p3: Pair<FloatConvertible,FloatConvertible>,
                              bottomLeftPoint p4: Pair<FloatConvertible,FloatConvertible>,
                              fillColor: Color = Color.white,
                              hatchPattern: BarGraphSeriesOptions.Hatching,
                              isOriginShifted: Bool) {
        var x = [Float]()
        var y = [Float]()
        x.append(Float(p1.x) + xOffset)
        x.append(Float(p2.x) + xOffset)
        x.append(Float(p3.x) + xOffset)
        x.append(Float(p4.x) + xOffset)
        y.append(Float(p1.y) + yOffset)
        y.append(Float(p2.y) + yOffset)
        y.append(Float(p3.y) + yOffset)
        y.append(Float(p4.y) + yOffset)
        draw_solid_rect(x,
                        y,
                        fillColor.r,
                        fillColor.g,
                        fillColor.b,
                        fillColor.a,
                        Int32(hatchPattern.rawValue),
                        isOriginShifted,
                        agg_object)
    }

    public func drawSolidRectWithBorder(topLeftPoint p1: Pair<FloatConvertible,FloatConvertible>,
                                        topRightPoint p2: Pair<FloatConvertible,FloatConvertible>,
                                        bottomRightPoint p3: Pair<FloatConvertible,FloatConvertible>,
                                        bottomLeftPoint p4: Pair<FloatConvertible,FloatConvertible>,
                                        strokeWidth thickness: Float,
                                        fillColor: Color = Color.white,
                                        borderColor: Color = Color.black,
                                        isOriginShifted: Bool) {
        var x = [Float]()
        var y = [Float]()

        x.append(Float(p1.x) + xOffset)
        x.append(Float(p2.x) + xOffset)
        x.append(Float(p3.x) + xOffset)
        x.append(Float(p4.x) + xOffset)
        y.append(Float(p1.y) + yOffset)
        y.append(Float(p2.y) + yOffset)
        y.append(Float(p3.y) + yOffset)
        y.append(Float(p4.y) + yOffset)

        draw_solid_rect(x,
                        y,
                        fillColor.r,
                        fillColor.g,
                        fillColor.b,
                        fillColor.a,
                        0,
                        isOriginShifted,
                        agg_object)
        draw_rect(x,
                  y,
                  thickness,
                  borderColor.r,
                  borderColor.g,
                  borderColor.b,
                  borderColor.a,
                  isOriginShifted,
                  agg_object)
    }

    public func drawSolidCircle(center c: Pair<FloatConvertible,FloatConvertible>,
                                radius r: Float,
                                fillColor: Color,
                                isOriginShifted: Bool) {
      draw_solid_circle(Float(c.x),
                        Float(c.y),
                        r,
                        fillColor.r,
                        fillColor.g,
                        fillColor.b,
                        fillColor.a,
                        isOriginShifted,
                        agg_object)
    }

    public func drawSolidTriangle(point1: Pair<FloatConvertible,FloatConvertible>,
                                  point2: Pair<FloatConvertible,FloatConvertible>,
                                  point3: Pair<FloatConvertible,FloatConvertible>,
                                  fillColor: Color,
                                  isOriginShifted: Bool) {
      draw_solid_triangle(Float(point1.x),
                          Float(point2.x),
                          Float(point3.x),
                          Float(point1.y),
                          Float(point2.y),
                          Float(point3.y),
                          fillColor.r,
                          fillColor.g,
                          fillColor.b,
                          fillColor.a,
                          isOriginShifted,
                          agg_object);
    }

    public func drawSolidPolygon(points: [Pair<FloatConvertible,FloatConvertible>],
                                 fillColor: Color,
                                 isOriginShifted: Bool) {
        var x = [Float]()
        var y = [Float]()
        for index in 0..<points.count {
            x.append(Float(points[index].x))
            y.append(Float(points[index].y))
        }
        draw_solid_polygon(x,
                           y,
                           Int32(points.count),
                           fillColor.r,
                           fillColor.g,
                           fillColor.b,
                           fillColor.a,
                           isOriginShifted,
                           agg_object)
    }

    public func drawLine(startPoint p1: Pair<FloatConvertible,FloatConvertible>,
                         endPoint p2: Pair<FloatConvertible,FloatConvertible>,
                         strokeWidth thickness: Float,
                         strokeColor: Color = Color.black,
                         isDashed: Bool,
                         isOriginShifted: Bool) {
        var x = [Float]()
        var y = [Float]()

        x.append(Float(p1.x) + xOffset)
        x.append(Float(p2.x) + xOffset)
        y.append(Float(p1.y) + yOffset)
        y.append(Float(p2.y) + yOffset)

        draw_line(x,
                  y,
                  thickness,
                  strokeColor.r,
                  strokeColor.g,
                  strokeColor.b,
                  strokeColor.a,
                  isDashed,
                  isOriginShifted,
                  agg_object)
    }

    public func drawPlotLines(points p: [Pair<FloatConvertible,FloatConvertible>],
                              strokeWidth thickness: Float,
                              strokeColor: Color,
                              isDashed: Bool) {
        var x = [Float]()
        var y = [Float]()

        for index in 0..<p.count {
            x.append(Float(p[index].x) + xOffset)
            y.append(Float(p[index].y) + yOffset)
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
                         location p: Pair<FloatConvertible,FloatConvertible>,
                         textSize size: Float,
                         strokeWidth thickness: Float,
                         angle: Float,
                         isOriginShifted: Bool){
        draw_text(s,
                  Float(p.x) + xOffset,
                  Float(p.y) + yOffset,
                  size,
                  thickness,
                  angle,
                  isOriginShifted,
                  agg_object)
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
        return encodeBase64PNG(pngBufferPointer: pngBufferPointer,
                               bufferSize: bufferSize)
    }

    deinit {
        delete_buffer(agg_object)
    }

}
