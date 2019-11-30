public protocol Plot {

    var plotSize: Size { get set }
    
    var legendLabels: [(String, LegendIcon)] { get }
    
    func drawGraph(renderer: Renderer)
}

extension Plot {
    public var legendLabels: [(String, LegendIcon)] {
        return []
    }
    
    // call functions to draw the graph
    public func drawGraphAndOutput(fileName name: String = "swiftplot_graph", renderer: Renderer) throws {
        renderer.plotDimensions = PlotDimensions(frameWidth: plotSize.width, frameHeight: plotSize.height)
        drawGraph(renderer: renderer)
        try saveImage(fileName: name, renderer: renderer)
    }

    public func drawGraphOutput(fileName name: String = "swiftplot_graph",
                                renderer: Renderer) throws {
        renderer.plotDimensions = PlotDimensions(frameWidth: plotSize.width, frameHeight: plotSize.height)
        try renderer.drawOutput(fileName: name)
    }
    
    func saveImage(fileName name: String, renderer: Renderer) throws {
        try renderer.drawOutput(fileName: name)
    }
}
