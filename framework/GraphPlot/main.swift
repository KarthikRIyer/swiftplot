import LinePlot
let x1:[Float] = [0,100,263,489]
let y1:[Float] = [0,320,310,170]
let x2:[Float] = [0,50,113,250]
let y2:[Float] = [0,20,100,170]

var lineGraph : LineGraph = LineGraph()
lineGraph.addSeries(x1, y1, label: "Plot 1", color: lightBlue)
lineGraph.addSeries(x2, y2, label: "Plot 2", color: orange)
lineGraph.setRenderer(renderer : RENDERER_AGG)
lineGraph.drawGraph(fileName : "swift_plot_test")
