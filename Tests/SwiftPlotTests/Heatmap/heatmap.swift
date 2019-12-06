import XCTest
import SwiftPlot
import SVGRenderer
#if canImport(AGGRenderer)
import AGGRenderer
#endif
#if canImport(QuartzRenderer)
import QuartzRenderer
#endif

@available(tvOS 13.0, watchOS 6.0, *)
final class HeatmapTests: SwiftPlotTestCase {
  
  func testHeatmap() throws {
    let fileName = "_____heatmap"
      
    var hm = Heatmap<[[Int]]>()
    hm.values = [
      (0..<5).map { _ in .random(in: -10...10) },
      (0..<5).map { _ in .random(in: -10...10) },
      (0..<5).map { _ in .random(in: -10...10) },
      (0..<5).map { _ in .random(in: -10...10) },
      (0..<5).map { _ in .random(in: -10...10) },
    ]
    
    let svg_renderer = SVGRenderer()
    try hm.drawGraphAndOutput(fileName: svgOutputDirectory+fileName,
                                     renderer: svg_renderer)
    #if canImport(AGGRenderer)
    let aggRenderer = AGGRenderer()
    try hm.drawGraphAndOutput(fileName: aggOutputDirectory + fileName,
                              renderer: aggRenderer)
    #endif
    #if canImport(QuartzRenderer)
    let quartz_renderer = QuartzRenderer()
    try hm.drawGraphAndOutput(fileName: coreGraphicsOutputDirectory+fileName,
                                     renderer: quartz_renderer)
    verifyImage(name: fileName, renderer: .coreGraphics)
    #endif
  }
}
