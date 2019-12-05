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
 
    let scatterPlot = ScatterPlot<Float,Float>(enableGrid: true)
    scatterPlot.addSeries(scatterplot_x, scatterplot_y, label: "Plot 1", startColor: .gold, endColor: .blue, scatterPattern: .circle)
    scatterPlot.addSeries(scatterplot_x, scatterplot_y1, label: "Plot 2", color: .green, scatterPattern: .star)
    scatterPlot.plotTitle = PlotTitle("SCATTER PLOT")
    scatterPlot.plotLabel = PlotLabel(xLabel: "X-AXIS", yLabel: "Y-AXIS")
    
    let imageSize = Size(width: 1000, height: 1000)
    let svg_renderer = SVGRenderer()
    try scatterPlot.drawGraphAndOutput(size: imageSize,
                                       fileName: svgOutputDirectory+fileName,
                                       renderer: svg_renderer)
    verifyImage(name: fileName, renderer: .svg)
    #if canImport(AGGRenderer)
    let agg_renderer = AGGRenderer()
    try scatterPlot.drawGraphAndOutput(size: imageSize,
                                       fileName: aggOutputDirectory+fileName,
                                       renderer: agg_renderer)
    verifyImage(name: fileName, renderer: .agg)
    #endif
    #if canImport(QuartzRenderer)
    let quartz_renderer = QuartzRenderer()
    try scatterPlot.drawGraphAndOutput(size: imageSize,
                                       fileName: coreGraphicsOutputDirectory+fileName,
                                       renderer: quartz_renderer)
    verifyImage(name: fileName, renderer: .coreGraphics)
    #endif
  }
}
