import SwiftPlot
import AGGRenderer
import SVGRenderer
#if os(iOS) || os(macOS)
import QuartzRenderer
#endif

var filePath = "examples/Reference/"
let fileName = "_22_histogram_step"

var agg_renderer = AGGRenderer()
var svg_renderer = SVGRenderer()
#if os(iOS) || os(macOS)
var quartz_renderer = QuartzRenderer()
#endif

var histogram = Histogram<Float>(isNormalized: false, enableGrid: true)
histogram.addSeries(data: x,
                    bins: 50,
                    label: "Plot 1",
                    color: .blue,
                    histogramType: .step)
histogram.plotTitle = PlotTitle("HISTOGRAM STEP")
histogram.plotLabel = PlotLabel(xLabel: "X", yLabel: "Frequency")

histogram.drawGraphAndOutput(fileName: filePath+"agg/"+fileName,
                             renderer: agg_renderer)
histogram.drawGraphAndOutput(fileName: filePath+"svg/"+fileName,
                             renderer: svg_renderer)
#if os(iOS) || os(macOS)
histogram.drawGraphAndOutput(fileName: filePath+"quartz/"+fileName,
                             renderer: quartz_renderer)
#endif
