import SwiftPlot
import AGGRenderer
import SVGRenderer

var filePath = "examples/Reference/"
let fileName = "_05_sub_plot_grid_stacked_line_chart"

let x:[Float] = [0,100,263,489]
let y:[Float] = [0,320,310,170]

var agg_renderer: AGGRenderer = AGGRenderer()
var svg_renderer: SVGRenderer = SVGRenderer()

var plots = [Plot]()

var lineGraph1 = LineGraph()
lineGraph1.addSeries(x, y, label: "Plot 1", color: .lightBlue)
lineGraph1.plotTitle = PlotTitle("PLOT 1")
lineGraph1.plotLabel = PlotLabel(xLabel: "X-AXIS", yLabel: "Y-AXIS")

var lineGraph2 = LineGraph()
lineGraph2.addSeries(x, y, label: "Plot 2", color: .orange)
lineGraph2.plotTitle = PlotTitle("PLOT 2")
lineGraph2.plotLabel = PlotLabel(xLabel: "X-AXIS", yLabel: "Y-AXIS")

var lineGraph3 = LineGraph()
lineGraph3.addSeries(x, y, label: "Plot 3", color: .brown)
lineGraph3.plotTitle = PlotTitle("PLOT 3")
lineGraph3.plotLabel = PlotLabel(xLabel: "X-AXIS", yLabel: "Y-AXIS")

var lineGraph4 = LineGraph()
lineGraph4.addSeries(x, y, label: "Plot 4", color: .green)
lineGraph4.plotTitle = PlotTitle("PLOT 4")
lineGraph4.plotLabel = PlotLabel(xLabel: "X-AXIS", yLabel: "Y-AXIS")

plots.append(lineGraph1)
plots.append(lineGraph2)
plots.append(lineGraph3)
plots.append(lineGraph4)

var subPlot = SubPlot(numberOfPlots: 4, numberOfRows: 2, numberOfColumns: 2, stackPattern: .gridStacked)
subPlot.draw(plots: plots, renderer: svg_renderer, fileName: filePath+"svg/"+fileName)
subPlot.draw(plots: plots, renderer: agg_renderer, fileName: filePath+"agg/"+fileName)
