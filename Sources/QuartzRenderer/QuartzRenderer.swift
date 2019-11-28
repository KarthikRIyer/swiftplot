import Foundation
import SwiftPlot

#if canImport(CoreGraphics)
import CoreGraphics

#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

@available(tvOS 13, watchOS 13, *)
public class QuartzRenderer: Renderer {
    static let colorSpace = CGColorSpaceCreateDeviceRGB()
    static let bitmapInfo = CGImageAlphaInfo.premultipliedFirst.rawValue
    
    var context: CGContext
    var fontPath = ""
    public var xOffset: Float = 0
    public var yOffset: Float = 0
    
    public var plotDimensions: PlotDimensions {
        didSet {
            context = CGContext(data: nil,
                                width: Int(plotDimensions.frameWidth),
                                height: Int(plotDimensions.frameHeight),
                                bitsPerComponent: 8,
                                bytesPerRow: 0,
                                space: Self.colorSpace,
                                bitmapInfo: Self.bitmapInfo)!
            let rect = CGRect(x: 0,
                              y: 0,
                              width: Int(plotDimensions.frameWidth),
                              height: Int(plotDimensions.frameHeight))
            context.setFillColor(Color.white.cgColor)
            context.fill(rect)
        }
    }

    public init(width w: Float = 1000, height h: Float = 660, fontPath: String = "") {
        plotDimensions = PlotDimensions(frameWidth: w, frameHeight: h)
        context = CGContext(data: nil,
                            width: Int(plotDimensions.frameWidth),
                            height: Int(plotDimensions.frameHeight),
                            bitsPerComponent: 8,
                            bytesPerRow: 0,
                            space: Self.colorSpace,
                            bitmapInfo: Self.bitmapInfo)!
        let rect = CGRect(x: 0,
                          y: 0,
                          width: Int(plotDimensions.frameWidth),
                          height: Int(plotDimensions.frameHeight))
        context.setFillColor(Color.white.cgColor)
        context.fill(rect)
    }

    public func drawRect(_ rect: Rect,
                         strokeWidth thickness: Float,
                         strokeColor: Color = Color.black,
                         isOriginShifted: Bool) {
        var rect = rect.normalized
        rect.origin.x += xOffset
        rect.origin.y += yOffset
        if (isOriginShifted) {
            rect.origin.y += (0.1*plotDimensions.subHeight)
            rect.origin.x += (0.1*plotDimensions.subWidth)
        }
        context.setStrokeColor(strokeColor.cgColor)
        context.setLineWidth(CGFloat(thickness))
        context.stroke(CGRect(rect))
    }

    public func drawSolidRect(_ rect: Rect,
                              fillColor: Color = Color.white,
                              hatchPattern: BarGraphSeriesOptions.Hatching,
                              isOriginShifted: Bool) {
        var rect = rect.normalized
        if (isOriginShifted) {
            rect.origin.y += (0.1*plotDimensions.subHeight) + yOffset
            rect.origin.x += (0.1*plotDimensions.subWidth) + xOffset
            context.setFillColor(fillColor.cgColor)
            context.fill(CGRect(rect))
            drawHatchingRect(rect, hatchPattern: hatchPattern)
        }
        else {
            rect.origin.y += yOffset
            rect.origin.x += xOffset
            context.setFillColor(fillColor.cgColor)
            context.fill(CGRect(rect))
            drawHatchingRect(rect, hatchPattern: hatchPattern)
        }
    }
    
    // Note: we assume this rect has already been offset-shifted.
    func drawHatchingRect(_ rect: Rect,
                          hatchPattern: BarGraphSeriesOptions.Hatching) {
        switch (hatchPattern) {
        case .none:
            break
        case .forwardSlash:
            let drawPattern: CGPatternDrawPatternCallback = { _, context in
                let line = CGMutablePath()
                line.move(to: CGPoint(x: Double(0), y: Double(0)))
                line.addLine(to: CGPoint(x: Double(10), y: Double(10)))
                context.setStrokeColor(Color.black.cgColor)
                context.setLineWidth(CGFloat(1))
                context.addPath(line)
                context.strokePath()
            }
            var callbacks = CGPatternCallbacks(
                version: 0, drawPattern: drawPattern, releaseInfo: nil)
            let pattern = CGPattern(
                info: nil,
                bounds: CGRect(x: 0, y: 0, width: 10, height: 10),
                matrix: .identity,
                xStep: 10,
                yStep: 10,
                tiling: .constantSpacing,
                isColored: true,
                callbacks: &callbacks)
            let patternSpace = CGColorSpace(patternBaseSpace: nil)!
            context.setFillColorSpace(patternSpace)
            var alpha : CGFloat = 1.0
            context.setFillPattern(pattern!, colorComponents: &alpha)
            context.fill(CGRect(rect))
        case .backwardSlash:
            let drawPattern: CGPatternDrawPatternCallback = { _, context in
                let line = CGMutablePath()
                line.move(to: CGPoint(x: Double(10), y: Double(0)))
                line.addLine(to: CGPoint(x: Double(0), y: Double(10)))
                context.setStrokeColor(Color.black.cgColor)
                context.setLineWidth(CGFloat(1))
                context.addPath(line)
                context.strokePath()
            }
            var callbacks = CGPatternCallbacks(
                version: 0, drawPattern: drawPattern, releaseInfo: nil)
            let pattern = CGPattern(
                info: nil,
                bounds: CGRect(x: 0, y: 0, width: 10, height: 10),
                matrix: .identity,
                xStep: 10,
                yStep: 10,
                tiling: .constantSpacing,
                isColored: true,
                callbacks: &callbacks)
            let patternSpace = CGColorSpace(patternBaseSpace: nil)!
            context.setFillColorSpace(patternSpace)
            var alpha : CGFloat = 1.0
            context.setFillPattern(pattern!, colorComponents: &alpha)
            context.fill(CGRect(rect))

        case .hollowCircle:
            let drawPattern: CGPatternDrawPatternCallback = { _, context in
                context.addArc(
                    center: CGPoint(x: 0, y: 0), radius: 4.0,
                    startAngle: 0, endAngle: CGFloat(2.0 * .pi),
                    clockwise: false)
                context.setStrokeColor(Color.black.cgColor)
                context.setLineWidth(1)
                context.strokePath()
            }
            var callbacks = CGPatternCallbacks(
                version: 0, drawPattern: drawPattern, releaseInfo: nil)
            let pattern = CGPattern(
                info: nil,
                bounds: CGRect(x: 0, y: 0, width: 20, height: 20),
                matrix: .identity,
                xStep: 12,
                yStep: 12,
                tiling: .constantSpacing,
                isColored: true,
                callbacks: &callbacks)
            let patternSpace = CGColorSpace(patternBaseSpace: nil)!
            context.setFillColorSpace(patternSpace)
            var alpha : CGFloat = 1.0
            context.setFillPattern(pattern!, colorComponents: &alpha)
            context.fill(CGRect(rect))
            
        case .filledCircle:
            let drawPattern: CGPatternDrawPatternCallback = { _, context in
                context.addArc(
                    center: CGPoint(x: 0, y: 0), radius: 4.0,
                    startAngle: 0, endAngle: CGFloat(2.0 * .pi),
                    clockwise: false)
                context.setFillColor(Color.black.cgColor)
                context.fillPath()
            }
            var callbacks = CGPatternCallbacks(
                version: 0, drawPattern: drawPattern, releaseInfo: nil)
            let pattern = CGPattern(
                info: nil,
                bounds: CGRect(x: 0, y: 0, width: 20, height: 20),
                matrix: .identity,
                xStep: 12,
                yStep: 12,
                tiling: .constantSpacing,
                isColored: true,
                callbacks: &callbacks)
            let patternSpace = CGColorSpace(patternBaseSpace: nil)!
            context.setFillColorSpace(patternSpace)
            var alpha : CGFloat = 1.0
            context.setFillPattern(pattern!, colorComponents: &alpha)
            context.fill(CGRect(rect))

        case .vertical:
            let drawPattern: CGPatternDrawPatternCallback = { _, context in
                let line = CGMutablePath()
                line.move(to: CGPoint(x: Double(5), y: Double(0)))
                line.addLine(to: CGPoint(x: Double(5), y: Double(10)))
                context.setStrokeColor(Color.black.cgColor)
                context.setLineWidth(CGFloat(1))
                context.addPath(line)
                context.strokePath()
            }
            var callbacks = CGPatternCallbacks(
                version: 0, drawPattern: drawPattern, releaseInfo: nil)
            let pattern = CGPattern(
                info: nil,
                bounds: CGRect(x: 0, y: 0, width: 10, height: 10),
                matrix: .identity,
                xStep: 10,
                yStep: 10,
                tiling: .constantSpacing,
                isColored: true,
                callbacks: &callbacks)
            let patternSpace = CGColorSpace(patternBaseSpace: nil)!
            context.setFillColorSpace(patternSpace)
            var alpha : CGFloat = 1.0
            context.setFillPattern(pattern!, colorComponents: &alpha)
            context.fill(CGRect(rect))
            
        case .horizontal:
            let drawPattern: CGPatternDrawPatternCallback = { _, context in
                let line = CGMutablePath()
                line.move(to: CGPoint(x: Double(0), y: Double(5)))
                line.addLine(to: CGPoint(x: Double(10), y: Double(5)))
                context.setStrokeColor(Color.black.cgColor)
                context.setLineWidth(CGFloat(1))
                context.addPath(line)
                context.strokePath()
            }
            var callbacks = CGPatternCallbacks(
                version: 0, drawPattern: drawPattern, releaseInfo: nil)
            let pattern = CGPattern(
                info: nil,
                bounds: CGRect(x: 0, y: 0, width: 10, height: 10),
                matrix: .identity,
                xStep: 10,
                yStep: 10,
                tiling: .constantSpacing,
                isColored: true,
                callbacks: &callbacks)
            let patternSpace = CGColorSpace(patternBaseSpace: nil)!
            context.setFillColorSpace(patternSpace)
            var alpha : CGFloat = 1.0
            context.setFillPattern(pattern!, colorComponents: &alpha)
            context.fill(CGRect(rect))
            
        case .grid:
            let drawPattern: CGPatternDrawPatternCallback = { _, context in
                let line = CGMutablePath()
                line.move(to: CGPoint(x: Double(0), y: Double(5)))
                line.addLine(to: CGPoint(x: Double(10), y: Double(5)))
                line.move(to: CGPoint(x: Double(5), y: Double(0)))
                line.addLine(to: CGPoint(x: Double(5), y: Double(10)))
                context.setStrokeColor(Color.black.cgColor)
                context.setLineWidth(CGFloat(1))
                context.addPath(line)
                context.strokePath()
            }
            var callbacks = CGPatternCallbacks(
                version: 0, drawPattern: drawPattern, releaseInfo: nil)
            let pattern = CGPattern(
                info: nil,
                bounds: CGRect(x: 0, y: 0, width: 10, height: 10),
                matrix: .identity,
                xStep: 10,
                yStep: 10,
                tiling: .constantSpacing,
                isColored: true,
                callbacks: &callbacks)
            let patternSpace = CGColorSpace(patternBaseSpace: nil)!
            context.setFillColorSpace(patternSpace)
            var alpha : CGFloat = 1.0
            context.setFillPattern(pattern!, colorComponents: &alpha)
            context.fill(CGRect(rect))
            
        case .cross:
            let drawPattern: CGPatternDrawPatternCallback = { _, context in
                let line = CGMutablePath()
                line.move(to: CGPoint(x: Double(0), y: Double(0)))
                line.addLine(to: CGPoint(x: Double(10), y: Double(10)))
                line.move(to: CGPoint(x: Double(0), y: Double(10)))
                line.addLine(to: CGPoint(x: Double(10), y: Double(00)))
                context.setStrokeColor(Color.black.cgColor)
                context.setLineWidth(CGFloat(1))
                context.addPath(line)
                context.strokePath()
            }
            var callbacks = CGPatternCallbacks(
                version: 0, drawPattern: drawPattern, releaseInfo: nil)
            let pattern = CGPattern(
                info: nil,
                bounds: CGRect(x: 0, y: 0, width: 10, height: 10),
                matrix: .identity,
                xStep: 10,
                yStep: 10,
                tiling: .constantSpacing,
                isColored: true,
                callbacks: &callbacks)
            let patternSpace = CGColorSpace(patternBaseSpace: nil)!
            context.setFillColorSpace(patternSpace)
            var alpha : CGFloat = 1.0
            context.setFillPattern(pattern!, colorComponents: &alpha)
            context.fill(CGRect(rect))
        }
    }

    public func drawSolidRectWithBorder(_ rect: Rect,
                                        strokeWidth thickness: Float,
                                        fillColor: Color = Color.white,
                                        borderColor: Color = Color.black,
                                        isOriginShifted: Bool) {
        var rect = rect.normalized
        rect.origin.x += xOffset
        rect.origin.y += yOffset
        if (isOriginShifted) {
            rect.origin.y += (0.1*plotDimensions.subHeight)
            rect.origin.x += (0.1*plotDimensions.subWidth)
        }

        context.setFillColor(fillColor.cgColor)
        context.fill(CGRect(rect))
        context.setStrokeColor(borderColor.cgColor)
        context.setLineWidth(CGFloat(thickness))
        context.stroke(CGRect(rect))
    }

    public func drawSolidCircle(center c: Point,
                                radius r: Float,
                                fillColor: Color,
                                isOriginShifted: Bool) {
        var x = c.x + xOffset;
        var y = c.y + yOffset;
        if (isOriginShifted) {
            x = x + 0.1*plotDimensions.subWidth
            y = y + 0.1*plotDimensions.subHeight
        }

        let rectBound = CGRect(x: Double(x-r),
                               y: Double(y-r),
                               width: Double(2.0*r),
                               height: Double(2.0*r))
        context.setFillColor(fillColor.cgColor)
        context.addEllipse(in: rectBound)
        context.drawPath(using: .fill)
    }

    public func drawSolidTriangle(point1: Point,
                                  point2: Point,
                                  point3: Point,
                                  fillColor: Color,
                                  isOriginShifted: Bool) {
        var x1 = point1.x + xOffset
        var x2 = point2.x + xOffset
        var x3 = point3.x + xOffset
        var y1 = point1.y + yOffset
        var y2 = point2.y + yOffset
        var y3 = point3.y + yOffset
        if (isOriginShifted) {
            x1 = x1 + 0.1*plotDimensions.subWidth
            x2 = x2 + 0.1*plotDimensions.subWidth
            x3 = x3 + 0.1*plotDimensions.subWidth
            y1 = y1 + 0.1*plotDimensions.subHeight
            y2 = y2 + 0.1*plotDimensions.subHeight
            y3 = y3 + 0.1*plotDimensions.subHeight
        }
        let trianglePath = CGMutablePath()
        trianglePath.move(to: CGPoint(x: Double(x1), y: Double(y1)))
        trianglePath.addLine(to: CGPoint(x: Double(x2), y: Double(y2)))
        trianglePath.addLine(to: CGPoint(x: Double(x3), y: Double(y3)))
        trianglePath.closeSubpath()
        context.setFillColor(fillColor.cgColor)
        context.addPath(trianglePath)
        context.fillPath()
    }

    public func drawSolidPolygon(points: [Point],
                                 fillColor: Color,
                                 isOriginShifted: Bool) {
        let polygonPath = CGMutablePath()
        if (isOriginShifted) {
            polygonPath.move(to: CGPoint(x: Double(points[0].x + 0.1*plotDimensions.subWidth + xOffset), y: Double(points[0].y + 0.1*plotDimensions.subHeight + yOffset)))
        }
        else {
            polygonPath.move(to: CGPoint(x: Double(points[0].x + xOffset), y: Double(points[0].y + yOffset)))
        }
        for index in 1..<points.count {
            if (isOriginShifted) {
                polygonPath.addLine(to: CGPoint(x: Double(points[index].x + 0.1*plotDimensions.subWidth + xOffset), y: Double(points[index].y + 0.1*plotDimensions.subHeight + yOffset)))
            }
            else {
                polygonPath.addLine(to: CGPoint(x: Double(points[index].x + xOffset), y: Double(points[index].y + yOffset)))
            }
        }
        polygonPath.closeSubpath()
        context.setFillColor(fillColor.cgColor)
        context.addPath(polygonPath)
        context.fillPath()
    }

    public func drawLine(startPoint p1: Point,
                         endPoint p2: Point,
                         strokeWidth thickness: Float,
                         strokeColor: Color = Color.black,
                         isDashed: Bool,
                         isOriginShifted: Bool) {
        let line = CGMutablePath()
        if (isOriginShifted) {
            line.move(to: CGPoint(x: Double(p1.x + 0.1*plotDimensions.subWidth + xOffset),
                                  y: Double(p1.y + 0.1*plotDimensions.subHeight + yOffset)))
            line.addLine(to: CGPoint(x: Double(p2.x + 0.1*plotDimensions.subWidth + xOffset),
                                     y: Double(p2.y + 0.1*plotDimensions.subHeight + yOffset)))
        }
        else {
            line.move(to: CGPoint(x: Double(p1.x + xOffset), y: Double(p1.y + yOffset)))
            line.addLine(to: CGPoint(x: Double(p2.x + xOffset), y: Double(p2.y + yOffset)))
        }
        context.setStrokeColor(strokeColor.cgColor)
        context.setLineWidth(CGFloat(thickness))
        context.addPath(line)
        if(isDashed) {
            let dashes: [ CGFloat ] = [ CGFloat(thickness + 1), CGFloat(thickness + 1) ]
            context.setLineDash(phase: 1, lengths: dashes)
        }
        context.strokePath()
        context.setLineDash(phase: 1, lengths: [])
    }

    public func drawPlotLines(points p: [Point],
                              strokeWidth thickness: Float,
                              strokeColor: Color,
                              isDashed: Bool) {
        for i in 0..<p.count-1 {
            drawLine(startPoint: p[i],
                     endPoint: p[i+1],
                     strokeWidth: thickness,
                     strokeColor: strokeColor,
                     isDashed: isDashed,
                     isOriginShifted: true)
        }
    }

    public func drawText(text s: String,
                         location p: Point,
                         textSize size: Float,
                         strokeWidth thickness: Float,
                         angle: Float,
                         isOriginShifted: Bool){
        var x1 = p.x + xOffset
        var y1 = p.y + yOffset
        if (isOriginShifted) {
            x1 = x1 + 0.1*plotDimensions.subWidth
            y1 = y1 + 0.1*plotDimensions.subHeight
        }
        #if canImport(AppKit)
        let font = NSFont.systemFont(ofSize: CGFloat(size))
        let attr = [NSAttributedString.Key.font:font,NSAttributedString.Key.foregroundColor:NSColor.black] as CFDictionary
        let cfstring:CFString = s as NSString
        let text = CFAttributedStringCreate(nil, cfstring, attr)
        let line = CTLineCreateWithAttributedString(text!)
        context.setLineWidth(1)
        context.setTextDrawingMode(.fill)
        context.textPosition = CGPoint(x: Double(x1), y: Double(y1))
        CTLineDraw(line, context)
        #elseif canImport(UIKit)
        let font = UIFont.systemFont(ofSize: CGFloat(size))
        let attr = [NSAttributedString.Key.font:font,NSAttributedString.Key.foregroundColor:UIColor.black] as CFDictionary
        let cfstring:CFString = s as NSString
        let text = CFAttributedStringCreate(nil, cfstring, attr)
        let line = CTLineCreateWithAttributedString(text!)
        context.setLineWidth(1)
        context.setTextDrawingMode(.fill)
        context.textPosition = CGPoint(x: Double(x1), y: Double(y1))
        CTLineDraw(line, context)
        #endif
    }

    public func getTextWidth(text: String,
                             textSize s: Float) -> Float {
        var attributes: [NSAttributedString.Key: Any] = [:]
        #if canImport(AppKit)
        let font = NSFont.systemFont(ofSize: CGFloat(s))
        context.setFont(CTFontCopyGraphicsFont(font, nil))
        attributes = [.font: font]
        #elseif canImport(UIKit)
        let font = UIFont.systemFont(ofSize: CGFloat(s))
        context.setFont(CTFontCopyGraphicsFont(font, nil))
        attributes = [.font: font]
        #endif
        let string = NSAttributedString(string: "\(text)", attributes: attributes)
        let size = string.size()
        return Float(size.width)
    }

    public func drawOutput(fileName name: String) {
        if !name.isEmpty {
            let fileName = name + ".png"
            let destinationURL = URL(fileURLWithPath: fileName)
            #if canImport(AppKit)
            let image = NSImage(cgImage: context.makeImage()!, size: NSZeroSize)
            image.writePng(to: destinationURL)
            #elseif canImport(UIKit)
            let image: UIImage = UIImage.init(cgImage: context.makeImage()!)
            image.writePng(to: destinationURL)
            #endif
        }
    }
}

// - Helpers

extension CGPoint {
    init(_ swiftplotPoint: SwiftPlot.Point) {
        self.init(x: CGFloat(swiftplotPoint.x), y: CGFloat(swiftplotPoint.y))
    }
}

extension CGSize {
    init(_ swiftplotSize: SwiftPlot.Size) {
        self.init(width: CGFloat(swiftplotSize.width), height: CGFloat(swiftplotSize.height))
    }
}

extension CGRect {
    init(_ swiftplotRect: SwiftPlot.Rect) {
        self.init(origin: CGPoint(swiftplotRect.origin), size: CGSize(swiftplotRect.size))
    }
}

#if canImport(AppKit)
extension NSImage {
    var pngData: Data? {
        guard let tiffRepresentation = tiffRepresentation, let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else { return nil }
        return bitmapImage.representation(using: .png, properties: [:])
    }
    func writePng(to url: URL, options: Data.WritingOptions = .atomic) -> Bool {
        guard let data = pngData else { return false } // TODO: throw an error.
        do {
            try data.write(to: url, options: options)
            return true
        } catch {
            print(error)
            return false
        }
    }
}
#elseif canImport(UIKit)
extension UIImage {
    func writePng(to url: URL, options: Data.WritingOptions = .atomic) -> Bool {
        guard let data = pngData() else { return false } // TODO: throw an error.
        do {
            try data.write(to: url, options: options)
            return true
        } catch {
            print(error)
            return false
        }
    }
}
#endif

#endif // canImport(CoreGraphics)
