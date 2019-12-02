public class SubPlot: Plot {

    public enum StackPattern {
        case vertical
        case horizontal
        case grid(rows: Int, columns: Int)
    }
    
    public var plots: [Plot]
    public var layout: StackPattern

    public init(layout: StackPattern = .vertical, plots: [Plot] = []) {
        self.layout = layout
        self.plots  = plots
    }

    struct LayoutPlan {
        var subplotSize = Size.zero
        var plotLocations = [Point]()
    }
    
    func calculateLayoutPlan(plotSize: Size) -> LayoutPlan {
        var results = LayoutPlan()
        let offset: Point
        let columns: Int
        switch layout {
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
    
    public func drawGraph(size: Size, renderer: Renderer) {
        let layoutPlan = calculateLayoutPlan(plotSize: size)
        for index in 0..<plots.count {
            renderer.withAdditionalOffset(layoutPlan.plotLocations[index]) { renderer in
                plots[index].drawGraph(size: layoutPlan.subplotSize, renderer: renderer)
            }
        }
    }
}
