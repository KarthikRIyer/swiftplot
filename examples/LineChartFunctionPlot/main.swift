import Foundation
import LinePlot
import Util
import Renderers

func logC(val: Float, forBase base: Float) -> Float {
    return (log(val)/log(base))
}

func function(_ x: Float)->Float {
    // return sin(x)
    // return logC(val: x, forBase: 10.0)
    // return (exp(-x)*cos(.pi*2*x))
    // return exp(-x*x)
    // return x*x
    return 1.0/x
}

var filePath = "examples/Reference/"
let fileName = "_06_function_plot_line_chart"

var agg_renderer: Renderer = AGGRenderer()
var svg_renderer: Renderer = SVGRenderer()

var plotTitle: PlotTitle = PlotTitle()

var lineGraph: LineGraph = LineGraph()
lineGraph.addFunction(function, minX: -5.0, maxX: 5.0, numberOfSamples: 400, label: "Function", color: Color.orange)
plotTitle.title = "FUNCTION"
lineGraph.plotTitle = plotTitle

lineGraph.drawGraphAndOutput(fileName: filePath+"agg/"+fileName, renderer: agg_renderer)
lineGraph.drawGraphAndOutput(fileName: filePath+"svg/"+fileName, renderer: svg_renderer)
