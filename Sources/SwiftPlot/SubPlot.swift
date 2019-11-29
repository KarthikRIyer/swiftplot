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

    public func draw(plots: [Plot], renderer: Renderer, fileName: String = "subPlot_output") throws {
        calculateSubPlotParams(numberOfPlots: plots.count)
        renderer.plotDimensions = plotDimensions
        for index in 0..<plots.count {
            let j: Int = index%numberOfColumns
            let i: Int = Int(index/numberOfColumns)
            renderer.xOffset = Float(j)*xOffset
            renderer.yOffset = Float(i)*yOffset
            var plot: Plot = plots[index]
            plot.plotSize = Size(width: plotDimensions.subWidth, height: plotDimensions.subHeight)
            plot.drawGraph(renderer: renderer)
        }
        try renderer.drawOutput(fileName: fileName)
    }

}
