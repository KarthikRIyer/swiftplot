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
  
  func testLineChartSecondaryAxis() throws {
    
    let fileName = "_07_secondary_axis_line_chart"
    
    let x:[Float] = [10,100,263,489]
    let y:[Float] = [10,120,500,800]
    let x1:[Float] = [100,200,361,672]
    let y1:[Float] = [150,250,628,800]
    
    let lineGraph = LineGraph<Float,Float>()
    lineGraph.addSeries(x1,y1,label: "Plot 1",color: .lightBlue,axisType: .primaryAxis)
    lineGraph.addSeries(x, y, label: "Plot 2", color: .orange, axisType: .secondaryAxis)
    lineGraph.plotTitle = PlotTitle("SECONDARY AXIS")
    lineGraph.plotLabel = PlotLabel(xLabel: "X-AXIS", yLabel: "Y-AXIS")
    lineGraph.plotLabel.y2Label = "Y2-AXIS"
    lineGraph.plotLineThickness = 3.0
    
    let svg_renderer = SVGRenderer()
    try lineGraph.drawGraphAndOutput(fileName: self.svgOutputDirectory+fileName,
                                     renderer: svg_renderer)
    #if canImport(AGGRenderer)
    let agg_renderer = AGGRenderer()
    try lineGraph.drawGraphAndOutput(fileName: self.aggOutputDirectory+fileName,
                                     renderer: agg_renderer)
    #endif
    #if canImport(QuartzRenderer)
    let quartz_renderer = QuartzRenderer()
    try lineGraph.drawGraphAndOutput(fileName: self.coreGraphicsOutputDirectory+fileName,
                                     renderer: quartz_renderer)
    #endif
  }
}
