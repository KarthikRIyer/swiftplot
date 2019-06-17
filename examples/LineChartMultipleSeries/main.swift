import SwiftPlot
import AGGRenderer
import SVGRenderer

var filePath = "examples/Reference/"
let fileName = "_02_multiple_series_line_chart"

let x1:[Float] = [0,100,263,489]
let y1:[Float] = [0,320,310,170]
let x2:[Float] = [0,50,113,250]
let y2:[Float] = [0,20,100,170]

var agg_renderer = AGGRenderer()
var svg_renderer = SVGRenderer()

var lineGraph: LineGraph = LineGraph()
lineGraph.addSeries(x1, y1, label: "Plot 1", color: .lightBlue)
lineGraph.addSeries(x2, y2, label: "Plot 2", color: .orange)
lineGraph.plotTitle = PlotTitle("MULTIPLE SERIES")
lineGraph.plotLabel = PlotLabel(xLabel: "X-AXIS", yLabel: "Y-AXIS")

lineGraph.drawGraphAndOutput(fileName: filePath+"agg/"+fileName, renderer: agg_renderer)
lineGraph.drawGraphAndOutput(fileName: filePath+"svg/"+fileName, renderer: svg_renderer)
