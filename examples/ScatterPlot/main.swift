import SwiftPlot
import AGGRenderer
import SVGRenderer
#if os(iOS) || os(macOS)
import QuartzRenderer
#endif

var filePath = "examples/Reference/"
let fileName = "_20_scatter_plot"

var agg_renderer = AGGRenderer()
var svg_renderer = SVGRenderer()
#if os(iOS) || os(macOS)
var quartz_renderer = QuartzRenderer()
#endif

var scatterPlot = ScatterPlot<Float,Float>(width: 1000, height: 1000, enableGrid: true)
scatterPlot.addSeries(x, y, label: "Plot 1", startColor: .gold, endColor: .blue, scatterPattern: .circle)
scatterPlot.addSeries(x, y1, label: "Plot 2", color: .green, scatterPattern: .star)
scatterPlot.plotTitle = PlotTitle("SCATTER PLOT")
scatterPlot.plotLabel = PlotLabel(xLabel: "X-AXIS", yLabel: "Y-AXIS")

scatterPlot.drawGraphAndOutput(fileName: filePath+"agg/"+fileName,
                               renderer: agg_renderer)
scatterPlot.drawGraphAndOutput(fileName: filePath+"svg/"+fileName,
                               renderer: svg_renderer)
#if os(iOS) || os(macOS)
scatterPlot.drawGraphAndOutput(fileName: filePath+"quartz/"+fileName,
                               renderer: quartz_renderer)
#endif
