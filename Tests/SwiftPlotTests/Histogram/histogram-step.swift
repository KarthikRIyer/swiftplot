import SwiftPlot
import AGGRenderer
import SVGRenderer
#if canImport(QuartzRenderer)
import QuartzRenderer
#endif

extension HistogramTests {
  
  func testHistogramStep() {
    
    let fileName = "_22_histogram_step"
    
    let agg_renderer = AGGRenderer()
    let svg_renderer = SVGRenderer()
    #if canImport(QuartzRenderer)
    let quartz_renderer = QuartzRenderer()
    #endif
    
    let histogram = Histogram<Float>(isNormalized: false, enableGrid: true)
    histogram.addSeries(data: histogram_step_values,
                        bins: 50,
                        label: "Plot 1",
                        color: .blue,
                        histogramType: .step)
    histogram.plotTitle = PlotTitle("HISTOGRAM STEP")
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
