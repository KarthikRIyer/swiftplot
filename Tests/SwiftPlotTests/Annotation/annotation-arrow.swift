@testable import SwiftPlot
import Foundation
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

    //TODO: update reference image

    let fileName = "_30_arrow_annotation"

    func function(_ x: Float) -> Float {
      return sin(x)
    }

    let lineGraph = LineGraph<Float, Float>(enablePrimaryAxisGrid: true)
    lineGraph.addFunction(function, minX: -5.0, maxX: 5.0, label: "sin(x)", color: .lightBlue)
    lineGraph.plotTitle.title = "FUNCTION"
    lineGraph.plotLabel.xLabel = "X-AXIS"
    lineGraph.plotLabel.yLabel = "Y-AXIS"
    lineGraph.plotLineThickness = 3.0

    //TODO: have arrow point at local maxima

    lineGraph.addAnnotation(annotation: Arrow(color: Color.black,
                                              start: Point(50.0, 50.0),
                                              end: Point(200.0, 200.0),
                                              strokeWidth: 10,
                                              headLength: 20,
                                              headAngle: 15))

    //TODO: add text with "local maxima"

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
