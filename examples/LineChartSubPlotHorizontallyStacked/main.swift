import LinePlot
import Util
import Renderers
import SubPlot

var filePath = "examples/Reference/"
let fileName = "_03_sub_plot_horizontally_stacked_line_chart"

let x:[Float] = [0,100,263,489]
let y:[Float] = [0,320,310,170]

// var agg_renderer : Renderer = AGGRenderer()
var svg_renderer : Renderer = SVGRenderer()

var plots = [Plot]()

var lineGraph1 : LineGraph = LineGraph()
lineGraph1.addSeries(x, y, label: "Plot 1", color: Color.lightBlue)
var lineGraph2 : LineGraph = LineGraph()
lineGraph2.addSeries(x, y, label: "Plot 2", color: Color.orange)
plots.append(lineGraph1)
plots.append(lineGraph2)
// lineGraph.drawGraphAndOutput(fileName : filePath+"agg/"+fileName, renderer : &agg_renderer)
// lineGraph.drawGraphAndOutput(fileName : filePath+"svg/"+fileName, renderer : &svg_renderer)

var subPlot : SubPlot = SubPlot(numberOfPlots : 2, stackingPattern : SubPlot.HORIZONTALLY_STACKED)
subPlot.draw(plots : plots, renderer : &svg_renderer, fileName : filePath+"svg/"+fileName)
