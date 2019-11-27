import SwiftPlot
import AGGRenderer
import SVGRenderer
#if canImport(QuartzRenderer)
import QuartzRenderer
#endif

extension BarchartTests {
  
  func testBarchartStackedVertical() {
    
    let fileName = "_18_bar_chart_vertical_stacked"
    
    let x:[String] = ["2008","2009","2010","2011"]
    let y:[Float] = [320,-100,420,500]
    let y1:[Float] = [100,100,220,245]
    
    let agg_renderer = AGGRenderer()
    let svg_renderer = SVGRenderer()
    #if canImport(QuartzRenderer)
    let quartz_renderer = QuartzRenderer()
    #endif
    
    let barGraph = BarGraph<String,Float>(enableGrid: true)
    barGraph.addSeries(x, y, label: "Plot 1", color: .orange)
    barGraph.addStackSeries(y1, label: "Plot 2", color: .blue)
    barGraph.plotTitle = PlotTitle("BAR CHART")
    barGraph.plotLabel = PlotLabel(xLabel: "X-AXIS", yLabel: "Y-AXIS")
    
    barGraph.drawGraphAndOutput(fileName: self.aggOutputDirectory+fileName,
                                renderer: agg_renderer)
    barGraph.drawGraphAndOutput(fileName: self.svgOutputDirectory+fileName,
                                renderer: svg_renderer)
    #if canImport(QuartzRenderer)
    barGraph.drawGraphAndOutput(fileName: self.coreGraphicsOutputDirectory+fileName,
                                renderer: quartz_renderer)
    #endif
  }
}
