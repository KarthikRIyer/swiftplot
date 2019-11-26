import SwiftPlot
import AGGRenderer
import SVGRenderer
#if canImport(QuartzRenderer)
import QuartzRenderer
#endif

extension ScatterPlotTests {
  
  func testScatterPlot() {

    let fileName = "_20_scatter_plot"
    
    let agg_renderer = AGGRenderer()
    let svg_renderer = SVGRenderer()
    #if canImport(QuartzRenderer)
    let quartz_renderer = QuartzRenderer()
    #endif
    
    let scatterPlot = ScatterPlot<Float,Float>(width: 1000, height: 1000, enableGrid: true)
    scatterPlot.addSeries(scatterplot_x, scatterplot_y, label: "Plot 1", startColor: .gold, endColor: .blue, scatterPattern: .circle)
    scatterPlot.addSeries(scatterplot_x, scatterplot_y1, label: "Plot 2", color: .green, scatterPattern: .star)
    scatterPlot.plotTitle = PlotTitle("SCATTER PLOT")
    scatterPlot.plotLabel = PlotLabel(xLabel: "X-AXIS", yLabel: "Y-AXIS")
    
    scatterPlot.drawGraphAndOutput(fileName: self.aggOutputDirectory+fileName,
                                   renderer: agg_renderer)
    scatterPlot.drawGraphAndOutput(fileName: self.svgOutputDirectory+fileName,
                                   renderer: svg_renderer)
    #if canImport(QuartzRenderer)
    scatterPlot.drawGraphAndOutput(fileName: self.coreGraphicsOutputDirectory+fileName,
                                   renderer: quartz_renderer)
    #endif
  }
}
