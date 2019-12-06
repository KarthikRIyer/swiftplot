import XCTest
import SwiftPlot
import SVGRenderer
#if canImport(AGGRenderer)
import AGGRenderer
#endif
#if canImport(QuartzRenderer)
import QuartzRenderer
#endif

struct MyStruct: Comparable {
  static func < (lhs: MyStruct, rhs: MyStruct) -> Bool {
    lhs.val < rhs.val
  }
  var val: Int
}

@available(tvOS 13.0, watchOS 6.0, *)
final class HeatmapTests: SwiftPlotTestCase {
  
  func testHeatmap() throws {
    let fileName = "_____heatmap"
      
    var hm = Heatmap<[[Int]]>()
    hm.values = [
      (0..<5).map { _ in .random(in: -10...10) },
      (0..<6).map { _ in .random(in: -10...10) },
      (0..<10).map { _ in .random(in: -10...10) },
      (0..<7).map { _ in .random(in: -10...10) },
      (0..<8).map { _ in .random(in: -10...10) },
    ]
    hm.plotTitle.title = "😅"
    
    
    
    var hm2 = Heatmap<[[MyStruct]]>(interpolator: .linearByKeyPath(\.val))
    hm2.values = (0..<5).map { row in
      (0..<5).map { col in
        row == col ? MyStruct(val: row) : MyStruct(val: 0)
      }
    }
    
    var sub = SubPlot(layout: .horizontal)
    sub.plots = [hm]//,  hm2]
    
    let svg_renderer = SVGRenderer()
    try sub.drawGraphAndOutput(fileName: svgOutputDirectory+fileName,
                                     renderer: svg_renderer)
    #if canImport(AGGRenderer)
    let aggRenderer = AGGRenderer()
    try sub.drawGraphAndOutput(fileName: aggOutputDirectory + fileName,
                              renderer: aggRenderer)
    #endif
    #if canImport(QuartzRenderer)
    let quartz_renderer = QuartzRenderer()
    try sub.drawGraphAndOutput(fileName: coreGraphicsOutputDirectory+fileName,
                                     renderer: quartz_renderer)
    verifyImage(name: fileName, renderer: .coreGraphics)
    #endif
  }
}
