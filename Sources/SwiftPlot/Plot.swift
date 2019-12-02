
/// An object which is able to draw itself in a Renderer.
public protocol Plot {
    /// Draws to the given renderer in-memory.
    /// - parameters:
    ///     - size: The overall size the plot has to lay out and draw in.
    ///     - renderer: The renderer. The plot should draw between
    ///       `(0...size.width)` on the X-axis and
    ///       `(0...size.height)` on the Y-axis.
    mutating func drawGraph(size: Size, renderer: Renderer)
}

extension Plot {
   
    /// Draws to the given renderer in-memory at a default size.
    public mutating func drawGraph(renderer: Renderer) {
        drawGraph(size: Size(width: 1000, height: 660),
                  renderer: renderer)
    }
    
    /// Draws and saves the graph to the named file.
    /// - note: This function changes the `imageSize` of the `Renderer` it is given.
    public mutating func drawGraphAndOutput(size: Size = Size(width: 1000, height: 660),
                                   fileName name: String = "swiftplot_graph", renderer: Renderer) throws {
        renderer.imageSize = size
        drawGraph(size: size, renderer: renderer)
        try renderer.drawOutput(fileName: name)
    }

    /// Saves the already-drawn graph to the named file.
    /// - note: This function changes the `imageSize` of the `Renderer` it is given.
    public mutating func drawGraphOutput(size: Size = Size(width: 1000, height: 660),
                                fileName name: String = "swiftplot_graph", renderer: Renderer) throws {
        renderer.imageSize = size
        try renderer.drawOutput(fileName: name)
    }
}
