import SwiftPlot
import AGGRenderer
import SVGRenderer
import Foundation

var filePath = "examples/Reference/"
let fileName = "_22_histogram_stacked"

var agg_renderer = AGGRenderer()
var svg_renderer = SVGRenderer()

var histogram = Histogram<Float>(isNormalized: false)
histogram.addSeries(data: x, bins: 50, label: "Plot 1", color: .blue)
histogram.addStackSeries(data: y, label: "Plot 2", color: .orange)
histogram.plotTitle = PlotTitle("HISTOGRAM STACKED")
histogram.plotLabel = PlotLabel(xLabel: "X", yLabel: "Frequency")

histogram.drawGraphAndOutput(fileName: filePath+"agg/"+fileName, renderer: agg_renderer)
histogram.drawGraphAndOutput(fileName: filePath+"svg/"+fileName, renderer: svg_renderer)
