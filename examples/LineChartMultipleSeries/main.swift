import SwiftPlot
import AGGRenderer
import SVGRenderer
import QuartzRenderer

var filePath = "examples/Reference/"
let fileName = "_02_multiple_series_line_chart"

let x1:[Float] = [10,100,263,489]
let y1:[Float] = [10,120,500,800]
let x2:[Float] = [100,200,361,672]
let y2:[Float] = [150,250,628,800]

var agg_renderer = AGGRenderer()
var svg_renderer = SVGRenderer()
var quartz_renderer = QuartzRenderer()

var lineGraph = LineGraph<Float,Float>(enablePrimaryAxisGrid: true)
lineGraph.addSeries(x1, y1, label: "Plot 1", color: .lightBlue)
lineGraph.addSeries(x2, y2, label: "Plot 2", color: .orange)
lineGraph.plotTitle = PlotTitle("MULTIPLE SERIES")
lineGraph.plotLabel = PlotLabel(xLabel: "X-AXIS", yLabel: "Y-AXIS")
lineGraph.plotLineThickness = 3.0

lineGraph.drawGraphAndOutput(fileName: filePath+"agg/"+fileName,
                             renderer: agg_renderer)
lineGraph.drawGraphAndOutput(fileName: filePath+"svg/"+fileName,
                             renderer: svg_renderer)
lineGraph.drawGraphAndOutput(fileName: filePath+"quartz/"+fileName,
                             renderer: quartz_renderer)
