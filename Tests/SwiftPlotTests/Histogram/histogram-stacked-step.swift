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
  
  func testHistogramStackedStep() throws {
    
    let fileName = "_24_histogram_stacked_step"
    
    let histogram = Histogram<Float>(isNormalized: false, enableGrid: true)
    histogram.addSeries(data: histogram_stacked_step_values, bins: 50, label: "Plot 1", color: .blue, histogramType: .step)
    histogram.addStackSeries(data: histogram_stacked_step_values_2, label: "Plot 2", color: .orange)
    histogram.plotTitle = PlotTitle("HISTOGRAM STACKED STEP")
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

  func testHistogramStackedStepLineJoins() throws {
    let fileName = "_27_histogram_stacked_step_line_joins"
    
    let histogram = Histogram<Float>(isNormalized: false, enableGrid: true)
    histogram.addSeries(data: [0, 13, 17, 17, 21, 25, 30, 34, 34, 38, 42, 45], bins: 49, label: "Plot 1", color: .blue, histogramType: .step)
    histogram.addStackSeries(data: [0, 6, 9, 10, 16, 18, 20, 22, 24, 24, 26, 26, 30, 33, 34, 35, 37, 38, 39, 41, 41, 42, 42, 43, 43, 45], label: "Plot 2", color: .orange)
    histogram.plotTitle = PlotTitle("HISTOGRAM STACKED STEP LINE JOINS")
    histogram.plotLabel = PlotLabel(xLabel: "X", yLabel: "Frequency")
    
    
    let svg_renderer = SVGRenderer()
    try histogram.drawGraphAndOutput(fileName: svgOutputDirectory+fileName,
                                     renderer: svg_renderer)
    #if canImport(AGGRenderer)
    let agg_renderer = AGGRenderer()
    try histogram.drawGraphAndOutput(fileName: aggOutputDirectory+fileName,
                                     renderer: agg_renderer)
    #endif
    #if canImport(QuartzRenderer)
    let quartz_renderer = QuartzRenderer()
    try histogram.drawGraphAndOutput(fileName: coreGraphicsOutputDirectory+fileName,
                                     renderer: quartz_renderer)
    #endif
  }

  func testHistogramMultiStackedStep() throws {
    let fileName = "_26_histogram_multi_stacked_step"
    
    let x: StrideTo<Float> = stride(from: 0, to: 2 * .pi, by: (2 * .pi)/100)
    let data1: [Float] = x.flatMap { [Float](repeating: $0, count: Int((sin($0) + 1)*10)) }
    let data2: [Float] = x.flatMap { [Float](repeating: $0, count: Int((cos($0) + 1)*10)) }
    let data3: [Float] = x.flatMap { [Float](repeating: $0, count: Int((sin($0 + .pi) + 1)*10)) }
    let data4: [Float] = x.flatMap { [Float](repeating: $0, count: Int((cos($0 + .pi) + 1)*10)) }
    
    let histogram = Histogram<Float>(isNormalized: false, enableGrid: true)
    histogram.addSeries(data: data1, bins: 40, label: "Plot 1", color: .blue, histogramType: .step)
    histogram.addStackSeries(data: data2, label: "Plot 2", color: .orange)
    histogram.addStackSeries(data: data3, label: "Plot 3", color: .purple)
    histogram.addStackSeries(data: data4, label: "Plot 3", color: .darkRed)
    
    histogram.plotTitle = PlotTitle("HISTOGRAM MULTI STACKED STEP")
    histogram.plotLabel = PlotLabel(xLabel: "X", yLabel: "Frequency")
    
    
    let svg_renderer = SVGRenderer()
    try histogram.drawGraphAndOutput(fileName: svgOutputDirectory+fileName,
                                     renderer: svg_renderer)
    #if canImport(AGGRenderer)
    let agg_renderer = AGGRenderer()
    try histogram.drawGraphAndOutput(fileName: aggOutputDirectory+fileName,
                                     renderer: agg_renderer)
    #endif
    #if canImport(QuartzRenderer)
    let quartz_renderer = QuartzRenderer()
    try histogram.drawGraphAndOutput(fileName: coreGraphicsOutputDirectory+fileName,
                                     renderer: quartz_renderer)
    #endif
  }
}
