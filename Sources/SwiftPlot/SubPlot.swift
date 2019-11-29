public class SubPlot{

    public enum StackPattern {
        case verticallyStacked
        case horizontallyStacked
        case gridStacked
    }

    var frameWidth: Float
    var frameHeight: Float
    var subWidth: Float
    var subHeight: Float
    var numberOfPlots: Int = 1
    var numberOfRows: Int = 1
    var numberOfColumns: Int = 1
    var stackingPattern: StackPattern = .verticallyStacked
    var xOffset: Float = 0
    var yOffset: Float = 0

    var plotDimensions: PlotDimensions = PlotDimensions()

    public init(width: Float = 1000,
                height: Float = 660,
                numberOfPlots n: Int = 1,
                numberOfRows nR: Int = 1,
                numberOfColumns nC: Int = 1,
                stackPattern: StackPattern = .verticallyStacked) {
        frameWidth = width
        frameHeight = height
        subWidth = width
        subHeight = height
        stackingPattern = stackPattern
        numberOfRows = nR
        numberOfColumns = nC
        calculateSubPlotParams(numberOfPlots: n)
    }

    func calculateSubPlotParams(numberOfPlots n: Int) {
        numberOfPlots = n
        if (stackingPattern == .verticallyStacked) {
            subWidth = frameWidth
            subHeight = frameHeight/Float(numberOfPlots)
            numberOfRows = numberOfPlots
            numberOfColumns = 1
            xOffset = 0
            yOffset = subHeight
        }
        else if (stackingPattern == .horizontallyStacked) {
            subWidth = frameWidth/Float(numberOfPlots)
            subHeight = frameHeight
            numberOfRows = 1
            numberOfColumns = numberOfPlots
            xOffset = subWidth
            yOffset = 0
        }
        else if (stackingPattern == .gridStacked){
            assert(numberOfRows*numberOfColumns >= numberOfPlots, "Number of plots greater than cells in grid.")
            subWidth = frameWidth/Float(numberOfColumns)
            subHeight = frameHeight/Float(numberOfRows)
            xOffset = subWidth
            yOffset = subHeight
        }
        plotDimensions = PlotDimensions(frameWidth: frameWidth,
                                        frameHeight: frameHeight,
                                        subWidth: subWidth,
                                        subHeight: subHeight)
    }

    public func draw(plots: [Plot], renderer: Renderer) {
        calculateSubPlotParams(numberOfPlots: plots.count)
        renderer.imageSize = plotDimensions.frameSize
        for index in 0..<plots.count {
            let j: Int = index%numberOfColumns
            let i: Int = Int(index/numberOfColumns)
            renderer.xOffset = Float(j)*xOffset
            renderer.yOffset = Float(i)*yOffset
            var plot: Plot = plots[index]
            plot.plotSize = plotDimensions.subplotSize
            plot.drawGraph(renderer: renderer)
        }
    }
    
    public func drawPlotsAndOutput(plots: [Plot], renderer: Renderer, fileName name: String = "swiftplot_graph") throws {
        draw(plots: plots, renderer: renderer)
        try saveImage(fileName: name, renderer: renderer)
    }

    public func drawPlotsOutput(plots: [Plot], renderer: Renderer, fileName name: String = "swiftplot_graph") throws {
//        renderer.plotDimensions = PlotDimensions(frameWidth: plotSize.width, frameHeight: plotSize.height)
//        try renderer.drawOutput(fileName: name)
    }
    
    func saveImage(fileName name: String, renderer: Renderer) throws {
        try renderer.drawOutput(fileName: name)
    }

}
