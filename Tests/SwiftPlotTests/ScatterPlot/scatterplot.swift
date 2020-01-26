import SwiftPlot
import SVGRenderer
#if canImport(AGGRenderer)
import AGGRenderer
#endif
#if canImport(QuartzRenderer)
import QuartzRenderer
#endif

@available(tvOS 13, watchOS 13, *)
extension ScatterPlotTests {
  
  func testScatterPlot() throws {

    let fileName = "_20_scatter_plot"
 
    var scatterPlot = ScatterPlot<Float,Float>(enableGrid: true)
    scatterPlot.addSeries(scatterplot_x, scatterplot_y, label: "Plot 1", startColor: .gold, endColor: .blue, scatterPattern: .circle)
    scatterPlot.addSeries(scatterplot_x, scatterplot_y1, label: "Plot 2", color: .green, scatterPattern: .star)
    scatterPlot.plotTitle = PlotTitle("SCATTER PLOT")
    scatterPlot.plotLabel = PlotLabel(xLabel: "X-AXIS", yLabel: "Y-AXIS")
    
    let imageSize = Size(width: 1000, height: 1000)
    try renderAndVerify(scatterPlot, size: imageSize, fileName: fileName)
  }
}
