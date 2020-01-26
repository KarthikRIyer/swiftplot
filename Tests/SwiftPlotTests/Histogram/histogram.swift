import SwiftPlot
import SVGRenderer
#if canImport(AGGRenderer)
import AGGRenderer
#endif
#if canImport(QuartzRenderer)
import QuartzRenderer
#endif

@available(tvOS 13, watchOS 13, *)
extension HistogramTests {
  
  func testHistogram() throws {    
    let fileName = "_21_histogram"
    
    var histogram = Histogram<Float>(isNormalized: false, enableGrid: true)
    histogram.addSeries(data: histogram_values, bins: 50, label: "Plot 1", color: .blue)
    histogram.plotTitle = PlotTitle("HISTOGRAM")
    histogram.plotLabel = PlotLabel(xLabel: "X", yLabel: "Frequency")
    
    try renderAndVerify(histogram, fileName: fileName)
  }
}
