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

  func testAnnotationArrow() throws {
    
    let fileName = "_30_arrow_annotation"

    let x:[Float] = [10,100,263,489]
    let y:[Float] = [10,120,500,800]

    let lineGraph = LineGraph<Float, Float>(enablePrimaryAxisGrid: true)
    lineGraph.addSeries(x, y, label: "Plot 1", color: .lightBlue)
    lineGraph.plotTitle.title = "SINGLE SERIES"
    lineGraph.plotLabel.xLabel = "X-AXIS"
    lineGraph.plotLabel.yLabel = "Y-AXIS"
    lineGraph.plotLineThickness = 3.0

    lineGraph.addAnnotation(annotation: Arrow(color: Color.black,
                                              start: Point(50.0, 50.0),
                                              end: Point(200.0, 200.0),
                                              width: 5,
                                              headLength: 20,
                                              headAngle: 15))

    lineGraph.addAnnotation(annotation: Arrow(color: Color.green,
                                              start: Point(500.0, 500.0),
                                              end: Point(125.0, 50.0),
                                              width: 5,
                                              headLength: 40,
                                              headAngle: 10))

    lineGraph.addAnnotation(annotation: Arrow(color: Color.red,
                                              start: Point(220.0, 250.0),
                                              end: Point(280.0, 200.0),
                                              width: 5,
                                              headLength: 25,
                                              headAngle: 30))

    lineGraph.addAnnotation(annotation: Arrow(color: Color.blue,
                                              start: Point(540.0, 520.0),
                                              end: Point(200.0, 600.0),
                                              width: 5,
                                              headLength: 20,
                                              headAngle: 20))

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
