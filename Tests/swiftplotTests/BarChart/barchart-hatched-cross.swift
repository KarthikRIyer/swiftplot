import SwiftPlot
import AGGRenderer
import SVGRenderer
#if os(iOS) || os(macOS)
import QuartzRenderer
#endif

var filePath = "examples/Reference/"
let fileName = "_15_bar_chart_cross_hatched"

let x:[String] = ["2008","2009","2010","2011"]
let y:[Float] = [320,-100,420,500]

var agg_renderer = AGGRenderer()
var svg_renderer = SVGRenderer()
#if os(iOS) || os(macOS)
var quartz_renderer = QuartzRenderer()
#endif

var barGraph = BarGraph<String,Float>(enableGrid: true)
barGraph.addSeries(x, y, label: "Plot 1", color: .orange, hatchPattern: .cross)
barGraph.plotTitle = PlotTitle("HATCHED BAR CHART")
barGraph.plotLabel = PlotLabel(xLabel: "X-AXIS", yLabel: "Y-AXIS")

barGraph.drawGraphAndOutput(fileName: filePath+"agg/"+fileName,
                            renderer: agg_renderer)
barGraph.drawGraphAndOutput(fileName: filePath+"svg/"+fileName,
                            renderer: svg_renderer)
#if os(iOS) || os(macOS)
barGraph.drawGraphAndOutput(fileName: filePath+"quartz/"+fileName,
                            renderer: quartz_renderer)
#endif
