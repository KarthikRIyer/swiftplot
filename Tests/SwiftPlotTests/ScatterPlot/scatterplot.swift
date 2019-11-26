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
  
  func testScatterPlot() {

    let fileName = "_20_scatter_plot"
 
    let scatterPlot = ScatterPlot<Float,Float>(width: 1000, height: 1000, enableGrid: true)
    scatterPlot.addSeries(scatterplot_x, scatterplot_y, label: "Plot 1", startColor: .gold, endColor: .blue, scatterPattern: .circle)
    scatterPlot.addSeries(scatterplot_x, scatterplot_y1, label: "Plot 2", color: .green, scatterPattern: .star)
    scatterPlot.plotTitle = PlotTitle("SCATTER PLOT")
    scatterPlot.plotLabel = PlotLabel(xLabel: "X-AXIS", yLabel: "Y-AXIS")
    
    let svg_renderer = SVGRenderer()
    scatterPlot.drawGraphAndOutput(fileName: self.svgOutputDirectory+fileName,
                                   renderer: svg_renderer)
    #if canImport(AGGRenderer)
    let agg_renderer = AGGRenderer()
    scatterPlot.drawGraphAndOutput(fileName: self.aggOutputDirectory+fileName,
                                   renderer: agg_renderer)
    #endif
    #if canImport(QuartzRenderer)
    let quartz_renderer = QuartzRenderer()
    scatterPlot.drawGraphAndOutput(fileName: self.coreGraphicsOutputDirectory+fileName,
                                   renderer: quartz_renderer)
    #endif
  }
}
