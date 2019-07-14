import Foundation
import SwiftPlot
import AGGRenderer
import SVGRenderer

func function(_ x: Float)->Float {
    return 1.0/x
}

var filePath = "examples/Reference/"
let fileName = "_06_function_plot_line_chart"

var agg_renderer = AGGRenderer()
var svg_renderer = SVGRenderer()

var lineGraph = LineGraph<Float,Float>(enablePrimaryAxisGrid: true)
lineGraph.addFunction(function, minX: -5.0, maxX: 5.0, numberOfSamples: 400, label: "Function", color: .orange)
lineGraph.plotTitle = PlotTitle("FUNCTION")
lineGraph.plotLabel = PlotLabel(xLabel: "X-AXIS", yLabel: "Y-AXIS")

lineGraph.drawGraphAndOutput(fileName: filePath+"agg/"+fileName, renderer: agg_renderer)
lineGraph.drawGraphAndOutput(fileName: filePath+"svg/"+fileName, renderer: svg_renderer)
