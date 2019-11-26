import SwiftPlot
import AGGRenderer
import SVGRenderer
#if canImport(QuartzRenderer)
import QuartzRenderer
#endif

extension LineChartTests {
  
  func testLineChartSingleSeries() {
    
    let fileName = "_01_single_series_line_chart"
    
    let x:[Float] = [10,100,263,489]
    let y:[Float] = [10,120,500,800]
    
    let agg_renderer = AGGRenderer()
    let svg_renderer = SVGRenderer()
    #if canImport(QuartzRenderer)
    let quartz_renderer = QuartzRenderer()
    #endif
    
    let lineGraph = LineGraph<Float,Float>(enablePrimaryAxisGrid: true)
    lineGraph.addSeries(x, y, label: "Plot 1", color: .lightBlue)
    lineGraph.plotTitle = PlotTitle("SINGLE SERIES")
    lineGraph.plotLabel = PlotLabel(xLabel: "X-AXIS", yLabel: "Y-AXIS")
    lineGraph.plotLineThickness = 3.0
    
    lineGraph.drawGraphAndOutput(fileName: self.aggOutputDirectory+fileName,
                                 renderer: agg_renderer)
    lineGraph.drawGraphAndOutput(fileName: self.svgOutputDirectory+fileName,
                                 renderer: svg_renderer)
    #if canImport(QuartzRenderer)
    lineGraph.drawGraphAndOutput(fileName: self.coreGraphicsOutputDirectory+fileName,
                                 renderer: quartz_renderer)
    #endif
  }
}
