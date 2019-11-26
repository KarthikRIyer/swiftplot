import SwiftPlot
import AGGRenderer
import SVGRenderer
#if canImport(QuartzRenderer)
import QuartzRenderer
#endif

extension LineChartTests {
  
  func testLineChartSubplotHorizontallyStacked() {
    
    let fileName = "_03_sub_plot_horizontally_stacked_line_chart"
    
    let x:[Float] = [10,100,263,489]
    let y:[Float] = [10,120,500,800]
    
    let agg_renderer = AGGRenderer()
    let svg_renderer = SVGRenderer()
    #if canImport(QuartzRenderer)
    let quartz_renderer = QuartzRenderer()
    #endif
    
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
    subPlot.draw(plots: plots,
                 renderer: svg_renderer,
                 fileName: self.svgOutputDirectory+fileName)
    subPlot.draw(plots: plots,
                 renderer: agg_renderer,
                 fileName: self.aggOutputDirectory+fileName)
    #if canImport(QuartzRenderer)
    subPlot.draw(plots: plots,
                 renderer: quartz_renderer,
                 fileName: self.coreGraphicsOutputDirectory+fileName)
    #endif
  }
}
