public struct PlotDimensions{
    public var frameWidth  : Float = 1000
    public var frameHeight : Float = 660
    public var subWidth  : Float = 0
    public var subHeight : Float = 0
    
    public init(frameWidth : Float = 1000,
                frameHeight : Float = 660,
                subWidth sW : Float = 1000,
                subHeight sH : Float = 660) {
        self.frameWidth = frameWidth
        self.frameHeight = frameHeight
        subWidth = sW
        subHeight = sH
    }

    public init(frameWidth : Float = 1000,
                frameHeight : Float = 660) {
        self.frameWidth = frameWidth
        self.frameHeight = frameHeight
        subWidth = frameWidth
        subHeight = frameHeight
    }
}
