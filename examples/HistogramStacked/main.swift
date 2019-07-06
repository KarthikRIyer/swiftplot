import SwiftPlot
import AGGRenderer
import SVGRenderer
import Foundation

var filePath = "examples/Reference/"
let fileName = "_22_histogram_stacked"

var x = [Float]()
var y = [Float]()
var mean1: Float = 100
var mean2: Float = 150
var deviation: Float = 15
let numberOfSamples = 10000

for _ in 1...numberOfSamples {
    let x1 = Float.random(in: 0.0...1.0)
    let x2 = Float.random(in: 0.0...1.0)
    let z1 = sqrt(-2 * log(x1))*cos(2*Float.pi*x2)
    x.append(z1*deviation + mean1)
}

for _ in 1...numberOfSamples {
    let x1 = Float.random(in: 0.0...1.0)
    let x2 = Float.random(in: 0.0...1.0)
    let z1 = sqrt(-2 * log(x1))*cos(2*Float.pi*x2)
    y.append(z1*deviation + mean2)
}

var agg_renderer = AGGRenderer()
var svg_renderer = SVGRenderer()

var histogram: Histogram = Histogram(isNormalized: false)
histogram.addSeries(data: x, bins: 50, label: "Plot 1", color: .blue)
histogram.addStackSeries(data: y, label: "Plot 2", color: .orange)
histogram.plotTitle = PlotTitle("HISTOGRAM STACKED")
histogram.plotLabel = PlotLabel(xLabel: "X", yLabel: "Frequency")

histogram.drawGraphAndOutput(fileName: filePath+"agg/"+fileName, renderer: agg_renderer)
histogram.drawGraphAndOutput(fileName: filePath+"svg/"+fileName, renderer: svg_renderer)
