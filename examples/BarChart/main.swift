import SwiftPlot
import AGGRenderer
import SVGRenderer

var filePath = "examples/Reference/"
let fileName = "_08_bar_chart"

let x:[String] = ["Java","Swift","C++","Python"]
let y:[Float] = [320,100,420,500]

var agg_renderer: AGGRenderer = AGGRenderer()
var svg_renderer: SVGRenderer = SVGRenderer()

var plotTitle: PlotTitle = PlotTitle()

var lineGraph: LineGraph = LineGraph()
lineGraph.addSeries(x, y, label: "Plot 1", color: Color.lightBlue)
plotTitle.title = "SINGLE SERIES"
lineGraph.plotTitle = plotTitle

lineGraph.drawGraphAndOutput(fileName: filePath+"agg/"+fileName, renderer: agg_renderer)
lineGraph.drawGraphAndOutput(fileName: filePath+"svg/"+fileName, renderer: svg_renderer)
