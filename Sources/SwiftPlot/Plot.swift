public protocol Plot {
    var xOffset: Float { get set }
    var yOffset: Float { get set }
    var plotDimensions: PlotDimensions { get set }
    
    var legendLabels: [(String, LegendIcon)] { get }
    
    func drawGraph(renderer: Renderer)
}

extension Plot {
    public var legendLabels: [(String, LegendIcon)] {
        return []
    }
}
