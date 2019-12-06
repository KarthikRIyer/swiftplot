#if canImport(AGGRenderer)
import XCTest
import SwiftPlot
import AGGRenderer

extension AGGRendererTests {
  
  /// Tests that base64 encoding is accurate by drawing a known graph directly in to
  /// a PNG buffer (no files), then verifying the base64-encoded data matches that from
  /// the reference file.
  func testBase64Encoding() throws {
    
    let x:[String] = ["2008","2009","2010","2011"]
    let y:[Float] = [320,-100,420,500]
    let barGraph = BarGraph<String,Float>(enableGrid: true)
    barGraph.addSeries(x, y, label: "Plot 1", color: .orange, hatchPattern: .cross)
    barGraph.plotTitle = PlotTitle("HATCHED BAR CHART")
    barGraph.plotLabel = PlotLabel(xLabel: "X-AXIS", yLabel: "Y-AXIS")
    
    let renderer = AGGRenderer()
    barGraph.drawGraph(renderer: renderer)
    let outputBase64 = renderer.base64Png()
    XCTAssertEqual(outputBase64.count, 46668)
    
    // First, sanity check: ensure *we* can decode the string.
    guard let _ = Data(base64Encoded: outputBase64, options: .ignoreUnknownCharacters) else {
      XCTFail("Failed to decode base64-encoded PNG")
      return
    }
    // Check the contents match a base64-encoded version of the
    // reference image.
    let fileName = "_15_bar_chart_cross_hatched"
    let referenceFile = referenceDirectory(for: .agg)
      .appendingPathComponent(fileName)
      .appendingPathExtension(KnownRenderer.agg.fileExtension)
    let referenceBase64 = try Data(contentsOf: referenceFile)
      .base64EncodedString()
    
    XCTAssertEqual(outputBase64, referenceBase64)
  }
}

#endif // canImport(AGGRenderer)
