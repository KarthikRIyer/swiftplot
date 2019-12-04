#if canImport(AGGRenderer)
import XCTest
import SwiftPlot
import AGGRenderer

extension AGGRendererTests {
    
    func testBase64Encoding() {
        let renderer = AGGRenderer()
        let rect = Rect(origin: zeroPoint, size: Size(width: 200, height: 200))
        
        renderer.imageSize = rect.size
        renderer.drawSolidRect(rect, fillColor: .white, hatchPattern: .none)
        renderer.drawSolidCircle(center: Point(100,100), radius: 75, fillColor: .red)
        
        let png = renderer.base64Png()
        XCTAssertEqual(png.count, 2315)
        
        // Check that we can decode it again.
        guard let data = Data(base64Encoded: png, options: .ignoreUnknownCharacters) else {
            XCTFail("Failed to decode base64-encoded PNG")
            return
        }
        XCTAssertEqual(data.count, 1710)
        // Check expected data.
        // A reference file would be better, but this will have to do for now.
        let pngPrefix = png.prefix(128)
        let pngSuffix = png.suffix(128)
        XCTAssertEqual(
            String(pngPrefix),
            #"iVBORw0KGgoAAAANSUhEUgAAAMgAAADICAMAAACahl6sAAABL1BMVEX/////6+v/"# + "\r\n" +
            #"w8P/m5v/gYH/aWn/UVH/ODj/JCT/HBz/FBT/DAz/AwP//v7/39//pqb/bGz/PT3"#
        )
        XCTAssertEqual(
            String(pngSuffix),
            #"bOhf/ybcSl/8JBL307q16z"# + "\r\n" +
            #"r65fM1xf2bV6P3+K7hZuvI3bu9L9w/VjOPx4/XBfurtteG886F0mk8lkMplMJpPJ"# + "\r\n" +
            #"ZDKZTCaTSUH/ABlnILfhHFVMAAAAAElFTkSuQmCC"#
        )
    }
}

#endif // canImport(AGGRenderer)
