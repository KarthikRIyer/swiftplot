public struct PlotDimensions{
  public var frameWidth  : Float = 1000
  public var frameHeight : Float = 660
  public var graphWidth  : Float = 0
  public var graphHeight : Float = 0

  public init(frameWidth frameWidth : Float = 1000, frameHeight frameHeight : Float = 660) {
      graphWidth = frameWidth*0.8
      graphHeight = frameHeight*0.8
  }

  public mutating func calculateGraphDimensions(){
    graphWidth = frameWidth*0.8
    graphHeight = frameHeight*0.8
  }
}
