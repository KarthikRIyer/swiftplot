import SwiftPlot
import AGGRenderer
import SVGRenderer

var filePath = "examples/Reference/"
let fileName = "_19_scatter_plot"

var x = [Float]()
var y = [Float]()

var x1 = [Float]()
var y1 = [Float]()

for index in 1...100 {
    x.append(Float(index))
    y.append(Float(index*2) + Float.random(in: -10...10))
}

for index in 1...100 {
    x1.append(Float(index))
    y1.append(Float(index) + Float.random(in: -10...10))
}

var agg_renderer = AGGRenderer()
var svg_renderer = SVGRenderer()

var scatterPlot: ScatterPlot = ScatterPlot(width: 1000, height: 1000)
scatterPlot.addSeries(x, y, label: "Plot 1", startColor: .gold, endColor: .blue, scatterPattern: .circle)
scatterPlot.addSeries(x1, y1, label: "Plot 2", color: .green, scatterPattern: .star)
scatterPlot.plotTitle = PlotTitle("SCATTER PLOT")
scatterPlot.plotLabel = PlotLabel(xLabel: "X-AXIS", yLabel: "Y-AXIS")

scatterPlot.drawGraphAndOutput(fileName: filePath+"agg/"+fileName, renderer: agg_renderer)
scatterPlot.drawGraphAndOutput(fileName: filePath+"svg/"+fileName, renderer: svg_renderer)
