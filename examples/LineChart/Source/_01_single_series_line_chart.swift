import LinePlot
import Util
import Renderers

func _01_single_series_line_chart() {
  var filePath = "examples/LineChart/Reference/"
  let fileName = "_01_single_series_line_chart"

  let x:[Float] = [0,100,263,489]
  let y:[Float] = [0,320,310,170]

  var agg_renderer : Renderer = AGGRenderer()
  var svg_renderer : Renderer = SVGRenderer()

  var lineGraph : LineGraph = LineGraph()
  lineGraph.addSeries(x, y, label: "Plot 1", color: Color.lightBlue)
  lineGraph.drawGraph(fileName : filePath+"agg/"+fileName, renderer : agg_renderer)
  lineGraph.drawGraph(fileName : filePath+"svg/"+fileName, renderer : svg_renderer)
}
