import XCTest
import SwiftPlot
import SVGRenderer
#if canImport(AGGRenderer)
import AGGRenderer
#endif
#if canImport(QuartzRenderer)
import QuartzRenderer
#endif

struct MyStruct {
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
    
    var d = Data(capacity: 10_000)
    for _ in 0..<10_000 { d.append(.random(in: 0..<255)) }
    var hm3 = d.heatmap(width: 100, interpolator: .linear)
    
//    var hm3 = Array("THIS IS SWIFPLOT!!!! Woo let's see what this looks like :)")
//      .heatmap(width: 5, interpolator: .linearByKeyPath(\.asciiValue!))
//    var hm3 = Array(stride(from: Float(0), to: 1, by: 0.001)).heatmap(width: 10, interpolator: .linear)
    hm3.colorMap = .viridis
    
    
    var hm2 = Heatmap<[[Int]]>(interpolator: .linear)//.inverted)
    hm2.values = (0..<10).map { row in
      (0..<10).map { col in 0 }
    }
    hm2.values[8][2] = 1
    hm2.values[8][6] = 1
    hm2.values[6][2] = 1
    hm2.values[6][6] = 1
    hm2.values[5][2...5] = Array(repeating: 1, count: 4)[...]
    hm2.colorMap = .inferno
    
    var sub = SubPlot(layout: .horizontal)
    sub.plots = [hm3]//,  hm2]
    
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
