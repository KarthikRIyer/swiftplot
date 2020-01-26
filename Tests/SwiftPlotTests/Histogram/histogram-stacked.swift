import Foundation
import SwiftPlot
import SVGRenderer
#if canImport(AGGRenderer)
import AGGRenderer
#endif
#if canImport(QuartzRenderer)
import QuartzRenderer
#endif

@available(tvOS 13, watchOS 13, *)
extension HistogramTests {
  
  func testHistogramStacked() throws {
    let fileName = "_23_histogram_stacked"
    
    var histogram = Histogram<Float>(isNormalized: false, enableGrid: true)
    histogram.addSeries(data: histogram_stacked_values, bins: 50, label: "Plot 1", color: .blue)
    histogram.addStackSeries(data: histogram_stacked_values_2, label: "Plot 2", color: .orange)
    histogram.plotTitle = PlotTitle("HISTOGRAM STACKED")
    histogram.plotLabel = PlotLabel(xLabel: "X", yLabel: "Frequency")
    
    try renderAndVerify(histogram, fileName: fileName)
  }
    
  func testHistogramMultiStackedColorBleed() throws {
      let fileName = "_25_histogram_multi_stacked_color_bleed"
      
      var histogram = Histogram<Float>(isNormalized: false, enableGrid: true)
      histogram.addSeries(data: [5, 6, 7, 8, 9, 10, 15, 18], bins: 21, label: "Plot 1", color: .yellow, histogramType: .bar)
      histogram.addStackSeries(data: [4, 5, 6, 7, 8, 9, 15, 18], label: "Plot 2", color: .orange)
      histogram.addStackSeries(data: [3, 4, 5, 6, 7, 8, 15, 16], label: "Plot 3", color: .green)
      histogram.addStackSeries(data: [2, 3, 4, 5, 6, 7, 14, 15, 16], label: "Plot 4", color: .red)
      histogram.addStackSeries(data: [1, 2, 3, 4, 5, 6, 14, 16, 19], label: "Plot 5", color: .blue)
      histogram.addStackSeries(data: [0, 1, 2, 3, 4, 5, 14, 16, 17, 19], label: "Plot 6", color: .purple)
      
      histogram.plotTitle = PlotTitle("HISTOGRAM MULTI STACKED")
      histogram.plotLabel = PlotLabel(xLabel: "X", yLabel: "Frequency")
      
      
      let svg_renderer = SVGRenderer()
      try histogram.drawGraphAndOutput(fileName: svgOutputDirectory+fileName,
                                       renderer: svg_renderer)
      verifyImage(name: fileName, renderer: .svg)
      #if canImport(AGGRenderer)
      let agg_renderer = AGGRenderer()
      try histogram.drawGraphAndOutput(fileName: aggOutputDirectory+fileName,
                                       renderer: agg_renderer)
      verifyImage(name: fileName, renderer: .agg)
      #endif
      #if canImport(QuartzRenderer)
      let quartz_renderer = QuartzRenderer()
      try histogram.drawGraphAndOutput(fileName: coreGraphicsOutputDirectory+fileName,
                                       renderer: quartz_renderer)
      verifyImage(name: fileName, renderer: .coreGraphics)
      #endif
    }
    
  func testHistogramMultiStacked() throws {
    let fileName = "_26_histogram_multi_stacked"
    
    let x: StrideTo<Float> = stride(from: 0, to: 2 * .pi, by: (2 * .pi)/100)
    let data1: [Float] = x.flatMap { [Float](repeating: $0, count: Int((sin($0) + 1)*10)) }
    let data2: [Float] = x.flatMap { [Float](repeating: $0, count: Int((cos($0) + 1)*10)) }
    let data3: [Float] = x.flatMap { [Float](repeating: $0, count: Int((sin($0 + .pi) + 1)*10)) }
    let data4: [Float] = x.flatMap { [Float](repeating: $0, count: Int((cos($0 + .pi) + 1)*10)) }
    
    var histogram = Histogram<Float>(isNormalized: false, enableGrid: true)
    histogram.addSeries(data: data1, bins: 40, label: "Plot 1", color: .blue, histogramType: .bar)
    histogram.addStackSeries(data: data2, label: "Plot 2", color: .orange)
    histogram.addStackSeries(data: data3, label: "Plot 3", color: .purple)
    histogram.addStackSeries(data: data4, label: "Plot 3", color: .darkRed)
    
    histogram.plotTitle = PlotTitle("HISTOGRAM MULTI STACKED")
    histogram.plotLabel = PlotLabel(xLabel: "X", yLabel: "Frequency")
    
    try renderAndVerify(histogram, fileName: fileName)
  }
}
