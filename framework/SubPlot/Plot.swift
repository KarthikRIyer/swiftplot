import Renderers
import Util
public protocol Plot {
  var xOffset : Float { get set }
  var yOffset : Float { get set }
  var plotDimensions : PlotDimensions { get set }
  func drawGraph(renderer renderer : Renderer)
}
