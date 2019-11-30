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
    
    // call functions to draw the graph
    public func drawGraphAndOutput(fileName name: String = "swiftplot_graph", renderer: Renderer){
        renderer.plotDimensions = plotDimensions
        drawGraph(renderer: renderer)
        saveImage(fileName: name, renderer: renderer)
    }

    public func drawGraphOutput(fileName name: String = "swiftplot_graph",
                                renderer: Renderer){
        renderer.plotDimensions = plotDimensions
        renderer.drawOutput(fileName: name)
    }
    
    func saveImage(fileName name: String, renderer: Renderer) {
        renderer.drawOutput(fileName: name)
    }
}
