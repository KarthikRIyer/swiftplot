public struct PlotDimensions{
	public var frameWidth  : Float = 1000
	public var frameHeight : Float = 660
	public var subWidth  : Float = 0
	public var subHeight : Float = 0
	public var graphWidth  : Float = 0
	public var graphHeight : Float = 0

	public init(frameWidth frameWidth : Float = 1000, frameHeight frameHeight : Float = 660, subWidth sW : Float = 1000, subHeight sH : Float = 660) {
		subWidth = sW
		subHeight = sH
		graphWidth = subWidth*0.8
		graphHeight = subHeight*0.8
	}

	public init(frameWidth frameWidth : Float = 1000, frameHeight frameHeight : Float = 660) {
		subWidth = frameWidth
		subHeight = frameHeight
		graphWidth = subWidth*0.8
		graphHeight = subHeight*0.8
	}

	public mutating func calculateGraphDimensions(){
		graphWidth = subWidth*0.8
		graphHeight = subHeight*0.8
	}
}
