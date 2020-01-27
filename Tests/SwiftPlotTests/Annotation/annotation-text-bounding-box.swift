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

  func testAnnotationTextBoundingBox() throws {
    
    let fileName = "_30_text_bounding_box_annotation"

    let x:[Float] = [10,100,263,489]
    let y:[Float] = [10,120,500,800]

    var lineGraph = LineGraph<Float, Float>(enablePrimaryAxisGrid: true)
    lineGraph.addSeries(x, y, label: "Plot 1", color: .lightBlue)
    lineGraph.plotTitle.title = "SINGLE SERIES"
    lineGraph.plotLabel.xLabel = "X-AXIS"
    lineGraph.plotLabel.yLabel = "Y-AXIS"
    lineGraph.plotLineThickness = 3.0

    lineGraph.addAnnotation(annotation: Text(text: "HELLO WORLD",
                                             color: .black,
                                             size: 50.0,
                                             location: Point(300, 300),
                                             boundingBox: Box(color: .pink),
                                             borderWidth: 5.0))

    try renderAndVerify(lineGraph, fileName: fileName)
  }
}
