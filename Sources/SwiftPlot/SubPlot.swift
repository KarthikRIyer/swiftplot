public class SubPlot: Plot {

    public enum StackPattern {
        case vertical
        case horizontal
        case grid(rows: Int, columns: Int)
    }
    
    public var plotSize: Size
    public var plots: [Plot] = []
    public var stackingPattern: StackPattern = .vertical

    var plotDimensions: PlotDimensions = PlotDimensions()

    public init(width: Float = 1000,
                height: Float = 660,
                stackPattern: StackPattern = .vertical) {
        plotSize = Size(width: width, height: height)
        stackingPattern = stackPattern
    }

    struct LayoutPlan {
        var subplotSize = Size.zero
        var plotLocations = [Point]()
    }
    
    func calculateLayoutPlan() -> LayoutPlan {
        var results = LayoutPlan()
        let offset: Point
        let columns: Int
        switch stackingPattern {
        case .vertical:
            results.subplotSize = Size(width: plotSize.width, height: plotSize.height/Float(plots.count))
            columns = 1
            offset = Point(0, results.subplotSize.height)
        case .horizontal:
            results.subplotSize = Size(width: plotSize.width/Float(plots.count), height: plotSize.height)
            columns = plots.count
            offset = Point(results.subplotSize.width, 0)
        case .grid(rows: let gRows, columns: let gColumns):
            assert(gRows*gColumns >= plots.count, "Number of plots greater than cells in grid.")
            results.subplotSize = Size(width: plotSize.width/Float(gColumns), height: plotSize.height/Float(gRows))
            offset = Point(results.subplotSize.width, results.subplotSize.height)
            columns = gColumns
        }
        for index in 0..<plots.count {
            let j: Int = index%columns
            let i: Int = Int(index/columns)
            results.plotLocations.append(
                Point(Float(j)*offset.x, Float(i)*offset.y)
            )
        }
        return results
    }
    
    public func drawGraph(renderer: Renderer) {
        let layoutPlan = calculateLayoutPlan()
        for index in 0..<plots.count {
            renderer.withAdditionalOffset(layoutPlan.plotLocations[index]) { renderer in
                var plot: Plot = plots[index]
                plot.plotSize = layoutPlan.subplotSize
                plot.drawGraph(renderer: renderer)
            }
        }
    }
}
