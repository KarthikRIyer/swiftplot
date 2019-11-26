import SwiftPlot
import AGGRenderer
import SVGRenderer
#if canImport(QuartzRenderer)
import QuartzRenderer
#endif

extension HistogramTests {
  
  func testHistogramStackedStep() {
    
    let fileName = "_24_histogram_stacked_step"
    
    let agg_renderer = AGGRenderer()
    let svg_renderer = SVGRenderer()
    #if canImport(QuartzRenderer)
    let quartz_renderer = QuartzRenderer()
    #endif
    
    let histogram = Histogram<Float>(isNormalized: false, enableGrid: true)
    histogram.addSeries(data: histogram_stacked_step_values, bins: 50, label: "Plot 1", color: .blue, histogramType: .step)
    histogram.addStackSeries(data: histogram_stacked_step_values_2, label: "Plot 2", color: .orange)
    histogram.plotTitle = PlotTitle("HISTOGRAM STACKED STEP")
    histogram.plotLabel = PlotLabel(xLabel: "X", yLabel: "Frequency")
    
    histogram.drawGraphAndOutput(fileName: self.aggOutputDirectory+fileName,
                                 renderer: agg_renderer)
    histogram.drawGraphAndOutput(fileName: self.svgOutputDirectory+fileName,
                                 renderer: svg_renderer)
    #if canImport(QuartzRenderer)
    histogram.drawGraphAndOutput(fileName: self.coreGraphicsOutputDirectory+fileName,
                                 renderer: quartz_renderer)
    #endif
  }
}
