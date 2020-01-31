
/// An object which maps a value in the range `0...1` to a `Color`.
///
/// This object wraps a conformer to `ColorMapProtocol`, and is used instead of `ColorMapProtocol` directly
/// in order to provide a cleaner interface and to automatically clamp out-of-range values.
/// Common color maps are available as static functions on this type, allowing code such as:
/// `x.colorMap = .fiveColorHeatMap`.
///
public struct ColorMap: ColorMapProtocol {
    var base: ColorMapProtocol
    
    public init(_ base: ColorMapProtocol) {
        // If base is already wrapped, do not re-wrap it.
        if let existing = base as? ColorMap { self = existing }
        else { self.base = base }
    }
    public func colorForOffset(_ offset: Double) -> Color {
        let offset = min(max(offset, 0), 1)
        return base.colorForOffset(offset)
    }
}

/// An object which maps a value in the range `0...1` to a `Color`.
///
public protocol ColorMapProtocol {
    func colorForOffset(_ offset: Double) -> Color
}
extension ColorMapProtocol {
    func colorForOffset(_ offset: Float) -> Color {
        return colorForOffset(Double(offset))
    }
}

// MARK: - Color Transformations.

private struct ColorTransformer: ColorMapProtocol {
    var base: ColorMapProtocol
    var transform: (Color)->Color
    init(_ base: ColorMapProtocol, transform: @escaping (Color)->Color) {
        self.base = base; self.transform = transform
    }
    func colorForOffset(_ offset: Double) -> Color {
        return transform(base.colorForOffset(offset))
    }
}

extension ColorMap {
    
    /// Returns a `ColorMap` whose output is transformed by the given closure.
    ///
    public func withTransform(_ transform: @escaping (Color)->Color) -> ColorMap {
        return ColorMap(ColorTransformer(base, transform: transform))
    }
    
    /// Returns a `ColorMap` whose output colors' alpha components are given by `alpha`.
    ///
    public func withAlpha(_ alpha: Float) -> ColorMap {
        return withTransform { $0.withAlpha(alpha) }
    }

    /// Returns a `ColorMap` whose output colors are lightened by the given `amount`.
    ///
    public func lightened(by amount: Float) -> ColorMap {
        return withTransform { $0.linearBlend(with: .white, offset: amount) }
    }
    
    /// Returns a `ColorMap` whose output colors are darkened by the given `amount`.
    ///
    public func darkened(by amount: Float) -> ColorMap {
        return withTransform { $0.linearBlend(with: .black, offset: amount) }
    }
}

// MARK: - Offset Transformations.

private struct ColorMapOffsetTransformer: ColorMapProtocol {
    var base: ColorMapProtocol
    var transform: (Double)->Double
    init(_ base: ColorMapProtocol, transform: @escaping (Double)->Double) {
        self.base = base; self.transform = transform
    }
    func colorForOffset(_ offset: Double) -> Color {
        // Ensure that we don't transform the offset out of bounds.
        var transformedOffset = transform(offset)
        transformedOffset = min(max(transformedOffset, 0), 1)
        return base.colorForOffset(transformedOffset)
    }
}

extension ColorMap {
    
    private func withOffsetTransform(_ transform: @escaping (Double) -> Double) -> ColorMap {
        return ColorMap(ColorMapOffsetTransformer(base, transform: transform))
    }
    
    /// Returns a `ColorMap` whose output at offset `x` is equal to this `ColorMap`'s output at `1 - x`.
    ///
    public func reversed() -> ColorMap {
        return withOffsetTransform { 1 - $0 }
    }
}

// MARK: - Single Colors.

private struct SingleColorMap: ColorMapProtocol {
    var color: Color
    func colorForOffset(_ offset: Double) -> Color {
        return color
    }
}

extension ColorMap {
    
    /// Returns a `ColorMap` which always returns the same color.
    ///
    public static func color(_ color: Color) -> ColorMap {
    	return ColorMap(SingleColorMap(color: color))
    }
}

// MARK: - Linear Gradients.

/// A position along a gradient.
///
public struct GradientStop {
    public var color: Color
    public var position: Double
    public init(_ color: Color, at position: Double) {
        self.color = color; self.position = position
    }
}

private struct LinearGradient: ColorMapProtocol {
    var stops: [GradientStop]
    
    init(stops: [GradientStop]) {
        self.stops = stops.sorted { $0.position < $1.position }
    }
    init(start: Color, end: Color) {
        self.init(stops: [GradientStop(start, at: 0), GradientStop(end, at: 1)])
    }
    func colorForOffset(_ offset: Double) -> Color {
        guard let rightStopIdx = stops.firstIndex(where: { $0.position > offset }) else {
            return stops.last?.color ?? .black
        }
        let rightStop = stops[rightStopIdx]
        guard rightStopIdx > stops.startIndex else { return rightStop.color }
        let leftStop = stops[stops.index(before: rightStopIdx)]
        assert(leftStop.position <= offset)
        
        let distance = rightStop.position - leftStop.position
        guard distance > 0 else { return rightStop.color }
        
        let offset = (offset - leftStop.position) / distance
        return leftStop.color.linearBlend(with: rightStop.color, offset: Float(offset))
    }
}

extension ColorMap {
    
    /// Returns a `ColorMap` whose output is a linear gradient with the given stops.
    ///
    public static func linearGradient(_ stops: [GradientStop]) -> ColorMap {
        return ColorMap(LinearGradient(stops: stops))
    }
    
    /// Returns a `ColorMap` whose output is a linear gradient between the given colors.
    ///
    public static func linearGradient(_ start: Color, _ end: Color) -> ColorMap {
        return ColorMap(LinearGradient(start: start, end: end))
    }
    
    /// A standard, five-color heat map.
    ///
    public static let fiveColorHeatMap = ColorMap.linearGradient([
        GradientStop(Color(0, 0, 1, 1), at: 0),
        GradientStop(Color(0, 1, 1, 1), at: 0.25),
        GradientStop(Color(0, 1, 0, 1), at: 0.5),
        GradientStop(Color(1, 1, 0, 1), at: 0.75),
        GradientStop(Color(1, 0, 0, 1), at: 1),
    ])

    /// A standard, seven-color heat map.
    ///
    public static let sevenColorHeatMap = ColorMap.linearGradient([
        GradientStop(Color(0, 0, 0, 1), at: 0),
        GradientStop(Color(0, 0, 1, 1), at: 0.1666666667),
        GradientStop(Color(0, 1, 1, 1), at: 0.3333333333),
        GradientStop(Color(0, 1, 0, 1), at: 0.5),
        GradientStop(Color(1, 1, 0, 1), at: 0.6666666667),
        GradientStop(Color(1, 0, 0, 1), at: 0.8333333333),
        GradientStop(Color(1, 1, 1, 1), at: 1)
    ])
}

