import SwiftPlot
import AGGRenderer
import SVGRenderer
#if os(iOS) || os(macOS)
import QuartzRenderer
#endif

var filePath = "examples/Reference/"
let fileName = "_24_histogram_stacked_step"

var agg_renderer = AGGRenderer()
var svg_renderer = SVGRenderer()
#if os(iOS) || os(macOS)
var quartz_renderer = QuartzRenderer()
#endif

var histogram = Histogram<Float>(isNormalized: false, enableGrid: true)
histogram.addSeries(data: x, bins: 50, label: "Plot 1", color: .blue, histogramType: .step)
histogram.addStackSeries(data: y, label: "Plot 2", color: .orange)
histogram.plotTitle = PlotTitle("HISTOGRAM STACKED STEP")
histogram.plotLabel = PlotLabel(xLabel: "X", yLabel: "Frequency")

histogram.drawGraphAndOutput(fileName: filePath+"agg/"+fileName,
                             renderer: agg_renderer)
histogram.drawGraphAndOutput(fileName: filePath+"svg/"+fileName,
                             renderer: svg_renderer)
#if os(iOS) || os(macOS)
histogram.drawGraphAndOutput(fileName: filePath+"quartz/"+fileName,
                             renderer: quartz_renderer)
#endif
