import LinePlot

func _01_single_series_line_chart() {
  var filePath = "examples/LineChart/Reference/"
  let fileName = "_01_single_series_line_chart"

  let x:[Float] = [0,100,263,489]
  let y:[Float] = [0,320,310,170]

  var lineGraph : LineGraph = LineGraph()
  lineGraph.addSeries(x, y, label: "Plot 1", color: lightBlue)
  lineGraph.setRenderer(renderer : RENDERER_AGG)
  lineGraph.drawGraph(fileName : filePath+"agg/"+fileName)
  lineGraph.setRenderer(renderer : RENDERER_SVG)
  lineGraph.drawGraph(fileName : filePath+"svg/"+fileName)
}
