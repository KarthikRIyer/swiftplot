import SwiftPlot
import SVGRenderer
#if canImport(AGGRenderer)
import AGGRenderer
#endif
#if canImport(QuartzRenderer)
import QuartzRenderer
#endif

@available(tvOS 13, watchOS 13, *)
extension BarchartTests {
  
  /// - note: This test is duplicated to also test base64 encoding.
  ///         If the test changes, please update that test, too.
  func testBarchartHatchedCross() throws {
    
    let fileName = "_15_bar_chart_cross_hatched"
    
    let x:[String] = ["2008","2009","2010","2011"]
    let y:[Float] = [320,-100,420,500]
    
    var barGraph = BarGraph<String,Float>(enableGrid: true)
    barGraph.addSeries(x, y, label: "Plot 1", color: .orange, hatchPattern: .cross)
    barGraph.plotTitle = PlotTitle("HATCHED BAR CHART")
    barGraph.plotLabel = PlotLabel(xLabel: "X-AXIS", yLabel: "Y-AXIS")

    try renderAndVerify(barGraph, fileName: fileName)
  }
}
