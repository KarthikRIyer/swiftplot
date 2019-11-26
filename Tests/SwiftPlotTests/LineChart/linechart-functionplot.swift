import SwiftPlot
import AGGRenderer
import SVGRenderer
#if canImport(QuartzRenderer)
import QuartzRenderer
#endif

extension LineChartTests {
  
  func testLineChartFunctionPlot() {
    
    func function(_ x: Float)->Float {
      return 1.0/x
    }
    
    let fileName = "_06_function_plot_line_chart"
    
    let agg_renderer = AGGRenderer()
    let svg_renderer = SVGRenderer()
    #if canImport(QuartzRenderer)
    let quartz_renderer = QuartzRenderer()
    #endif
    
    let lineGraph = LineGraph<Float,Float>(enablePrimaryAxisGrid: true)
    lineGraph.addFunction(function,
                          minX: -5.0,
                          maxX: 5.0,
                          numberOfSamples: 400,
                          label: "Function",
                          color: .orange)
    lineGraph.plotTitle = PlotTitle("FUNCTION")
    lineGraph.plotLabel = PlotLabel(xLabel: "X-AXIS", yLabel: "Y-AXIS")
    
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
