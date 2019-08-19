import Foundation
import AppKit
import SwiftPlot

public class QuartzRenderer: Renderer {
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGImageAlphaInfo.premultipliedFirst.rawValue
    var context: CGContext
    var fontPath = ""
    var initialized = false

    public var xOffset: Float = 0
    public var yOffset: Float = 0
    public var plotDimensions: PlotDimensions {
        willSet{
            if (initialized) {
                context = CGContext(data: nil,
                                    width: Int(plotDimensions.frameWidth),
                                    height: Int(newValue.frameHeight),
                                    bitsPerComponent: 8,
                                    bytesPerRow: 0,
                                    space: colorSpace,
                                    bitmapInfo: bitmapInfo)!
                let rect = CGRect(x: 0,
                                  y: 0,
                                  width: Int(newValue.frameWidth),
                                  height: Int(newValue.frameHeight))
                context.setFillColor(CGColor(red: 1,
                                             green: 1,
                                             blue: 1,
                                             alpha: 1))
                context.fill(rect)
            }
        }
    }

    public init(width w: Float = 1000, height h: Float = 660, fontPath: String = ""){
        initialized = false
        plotDimensions = PlotDimensions(frameWidth: w, frameHeight: h)
        context = CGContext(data: nil,
                            width: Int(plotDimensions.frameWidth),
                            height: Int(plotDimensions.frameHeight),
                            bitsPerComponent: 8,
                            bytesPerRow: 0,
                            space: colorSpace,
                            bitmapInfo: bitmapInfo)!
        let rect = CGRect(x: 0,
                          y: 0,
                          width: Int(plotDimensions.frameWidth),
                          height: Int(plotDimensions.frameHeight))
        context.setFillColor(CGColor(red: 1,
                                     green: 1,
                                     blue: 1,
                                     alpha: 1))
        context.fill(rect)
        initialized = true
    }

    public func drawRect(topLeftPoint p1: Point,
                         topRightPoint p2: Point,
                         bottomRightPoint p3: Point,
                         bottomLeftPoint p4: Point,
                         strokeWidth thickness: Float,
                         strokeColor: Color = Color.black,
                         isOriginShifted: Bool) {
        let w = abs(p2.x - p1.x)
        let h = abs(p2.y - p3.y)
        var y = min(p1.y,p2.y,p3.y,p4.y) + yOffset
        var x = p1.x + xOffset
        if (isOriginShifted) {
            y = y + (0.1*plotDimensions.subHeight)
            x = x + (0.1*plotDimensions.subWidth)
        }
        let rect = CGRect(x: Double(x),
                          y: Double(y),
                          width: Double(w),
                          height: Double(h))
        context.setStrokeColor(CGColor(red: CGFloat(strokeColor.r),
                                       green: CGFloat(strokeColor.g),
                                       blue: CGFloat(strokeColor.b),
                                       alpha: CGFloat(strokeColor.a)))
        context.setLineWidth(CGFloat(thickness))
        context.stroke(rect)
    }

    public func drawSolidRect(topLeftPoint p1: Point,
                              topRightPoint p2: Point,
                              bottomRightPoint p3: Point,
                              bottomLeftPoint p4: Point,
                              fillColor: Color = Color.white,
                              hatchPattern: BarGraphSeriesOptions.Hatching,
                              isOriginShifted: Bool) {
        if (isOriginShifted) {
            let w = abs(p2.x - p1.x)
            let h = abs(p2.y - p3.y)
            let y = min(p1.y,p2.y,p3.y,p4.y) + (0.1*plotDimensions.subHeight) + yOffset
            let x = min(p1.x, p2.x, p3.x, p4.x) + xOffset + (0.1*plotDimensions.subWidth)
            let rect = CGRect(x: Double(x),
                              y: Double(y),
                              width: Double(w),
                              height: Double(h))
            context.setFillColor(CGColor(red: CGFloat(fillColor.r),
                                         green: CGFloat(fillColor.g),
                                         blue: CGFloat(fillColor.b),
                                         alpha: CGFloat(fillColor.a)))
            context.fill(rect)
            drawHatchingRect(x: x, y: y, width: w, height: h, hatchPattern: hatchPattern)
        }
        else {
            let w: Float = abs(p2.x - p1.x)
            let h: Float = abs(p2.y - p3.y)
            let y = min(p1.y,p2.y,p3.y,p4.y) + yOffset
            let x = p1.x + xOffset
            let rect = CGRect(x: Double(x),
                              y: Double(y),
                              width: Double(w),
                              height: Double(h))
            context.setFillColor(CGColor(red: CGFloat(fillColor.r),
                                         green: CGFloat(fillColor.g),
                                         blue: CGFloat(fillColor.b),
                                         alpha: CGFloat(fillColor.a)))
            context.fill(rect)
            drawHatchingRect(x: x, y: y, width: w, height: h, hatchPattern: hatchPattern)
        }
    }
    
    func drawHatchingRect(x: Float,
                          y: Float,
                          width w: Float,
                          height h: Float,
                          hatchPattern: BarGraphSeriesOptions.Hatching) {
        switch (hatchPattern.rawValue) {
        case 0:
            break
        case 1:
            let drawPattern: CGPatternDrawPatternCallback = { _, context in
                let line = CGMutablePath()
                line.move(to: CGPoint(x: Double(0), y: Double(0)))
                line.addLine(to: CGPoint(x: Double(10), y: Double(10)))
                context.setStrokeColor(NSColor.black.cgColor)
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
            context.fill(CGRect(x: Double(x + xOffset),
                                y: Double(y + yOffset),
                                width: Double(w),
                                height: Double(h)))
        case 2:
            let drawPattern: CGPatternDrawPatternCallback = { _, context in
                let line = CGMutablePath()
                line.move(to: CGPoint(x: Double(10), y: Double(0)))
                line.addLine(to: CGPoint(x: Double(0), y: Double(10)))
                context.setStrokeColor(NSColor.black.cgColor)
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
            context.fill(CGRect(x: Double(x + xOffset),
                                y: Double(y + yOffset),
                                width: Double(w),
                                height: Double(h)))

        case 3:
            let drawPattern: CGPatternDrawPatternCallback = { _, context in
                context.addArc(
                    center: CGPoint(x: 0, y: 0), radius: 4.0,
                    startAngle: 0, endAngle: CGFloat(2.0 * .pi),
                    clockwise: false)
                context.setStrokeColor(NSColor.black.cgColor)
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
            context.fill(CGRect(x: Double(x + xOffset),
                                y: Double(y + yOffset),
                                width: Double(w),
                                height: Double(h)))
        case 4:
            let drawPattern: CGPatternDrawPatternCallback = { _, context in
                context.addArc(
                    center: CGPoint(x: 0, y: 0), radius: 4.0,
                    startAngle: 0, endAngle: CGFloat(2.0 * .pi),
                    clockwise: false)
                context.setFillColor(NSColor.black.cgColor)
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
            context.fill(CGRect(x: Double(x + xOffset),
                                y: Double(y + yOffset),
                                width: Double(w),
                                height: Double(h)))

        case 5:
            let drawPattern: CGPatternDrawPatternCallback = { _, context in
                let line = CGMutablePath()
                line.move(to: CGPoint(x: Double(5), y: Double(0)))
                line.addLine(to: CGPoint(x: Double(5), y: Double(10)))
                context.setStrokeColor(NSColor.black.cgColor)
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
            context.fill(CGRect(x: Double(x + xOffset),
                                y: Double(y + yOffset),
                                width: Double(w),
                                height: Double(h)))
        case 6:
            let drawPattern: CGPatternDrawPatternCallback = { _, context in
                let line = CGMutablePath()
                line.move(to: CGPoint(x: Double(0), y: Double(5)))
                line.addLine(to: CGPoint(x: Double(10), y: Double(5)))
                context.setStrokeColor(NSColor.black.cgColor)
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
            context.fill(CGRect(x: Double(x + xOffset),
                                y: Double(y + yOffset),
                                width: Double(w),
                                height: Double(h)))
        case 7:
            let drawPattern: CGPatternDrawPatternCallback = { _, context in
                let line = CGMutablePath()
                line.move(to: CGPoint(x: Double(0), y: Double(5)))
                line.addLine(to: CGPoint(x: Double(10), y: Double(5)))
                line.move(to: CGPoint(x: Double(5), y: Double(0)))
                line.addLine(to: CGPoint(x: Double(5), y: Double(10)))
                context.setStrokeColor(NSColor.black.cgColor)
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
            context.fill(CGRect(x: Double(x + xOffset),
                                y: Double(y + yOffset),
                                width: Double(w),
                                height: Double(h)))
        case 8:
            let drawPattern: CGPatternDrawPatternCallback = { _, context in
                let line = CGMutablePath()
                line.move(to: CGPoint(x: Double(0), y: Double(0)))
                line.addLine(to: CGPoint(x: Double(10), y: Double(10)))
                line.move(to: CGPoint(x: Double(0), y: Double(10)))
                line.addLine(to: CGPoint(x: Double(10), y: Double(00)))
                context.setStrokeColor(NSColor.black.cgColor)
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
            context.fill(CGRect(x: Double(x + xOffset),
                                y: Double(y + yOffset),
                                width: Double(w),
                                height: Double(h)))
        default:
            break
        }
    }

    public func drawSolidRectWithBorder(topLeftPoint p1: Point,
                                        topRightPoint p2: Point,
                                        bottomRightPoint p3: Point,
                                        bottomLeftPoint p4: Point,
                                        strokeWidth thickness: Float,
                                        fillColor: Color = Color.white,
                                        borderColor: Color = Color.black,
                                        isOriginShifted: Bool) {
        let w: Float = abs(p2.x - p1.x)
        let h: Float = abs(p2.y - p3.y)
        var y = min(p1.y,p2.y,p3.y,p4.y) + yOffset
        var x = p1.x + xOffset
        if (isOriginShifted) {
            y = y + (0.1*plotDimensions.subHeight)
            x = x + (0.1*plotDimensions.subWidth)
        }

        let rect = CGRect(x: Double(x),
                          y: Double(y),
                          width: Double(w),
                          height: Double(h))
        context.setFillColor(CGColor(red: CGFloat(fillColor.r),
                                     green: CGFloat(fillColor.g),
                                     blue: CGFloat(fillColor.b),
                                     alpha: CGFloat(fillColor.a)))
        context.fill(rect)
        context.setStrokeColor(CGColor(red: CGFloat(borderColor.r),
                                       green: CGFloat(borderColor.g),
                                       blue: CGFloat(borderColor.b),
                                       alpha: CGFloat(borderColor.a)))
        context.setLineWidth(CGFloat(thickness))
        context.stroke(rect)
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
        context.setFillColor(CGColor(red: CGFloat(fillColor.r),
                                     green: CGFloat(fillColor.g),
                                     blue: CGFloat(fillColor.b),
                                     alpha: CGFloat(fillColor.a)))
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
        context.setFillColor(CGColor(red: CGFloat(fillColor.r),
                                     green: CGFloat(fillColor.g),
                                     blue: CGFloat(fillColor.b),
                                     alpha: CGFloat(fillColor.a)))
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
        context.setFillColor(CGColor(red: CGFloat(fillColor.r),
                                     green: CGFloat(fillColor.g),
                                     blue: CGFloat(fillColor.b),
                                     alpha: CGFloat(fillColor.a)))
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
        context.setStrokeColor(CGColor(red: CGFloat(strokeColor.r),
                                       green: CGFloat(strokeColor.g),
                                       blue: CGFloat(strokeColor.b),
                                       alpha: CGFloat(strokeColor.a)))
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
        let font = NSFont.systemFont(ofSize: CGFloat(size))
//        let transform = CGAffineTransform(rotationAngle: CGFloat(angle))
//        context.textMatrix = transform
        let attr:CFDictionary = [NSAttributedString.Key.font:font,NSAttributedString.Key.foregroundColor:NSColor.black] as CFDictionary
        let cfstring:CFString = s as NSString
        let text = CFAttributedStringCreate(nil, cfstring, attr)
        let line = CTLineCreateWithAttributedString(text!)
        context.setLineWidth(1)
        context.setTextDrawingMode(.fill)
        context.textPosition = CGPoint(x: Double(x1), y: Double(y1))
        CTLineDraw(line, context)
//        context.textMatrix = CGAffineTransform(rotationAngle: 0)
    }

    public func getTextWidth(text: String,
                             textSize s: Float) -> Float {
        let font = NSFont.systemFont(ofSize: CGFloat(s))
        context.setFont(CTFontCopyGraphicsFont(font, nil))
        let string = NSAttributedString(string: "\(text)", attributes: [NSAttributedString.Key.font: font])
        let size = string.size()
        return Float(size.width)
    }

    public func drawOutput(fileName name: String) {
        if !name.isEmpty {
            let fileName = name + ".png"
            let destinationURL = URL(fileURLWithPath: fileName)
            let image = NSImage(cgImage: context.makeImage()!, size: NSZeroSize)
            if image.pngWrite(to: destinationURL) {
                print("File Saved")
            }
        }
    }
}

extension NSImage {
    var pngData: Data? {
        guard let tiffRepresentation = tiffRepresentation, let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else { return nil }
        return bitmapImage.representation(using: .png, properties: [:])
    }
    func pngWrite(to url: URL, options: Data.WritingOptions = .atomic) -> Bool {
        do {
            try pngData?.write(to: url, options: options)
            return true
        } catch {
            print(error)
            return false
        }
    }
}
