import SwiftPlot
import AGGRenderer
import SVGRenderer
import QuartzRenderer

var filePath = "examples/Reference/"
let fileName = "_20_scatter_plot"

var agg_renderer = AGGRenderer()
var svg_renderer = SVGRenderer()
var quartz_renderer = QuartzRenderer()

var scatterPlot = ScatterPlot<Float,Float>(width: 1000, height: 1000, enableGrid: true)
scatterPlot.addSeries(x, y, label: "Plot 1", startColor: .gold, endColor: .blue, scatterPattern: .circle)
scatterPlot.addSeries(x, y1, label: "Plot 2", color: .green, scatterPattern: .star)
scatterPlot.plotTitle = PlotTitle("SCATTER PLOT")
scatterPlot.plotLabel = PlotLabel(xLabel: "X-AXIS", yLabel: "Y-AXIS")

scatterPlot.drawGraphAndOutput(fileName: filePath+"agg/"+fileName,
                               renderer: agg_renderer)
scatterPlot.drawGraphAndOutput(fileName: filePath+"svg/"+fileName,
                               renderer: svg_renderer)
scatterPlot.drawGraphAndOutput(fileName: filePath+"quartz/"+fileName,
                               renderer: quartz_renderer)
