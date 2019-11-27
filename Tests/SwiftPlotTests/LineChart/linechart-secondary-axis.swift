import SwiftPlot
import AGGRenderer
import SVGRenderer
#if canImport(QuartzRenderer)
import QuartzRenderer
#endif

extension LineChartTests {
  
  func testLineChartSecondaryAxis() {
    
    let fileName = "_07_secondary_axis_line_chart"
    
    let x:[Float] = [10,100,263,489]
    let y:[Float] = [10,120,500,800]
    let x1:[Float] = [100,200,361,672]
    let y1:[Float] = [150,250,628,800]
    
    let agg_renderer = AGGRenderer()
    let svg_renderer = SVGRenderer()
    #if canImport(QuartzRenderer)
    let quartz_renderer = QuartzRenderer()
    #endif
    
    let lineGraph = LineGraph<Float,Float>()
    lineGraph.addSeries(x1,y1,label: "Plot 1",color: .lightBlue,axisType: .primaryAxis)
    lineGraph.addSeries(x, y, label: "Plot 2", color: .orange, axisType: .secondaryAxis)
    lineGraph.plotTitle = PlotTitle("SECONDARY AXIS")
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
