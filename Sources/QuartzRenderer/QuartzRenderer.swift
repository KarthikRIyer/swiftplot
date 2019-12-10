import Foundation
import SwiftPlot

#if canImport(CoreGraphics)
import CoreGraphics

#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

@available(tvOS 13.0, watchOS 6.0, *)
public class QuartzRenderer: Renderer {
    static let colorSpace = CGColorSpaceCreateDeviceRGB()
    static let bitmapInfo = CGImageAlphaInfo.premultipliedFirst.rawValue
    
    var context: CGContext
    /// Whether or not this context was given to us. If `true`, we should never re-make `context`
    let isExternalContext: Bool
    var fontPath = ""
    public var offset: Point = .zero
    
    public var fontSmoothing: Bool = false {
        didSet { context.setShouldSmoothFonts(fontSmoothing) }
    }
    
    public var imageSize: Size {
        didSet {
            guard !isExternalContext else { return }
            context = CGContext(data: nil,
                                width: Int(imageSize.width),
                                height: Int(imageSize.height),
                                bitsPerComponent: 8,
                                bytesPerRow: 0,
                                space: Self.colorSpace,
                                bitmapInfo: Self.bitmapInfo)!
            context.setAllowsFontSmoothing(true)
            context.setShouldSmoothFonts(fontSmoothing)
            let rect = CGRect(x: 0,
                              y: 0,
                              width: Int(imageSize.width),
                              height: Int(imageSize.height))
            context.setFillColor(Color.white.cgColor)
            context.fill(rect)
          self.context.setShouldSmoothFonts(false)
//          context.setShouldAntialias(false)
        }
    }

    /// Creates a renderer with the given width and height.
    public convenience init(width w: Float = 1000, height h: Float = 660, fontPath: String = "") {
        self.init(size: Size(width: w, height: h), fontPath: fontPath)
    }
    
    /// Creates a renderer with the given size.
    public init(size: Size, fontPath: String = "") {
        self.imageSize = size
        self.context = CGContext(data: nil,
                                 width: Int(size.width),
                                 height: Int(size.height),
                                 bitsPerComponent: 8,
                                 bytesPerRow: 0,
                                 space: Self.colorSpace,
                                 bitmapInfo: Self.bitmapInfo)!
        self.context.setAllowsFontSmoothing(true)
        self.context.setShouldSmoothFonts(fontSmoothing)
        self.isExternalContext = false
      self.context.setShouldSmoothFonts(false)
//      context.setShouldAntialias(false)
    }
    
    /// Creates a renderer with the given external context and dimensions..
    public init(externalContext: CGContext, dimensions: Size) {
        self.imageSize = dimensions
        self.context = externalContext
        self.isExternalContext = true
    }

    public func drawRect(_ rect: Rect,
                         strokeWidth thickness: Float,
                         strokeColor: Color = Color.black) {
        var rect = rect.normalized
        rect.origin.x += xOffset
        rect.origin.y += yOffset
        context.setStrokeColor(strokeColor.cgColor)
        context.setLineWidth(CGFloat(thickness))
        context.stroke(CGRect(rect))
    }

    public func drawSolidRect(_ rect: Rect,
                              fillColor: Color = Color.white,
                              hatchPattern: BarGraphSeriesOptions.Hatching) {
        var rect = rect.normalized
        rect.origin.y += yOffset
        rect.origin.x += xOffset
        context.setFillColor(fillColor.cgColor)
        context.fill(CGRect(rect))
        drawHatchingRect(rect, hatchPattern: hatchPattern)
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
                                        borderColor: Color = Color.black) {
        var rect = rect.normalized
        rect.origin.x += xOffset
        rect.origin.y += yOffset
        context.setFillColor(fillColor.cgColor)
        context.fill(CGRect(rect))
        context.setStrokeColor(borderColor.cgColor)
        context.setLineWidth(CGFloat(thickness))
        context.stroke(CGRect(rect))
    }

    public func drawSolidCircle(center c: Point,
                                radius r: Float,
                                fillColor: Color) {
        let x = c.x + xOffset;
        let y = c.y + yOffset;
        let rectBound = CGRect(x: Double(x-r),
                               y: Double(y-r),
                               width: Double(2.0*r),
                               height: Double(2.0*r))
        context.setFillColor(fillColor.cgColor)
        context.addEllipse(in: rectBound)
        context.drawPath(using: .fill)
    }
    
    public func drawSolidEllipse(center c: Point,
                                 radiusX rx: Float,
                                 radiusY ry: Float,
                                 fillColor: Color) {
        let ellipse = CGMutablePath()
        ellipse.addEllipse(in: CGRect(x: CGFloat(c.x-rx), y: CGFloat(c.y-ry), width: CGFloat(rx*2), height: CGFloat(ry*2)),
                           transform: CGAffineTransform(translationX: CGFloat(xOffset), y: CGFloat(yOffset)))
        context.setFillColor(fillColor.cgColor)
        context.addPath(ellipse)
        context.fillPath()
    }

    public func drawSolidTriangle(point1: Point,
                                  point2: Point,
                                  point3: Point,
                                  fillColor: Color) {
        let x1 = point1.x + xOffset
        let x2 = point2.x + xOffset
        let x3 = point3.x + xOffset
        let y1 = point1.y + yOffset
        let y2 = point2.y + yOffset
        let y3 = point3.y + yOffset
        let trianglePath = CGMutablePath()
        trianglePath.move(to: CGPoint(x: Double(x1), y: Double(y1)))
        trianglePath.addLine(to: CGPoint(x: Double(x2), y: Double(y2)))
        trianglePath.addLine(to: CGPoint(x: Double(x3), y: Double(y3)))
        trianglePath.closeSubpath()
        context.setFillColor(fillColor.cgColor)
        context.addPath(trianglePath)
        context.fillPath()
    }

    public func drawSolidPolygon(_ polygon: SwiftPlot.Polygon,
                                 fillColor: Color) {
        let polygonPath = CGMutablePath()
        polygonPath.addLines(between: polygon.points.map { CGPoint(x: CGFloat($0.x), y: CGFloat($0.y)) },
                             transform: CGAffineTransform(translationX: CGFloat(xOffset), y: CGFloat(yOffset)))
        polygonPath.closeSubpath()
        context.setFillColor(fillColor.cgColor)
        context.addPath(polygonPath)
        context.fillPath()
    }

    public func drawLine(startPoint p1: Point,
                         endPoint p2: Point,
                         strokeWidth thickness: Float,
                         strokeColor: Color = Color.black,
                         isDashed: Bool) {
        let line = CGMutablePath()
        line.move(to: CGPoint(x: Double(p1.x + xOffset), y: Double(p1.y + yOffset)))
        line.addLine(to: CGPoint(x: Double(p2.x + xOffset), y: Double(p2.y + yOffset)))
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

    public func drawPolyline(_ polyline: Polyline,
                              strokeWidth thickness: Float,
                              strokeColor: Color,
                              isDashed: Bool) {

        let linePath = CGMutablePath()
        linePath.addLines(between: polyline.points.map { CGPoint(x: CGFloat($0.x), y: CGFloat($0.y)) },
                          transform: CGAffineTransform(translationX: CGFloat(xOffset), y: CGFloat(yOffset)))
        context.setStrokeColor(strokeColor.cgColor)
        context.setLineWidth(CGFloat(thickness))
        context.addPath(linePath)
        if(isDashed) {
            let dashes: [ CGFloat ] = [ CGFloat(thickness + 1), CGFloat(thickness + 1) ]
            context.setLineDash(phase: 1, lengths: dashes)
        }
        context.strokePath()
        context.setLineDash(phase: 1, lengths: [])
    }

    public func drawText(text s: String,
                         location p: Point,
                         textSize size: Float,
                         color: Color,
                         strokeWidth thickness: Float,
                         angle: Float){
        let x1 = p.x + xOffset
        let y1 = p.y + yOffset
        #if canImport(AppKit)
        let font = NSFont.systemFont(ofSize: CGFloat(size))
        let attr = [NSAttributedString.Key.font : font,
                    .foregroundColor: NSColor(cgColor: color.cgColor) ?? .black] as CFDictionary
        let cfstring:CFString = s as NSString
        let text = CFAttributedStringCreate(nil, cfstring, attr)
        let line = CTLineCreateWithAttributedString(text!)
        context.setLineWidth(1)
        context.setTextDrawingMode(.fill)
        context.saveGState()
        context.translateBy(x: CGFloat(x1), y: CGFloat(y1))
        context.rotate(by: CGFloat(angle) * .pi / 180)
        context.textPosition = .zero
        CTLineDraw(line, context)
        context.restoreGState()
        #elseif canImport(UIKit)
        let font = UIFont.systemFont(ofSize: CGFloat(size))
        let attr = [NSAttributedString.Key.font:font,
                    .foregroundColor: UIColor(cgColor: color.cgColor)] as CFDictionary
        let cfstring:CFString = s as NSString
        let text = CFAttributedStringCreate(nil, cfstring, attr)
        let line = CTLineCreateWithAttributedString(text!)
        context.setLineWidth(1)
        context.setTextDrawingMode(.fill)
        context.saveGState()
        context.translateBy(x: CGFloat(x1), y: CGFloat(y1))
        context.rotate(by: CGFloat(angle) * .pi / 180)
        context.textPosition = .zero
        CTLineDraw(line, context)
        context.restoreGState()
        #endif
    }

    public func getTextLayoutSize(text: String,
                             textSize s: Float) -> Size {
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
        // FIXME: 'size.height' is always too big and misaligns text.
        return Size(width: Float(size.width), height: s)
    }
    
    enum WritePNGError: Error {
        case imageCouldNotBeRendered
    }

    public func drawOutput(fileName name: String) throws {
        if !name.isEmpty {
            let fileName = name + ".png"
            let destinationURL = URL(fileURLWithPath: fileName)
            #if canImport(AppKit)
            let image = NSImage(cgImage: context.makeImage()!, size: NSZeroSize)
            try image.writePng(to: destinationURL)
            #elseif canImport(UIKit)
            let image: UIImage = UIImage.init(cgImage: context.makeImage()!)
            try image.writePng(to: destinationURL)
            #endif
        }
    }
    
    public func makeCGImage() -> CGImage? {
        context.makeImage()
    }
}

// - Helpers

extension CGPoint {
    public init(_ swiftplotPoint: SwiftPlot.Point) {
        self.init(x: CGFloat(swiftplotPoint.x), y: CGFloat(swiftplotPoint.y))
    }
}

extension SwiftPlot.Point {
    public init(_ cgPoint: CGPoint) {
        self.init(Float(cgPoint.x), Float(cgPoint.y))
    }
}

extension CGSize {
    public init(_ swiftplotSize: SwiftPlot.Size) {
        self.init(width: CGFloat(swiftplotSize.width), height: CGFloat(swiftplotSize.height))
    }
}

extension SwiftPlot.Size {
    public init(_ cgSize: CGSize) {
        self.init(width: Float(cgSize.width), height: Float(cgSize.height))
    }
}

extension CGRect {
    public init(_ swiftplotRect: SwiftPlot.Rect) {
        self.init(origin: CGPoint(swiftplotRect.origin), size: CGSize(swiftplotRect.size))
    }
}

extension SwiftPlot.Rect {
    public init(_ cgRect: CGRect) {
        self.init(origin: Point(cgRect.origin), size: Size(cgRect.size))
    }
}

#if canImport(AppKit)
fileprivate extension NSImage {
    var pngData: Data? {
        guard let tiffRepresentation = tiffRepresentation, let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else { return nil }
        return bitmapImage.representation(using: .png, properties: [:])
    }
    func writePng(to url: URL, options: Data.WritingOptions = .atomic) throws {
        guard let data = pngData else { throw QuartzRenderer.WritePNGError.imageCouldNotBeRendered }
        try data.write(to: url, options: options)
    }
}
#elseif canImport(UIKit)
@available(tvOS 13.0, watchOS 6.0, *)
fileprivate extension UIImage {
    func writePng(to url: URL, options: Data.WritingOptions = .atomic) throws {
        guard let data = pngData() else { throw QuartzRenderer.WritePNGError.imageCouldNotBeRendered }
        try data.write(to: url, options: options)
    }
}
#endif

#endif // canImport(CoreGraphics)
