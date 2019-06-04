public class BarGraphSeriesOptions {
    public enum Hatching: Int, CaseIterable{
        case none = 0
        case forwardSlash = 1
        case backwardSlash = 2
        case hollowCircleHatch = 3
        case filledCircleHatch = 4
    }
    public var hatchPattern: Hatching = .none
    public init() {}
}
