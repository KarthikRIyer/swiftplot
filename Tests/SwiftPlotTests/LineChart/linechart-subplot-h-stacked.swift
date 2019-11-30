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
  
  func testLineChartSubplotHorizontallyStacked() throws {
    
    let fileName = "_03_sub_plot_horizontally_stacked_line_chart"
    
    let x:[Float] = [10,100,263,489]
    let y:[Float] = [10,120,500,800]
    
    var plots = [Plot]()
    
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
    
    plots.append(lineGraph1)
    plots.append(lineGraph2)
    
    let subPlot = SubPlot(numberOfPlots: 2, stackPattern: .horizontallyStacked)
    let svg_renderer = SVGRenderer()
    try subPlot.draw(plots: plots,
                     renderer: svg_renderer,
                     fileName: self.svgOutputDirectory+fileName)
    #if canImport(AGGRenderer)
    let agg_renderer = AGGRenderer()
    try subPlot.draw(plots: plots,
                     renderer: agg_renderer,
                     fileName: self.aggOutputDirectory+fileName)
    #endif
    #if canImport(QuartzRenderer)
    let quartz_renderer = QuartzRenderer()
    try subPlot.draw(plots: plots,
                     renderer: quartz_renderer,
                     fileName: self.coreGraphicsOutputDirectory+fileName)
    #endif
  }
}
