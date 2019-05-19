import Util
import Renderers

public class SubPlot{
  public static let VERTICALLY_STACKED : Int = 0
  public static let HORIZONTALLY_STACKED : Int = 1

  var frameWidth : Float = 1000
  var frameHeight : Float = 660
  var subWidth : Float = 1000
  var subHeight : Float = 660
  var numberOfPlots : Int = 1
  var numberOfRows : Int = 1
  var numberOfColumns : Int = 1
  var stackingPattern : Int = 0
  var xOffset : Float = 0
  var yOffset : Float = 0

  var plotDimensions : PlotDimensions = PlotDimensions()

  public init(frameWidth width : Float = 1000, frameHeight height : Float = 660, numberOfPlots n : Int = 1, stackingPattern stackPattern : Int = 0) {
    frameWidth = width
    frameHeight = height
    stackingPattern = stackPattern
    calculateSubPlotParams(numberOfPlots : n)
  }

  func calculateSubPlotParams(numberOfPlots n : Int) {
    numberOfPlots = n
    if (stackingPattern == SubPlot.VERTICALLY_STACKED) {
        subWidth = frameWidth
        subHeight = frameHeight/Float(numberOfPlots)
        numberOfRows = numberOfPlots
        numberOfColumns = 1
        xOffset = 0
        yOffset = subHeight
    }
    else if (stackingPattern == SubPlot.HORIZONTALLY_STACKED) {
      subWidth = frameWidth/Float(numberOfPlots)
      subHeight = frameHeight
      numberOfRows = 1
      numberOfColumns = numberOfPlots
      xOffset = subWidth
      yOffset = 0
    }
    plotDimensions = PlotDimensions(frameWidth : frameWidth, frameHeight : frameHeight, subWidth : subWidth, subHeight : subHeight)
  }

  // public init(frameWidth width : Float = 1000, frameHeight height : Float = 660, numberOfRows nR : Int = 1, numberOfColumns nC : Int = 1) {
  //   frameWidth = width
  //   frameHeight = height
  //   subWidth = frameWidth/Float(nC)
  //   subHeight = frameHeight/Float(nR)
  //   xOffset = subWidth
  //   yOffset = subHeight
  // }

  public func draw(plots plots : [Plot], renderer renderer : inout Renderer, fileName fileName : String = "subPlot_output") {
    calculateSubPlotParams(numberOfPlots : plots.count)
    print("count \(plots.count)")
      for index in 0..<plots.count {
        var plot : Plot = plots[index]
        plot.xOffset = Float(index)*xOffset
        plot.yOffset = Float(index)*yOffset
        plot.plotDimensions = plotDimensions
        renderer.plotDimensions = plotDimensions
        plot.drawGraph(renderer : &renderer)
      }
      renderer.drawOutput(fileName : fileName)
  }

}
