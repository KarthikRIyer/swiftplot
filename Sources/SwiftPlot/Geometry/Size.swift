
public struct Size: Hashable {
    public var width: Float
    public var height: Float
    
    public init(width: Float, height: Float) {
        self.width = width
        self.height = height
    }
}

extension Size {
    public static let zero = Size(width: 0, height: 0)
}

extension Size {
    
    /// Returns a `Size` whose `width` is equal to this size's `height`,
    ///  and whose `height` is equal to this size's `width`.
    ///
    public func swappingComponents() -> Size {
        Size(width: height, height: width)
    }
}
