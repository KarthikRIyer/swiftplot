import SwiftPlot
import AGGRenderer
import SVGRenderer
#if os(iOS) || os(macOS)
import QuartzRenderer
#endif

var filePath = "examples/Reference/"
let fileName = "_04_sub_plot_vertically_stacked_line_chart"

let x:[Float] = [10,100,263,489]
let y:[Float] = [10,120,500,800]

var agg_renderer = AGGRenderer()
var svg_renderer = SVGRenderer()
#if os(iOS) || os(macOS)
var quartz_renderer = QuartzRenderer()
#endif

var plots = [Plot]()

var lineGraph1 = LineGraph<Float,Float>(enablePrimaryAxisGrid: true)
lineGraph1.addSeries(x, y, label: "Plot 1", color: .lightBlue)
lineGraph1.plotTitle = PlotTitle("PLOT 1")
lineGraph1.plotLabel = PlotLabel(xLabel: "X-AXIS", yLabel: "Y-AXIS")
lineGraph1.plotLineThickness = 3.0

var lineGraph2 = LineGraph<Float,Float>(enablePrimaryAxisGrid: true)
lineGraph2.addSeries(x, y, label: "Plot 2", color: .orange)
lineGraph2.plotTitle = PlotTitle("PLOT 2")
lineGraph2.plotLabel = PlotLabel(xLabel: "X-AXIS", yLabel: "Y-AXIS")
lineGraph2.plotLineThickness = 3.0

plots.append(lineGraph1)
plots.append(lineGraph2)

var subPlot = SubPlot(numberOfPlots: 2, stackPattern: .verticallyStacked)
subPlot.draw(plots: plots,
             renderer: svg_renderer,
             fileName: filePath+"svg/"+fileName)
subPlot.draw(plots: plots,
             renderer: agg_renderer,
             fileName: filePath+"agg/"+fileName)
#if os(iOS) || os(macOS)
subPlot.draw(plots: plots,
             renderer: quartz_renderer,
             fileName: filePath+"quartz/"+fileName)
#endif
