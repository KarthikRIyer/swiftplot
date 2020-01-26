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

  func testAnnotationArrowDoubleHeaded() throws {

    let fileName = "_34_arrow_annotation_double_headed"

    var lineGraph = LineGraph<Float, Float>(enablePrimaryAxisGrid: true)
    lineGraph.addFunction(sin, minX: -5.0, maxX: 5.0, label: "sin(x)", color: .lightBlue)
    lineGraph.plotTitle.title = "FUNCTION"
    lineGraph.plotLabel.xLabel = "X-AXIS"
    lineGraph.plotLabel.yLabel = "Y-AXIS"
    lineGraph.plotLineThickness = 3.0

    lineGraph.addAnnotation(annotation: Arrow(start: Point(180.0, 585.0),
                                              end: Point(585.0, 585.0),
                                              isDoubleHeaded: true))

    try renderAndVerify(lineGraph, fileName: fileName)
  }
}
