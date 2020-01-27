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

  func testAnnotationArrowWedge() throws {

    let fileName = "_33_arrow_annotation_wedge"

    var lineGraph = LineGraph<Float, Float>(enablePrimaryAxisGrid: true)
    lineGraph.addFunction(sin, minX: -5.0, maxX: 5.0, label: "sin(x)", color: .lightBlue)
    lineGraph.plotTitle.title = "FUNCTION"
    lineGraph.plotLabel.xLabel = "X-AXIS"
    lineGraph.plotLabel.yLabel = "Y-AXIS"
    lineGraph.plotLineThickness = 3.0

    lineGraph.addAnnotation(annotation: Arrow(start: Point(500.0, 585.0),
                                              end: Point(585.0, 585.0),
                                              strokeWidth: 5,
                                              headStyle: .wedge,
                                              startAnnotation: Text(text: "relative maxima",
                                                                    direction: .west)))

    try renderAndVerify(lineGraph, fileName: fileName)
  }
}
