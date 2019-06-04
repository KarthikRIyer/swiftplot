import SwiftPlot
import AGGRenderer
import SVGRenderer

var filePath = "examples/Reference/"
let fileName = "_11_bar_chart_vertical_hatched"

let x:[String] = ["2008","2009","2010","2011"]
let y:[Float] = [320,-100,420,500]

var agg_renderer: AGGRenderer = AGGRenderer()
var svg_renderer: SVGRenderer = SVGRenderer()

var plotTitle: PlotTitle = PlotTitle()

var barGraph: BarGraph = BarGraph()
barGraph.addSeries(x, y, label: "Plot 1", color: .orange, hatchPattern: .vertical)
plotTitle.title = "HATCHED BAR CHART"
barGraph.plotTitle = plotTitle

barGraph.drawGraphAndOutput(fileName: filePath+"agg/"+fileName, renderer: agg_renderer)
barGraph.drawGraphAndOutput(fileName: filePath+"svg/"+fileName, renderer: svg_renderer)
