import LinePlot
import Util
import Renderers
import SubPlot

var filePath = "examples/Reference/"
let fileName = "_05_sub_plot_grid_stacked_line_chart"

let x:[Float] = [0,100,263,489]
let y:[Float] = [0,320,310,170]

// var agg_renderer : Renderer = AGGRenderer()
var svg_renderer : Renderer = SVGRenderer()

var plots = [Plot]()

var lineGraph1 : LineGraph = LineGraph()
lineGraph1.addSeries(x, y, label: "Plot 1", color: Color.lightBlue)
var lineGraph2 : LineGraph = LineGraph()
lineGraph2.addSeries(x, y, label: "Plot 2", color: Color.orange)
var lineGraph3 : LineGraph = LineGraph()
lineGraph3.addSeries(x, y, label: "Plot 3", color: Color.brown)
var lineGraph4 : LineGraph = LineGraph()
lineGraph4.addSeries(x, y, label: "Plot 4", color: Color.green)
plots.append(lineGraph1)
plots.append(lineGraph2)
plots.append(lineGraph3)
plots.append(lineGraph4)
// lineGraph.drawGraphAndOutput(fileName : filePath+"agg/"+fileName, renderer : &agg_renderer)
// lineGraph.drawGraphAndOutput(fileName : filePath+"svg/"+fileName, renderer : &svg_renderer)

var subPlot : SubPlot = SubPlot(numberOfPlots : 4, numberOfRows : 2, numberOfColumns : 2, stackingPattern : SubPlot.GRID_STACKED)
subPlot.draw(plots : plots, renderer : &svg_renderer, fileName : filePath+"svg/"+fileName)
