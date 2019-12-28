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

  func testAnnotationTextBackgroundRect() throws {
    
    let fileName = "_30_text_backround_rect_annotation"

    let x:[Float] = [10,100,263,489]
    let y:[Float] = [10,120,500,800]

    let lineGraph = LineGraph<Float, Float>(enablePrimaryAxisGrid: true)
    lineGraph.addSeries(x, y, label: "Plot 1", color: .lightBlue)
    lineGraph.plotTitle.title = "SINGLE SERIES"
    lineGraph.plotLabel.xLabel = "X-AXIS"
    lineGraph.plotLabel.yLabel = "Y-AXIS"
    lineGraph.plotLineThickness = 3.0

    lineGraph.addAnnotation(annotation: Text(text: "HELLO WORLD",
                                             color: Color(0.0, 0.0, 0.0, 0.5),
                                             size: 50.0,
                                             location: Point(300, 300),
                                             drawBackgroundRect: true,
                                             backgroundRectColor: Color.green))

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
    /*
    #if canImport(QuartzRenderer)
    let quartz_renderer = QuartzRenderer()
    try lineGraph.drawGraphAndOutput(fileName: coreGraphicsOutputDirectory+fileName,
                                     renderer: quartz_renderer)
    verifyImage(name: fileName, renderer: .coreGraphics)
    #endif
    */
  }
}