@testable import SwiftPlot
import SVGRenderer
#if canImport(AGGRenderer)
import AGGRenderer
#endif
#if canImport(QuartzRenderer)
import QuartzRenderer
#endif

@available(tvOS 13, watchOS 13, *)
extension AnnotationTests {

  func textAnnotationText() throws {
    
    let fileName = "_29_text_annotation"

    let lineGraph = LineGraph<Float, Float>(enablePrimaryAxisGrid: true)
    lineGraph.addAnnotation(annotation: Text(text: "HELLO WORLD",
                                             color: Color(0.0, 0.0, 0.0, 0.5),
                                             size: 12.0,
                                             location: Point(0.95, 0.95)))

    let svg_renderer = SVGRenderer()
    try lineGraph.drawGraphAndOutput(fileName: svgOutputDirectory+fileName,
                                     renderer: svg_renderer)
    verifyImage(name: fileName, renderer: .svg)
    #if canImport(AGGRenderer)
    let agg_renderer = AGGRenderer()
    try lineGraph.drawGraphAndOutput(fileName: aggOutputDirectory+fileName,
                                     renderer: agg_renderer)
    verifyImage(name: fileName, renderer: .agg)
    #endif
    #if canImport(QuartzRenderer)
    let quartz_renderer = QuartzRenderer()
    try lineGraph.drawGraphAndOutput(fileName: coreGraphicsOutputDirectory+fileName,
                                     renderer: quartz_renderer)
    verifyImage(name: fileName, renderer: .coreGraphics)
    #endif
  }
}
