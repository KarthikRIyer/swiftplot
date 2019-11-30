import SwiftPlot
import SVGRenderer
#if canImport(AGGRenderer)
import AGGRenderer
#endif
#if canImport(QuartzRenderer)
import QuartzRenderer
#endif

@available(tvOS 13, watchOS 13, *)
extension LineChartTests {
  
  func testLineChartSubplotVerticallyStacked() throws {
    
    let fileName = "_04_sub_plot_vertically_stacked_line_chart"
    
    let x:[Float] = [10,100,263,489]
    let y:[Float] = [10,120,500,800]

    let subPlot = SubPlot(stackPattern: .vertical)
    
    let lineGraph1 = LineGraph<Float,Float>(enablePrimaryAxisGrid: true)
    lineGraph1.addSeries(x, y, label: "Plot 1", color: .lightBlue)
    lineGraph1.plotTitle = PlotTitle("PLOT 1")
    lineGraph1.plotLabel = PlotLabel(xLabel: "X-AXIS", yLabel: "Y-AXIS")
    lineGraph1.plotLineThickness = 3.0
    
    let lineGraph2 = LineGraph<Float,Float>(enablePrimaryAxisGrid: true)
    lineGraph2.addSeries(x, y, label: "Plot 2", color: .orange)
    lineGraph2.plotTitle = PlotTitle("PLOT 2")
    lineGraph2.plotLabel = PlotLabel(xLabel: "X-AXIS", yLabel: "Y-AXIS")
    lineGraph2.plotLineThickness = 3.0
    
    subPlot.plots = [lineGraph1, lineGraph2]

    let svg_renderer = SVGRenderer()
    try subPlot.drawGraphAndOutput(fileName: self.svgOutputDirectory+fileName,
                                   renderer: svg_renderer)
    #if canImport(AGGRenderer)
    let agg_renderer = AGGRenderer()
    try subPlot.drawGraphAndOutput(fileName: self.aggOutputDirectory+fileName,
                                   renderer: agg_renderer)
    #endif
    #if canImport(QuartzRenderer)
    let quartz_renderer = QuartzRenderer()
    try subPlot.drawGraphAndOutput(fileName: self.coreGraphicsOutputDirectory+fileName,
                                   renderer: quartz_renderer)
    #endif
    
  }
}
