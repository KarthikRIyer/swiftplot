import SwiftPlot
import AGGRenderer
import SVGRenderer
#if canImport(QuartzRenderer)
import QuartzRenderer
#endif

extension BarchartTests {
  
  func testBarchartHatchedBackslash() {
    
    let fileName = "_11_bar_chart_backward_slash_hatched"
    
    let x:[String] = ["2008","2009","2010","2011"]
    let y:[Float] = [320,-100,420,500]
    
    let agg_renderer = AGGRenderer()
    let svg_renderer = SVGRenderer()
    #if canImport(QuartzRenderer)
    let quartz_renderer = QuartzRenderer()
    #endif
    
    let barGraph = BarGraph<String,Float>(enableGrid: true)
    barGraph.addSeries(x, y, label: "Plot 1", color: .orange, hatchPattern: .backwardSlash)
    barGraph.plotTitle = PlotTitle("HATCHED BAR CHART")
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
