public class BarGraphSeriesOptions {
    public enum Hatching: Int, CaseIterable{
        case none = 0
        case forwardSlash = 1
        case backwardSlash = 2
        case hollowCircle = 3
        case filledCircle = 4
        case vertical = 5
        case horizontal = 6
        case grid = 7
        case cross = 8
    }
    public var hatchPattern: Hatching = .none
    public init() {}
}
