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
  
  func testLineChartFunctionPlot() throws {
    
    func function(_ x: Float)->Float {
      return 1.0/x
    }
    
    let fileName = "_06_function_plot_line_chart"
    
    let lineGraph = LineGraph<Float,Float>(enablePrimaryAxisGrid: true)
    lineGraph.addFunction(function,
                          minX: -5.0,
                          maxX: 5.0,
                          numberOfSamples: 400,
                          clampY: -50...50,
                          label: "Function",
                          color: .orange)
    lineGraph.plotTitle = PlotTitle("FUNCTION")
    lineGraph.plotLabel = PlotLabel(xLabel: "X-AXIS", yLabel: "Y-AXIS")
    
    let svg_renderer = SVGRenderer()
    try lineGraph.drawGraphAndOutput(fileName: svgOutputDirectory+fileName,
                                     renderer: svg_renderer)
    verifyImage(name: fileName, renderer: .svg)
    #if canImport(AGGRenderer)
    let agg_renderer = AGGRenderer()
    try lineGraph.drawGraphAndOutput(fileName: aggOutputDirectory+fileName,
                                     renderer: agg_renderer)
    verifyImage(name: fileName, renderer: .agg)
    #endif
    #if canImport(QuartzRenderer)
    let quartz_renderer = QuartzRenderer()
    try lineGraph.drawGraphAndOutput(fileName: coreGraphicsOutputDirectory+fileName,
                                     renderer: quartz_renderer)
    verifyImage(name: fileName, renderer: .coreGraphics)
    #endif
  }
}
