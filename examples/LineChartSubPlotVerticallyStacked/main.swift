import SwiftPlot
import AGGRenderer
import SVGRenderer

var filePath = "examples/Reference/"
let fileName = "_04_sub_plot_vertically_stacked_line_chart"

let x:[Float] = [0,100,263,489]
let y:[Float] = [0,320,310,170]

var agg_renderer = AGGRenderer()
var svg_renderer = SVGRenderer()

var plots = [Plot]()

var lineGraph1 = LineGraph()
lineGraph1.addSeries(x, y, label: "Plot 1", color: .lightBlue)
lineGraph1.plotTitle = PlotTitle("PLOT 1")
lineGraph1.plotLabel = PlotLabel(xLabel: "X-AXIS", yLabel: "Y-AXIS")

var lineGraph2 = LineGraph()
lineGraph2.addSeries(x, y, label: "Plot 2", color: .orange)
lineGraph2.plotTitle = PlotTitle("PLOT 2")
lineGraph2.plotLabel = PlotLabel(xLabel: "X-AXIS", yLabel: "Y-AXIS")

plots.append(lineGraph1)
plots.append(lineGraph2)

var subPlot = SubPlot(numberOfPlots: 2, stackPattern: .verticallyStacked)
subPlot.draw(plots: plots, renderer: svg_renderer, fileName: filePath+"svg/"+fileName)
subPlot.draw(plots: plots, renderer: agg_renderer, fileName: filePath+"agg/"+fileName)
