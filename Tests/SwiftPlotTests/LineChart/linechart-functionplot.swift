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
  
  func testLineChartFunctionPlot() {
    
    func function(_ x: Float)->Float {
      return 1.0/x
    }
    
    let fileName = "_06_function_plot_line_chart"
    
    let lineGraph = LineGraph<Float,Float>(enablePrimaryAxisGrid: true)
    lineGraph.addFunction(function,
                          minX: -5.0,
                          maxX: 5.0,
                          numberOfSamples: 400,
                          label: "Function",
                          color: .orange)
    lineGraph.plotTitle = PlotTitle("FUNCTION")
    lineGraph.plotLabel = PlotLabel(xLabel: "X-AXIS", yLabel: "Y-AXIS")
    
    let svg_renderer = SVGRenderer()
    lineGraph.drawGraphAndOutput(fileName: self.svgOutputDirectory+fileName,
                                 renderer: svg_renderer)
    #if canImport(AGGRenderer)
    let agg_renderer = AGGRenderer()
    lineGraph.drawGraphAndOutput(fileName: self.aggOutputDirectory+fileName,
                                 renderer: agg_renderer)
    #endif
    #if canImport(QuartzRenderer)
    let quartz_renderer = QuartzRenderer()
    lineGraph.drawGraphAndOutput(fileName: self.coreGraphicsOutputDirectory+fileName,
                                 renderer: quartz_renderer)
    #endif
  }
}
