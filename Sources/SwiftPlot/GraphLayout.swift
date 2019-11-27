import Foundation

public enum LegendIcon {
    case square(Color)
    case shape(ScatterPlotSeriesOptions.ScatterPattern, Color)
}

public struct GraphLayout {
    // Inputs.
    var plotDimensions: PlotDimensions
    
    init(plotDimensions: PlotDimensions) {
        self.plotDimensions = plotDimensions
        self.plotDimensions.calculateGraphDimensions()
    }
    
    var plotTitle: PlotTitle? = nil
    var plotLabel: PlotLabel? = nil
    var plotLegend = PlotLegend()
    var plotBorder = PlotBorder()
    var legendLabels: [(String, LegendIcon)] = []
    
    var enablePrimaryAxisGrid = true
    var enableSecondaryAxisGrid = true
    var gridColor = Color.gray
    var gridLineThickness: Float = 0.5
    var markerTextSize: Float = 12
    
    struct Results {
        var xLabelLocation: Point?
        var yLabelLocation: Point?
        var titleLocation: Point?
        
        var plotBorderRect: Rect?
        var plotLegendTopLeft: Point?
        var primaryAxisPlotMarkers = PlotMarkers()
        var secondaryAxisPlotMarkers: PlotMarkers? = nil
        
        var legendRect: Rect?
    }
    
    // Layout.
        
    func layout(renderer: Renderer, calculateMarkers: (inout PlotMarkers, inout PlotMarkers?)->Void) -> Results {
        var results = Results()
        calcBorderAndLegend(results: &results)
        calcLabelLocations(renderer: renderer, results: &results)
        calculateMarkers(&results.primaryAxisPlotMarkers, &results.secondaryAxisPlotMarkers)
        calcLegend(legendLabels, results: &results, renderer: renderer)
        return results
    }
    
    func calcBorderAndLegend(results: inout Results) {
        let borderRect = Rect(
            origin: Point(plotDimensions.subWidth * 0.1, plotDimensions.subHeight * 0.1),
            size: Size(width: plotDimensions.subWidth * 0.8,
                       height: plotDimensions.subHeight * 0.8)
        )
        results.plotBorderRect = borderRect
        results.plotLegendTopLeft = Point(borderRect.minX + Float(20),
                                          borderRect.maxY - Float(20))
    }

    func calcLabelLocations(renderer: Renderer, results: inout Results) {
        if let plotLabel = plotLabel {
            let xWidth = renderer.getTextWidth(text: plotLabel.xLabel, textSize: plotLabel.labelSize)
            let yWidth = renderer.getTextWidth(text: plotLabel.yLabel, textSize: plotLabel.labelSize)
            results.xLabelLocation = Point(
                results.plotBorderRect!.midX - xWidth * 0.5,
                results.plotBorderRect!.minY - plotLabel.labelSize - 0.05 * plotDimensions.graphHeight
            )
            results.yLabelLocation = Point(
                results.plotBorderRect!.origin.x - plotLabel.labelSize - 0.05 * plotDimensions.graphWidth,
                results.plotBorderRect!.midY - yWidth
            )
        }
        if let plotTitle = plotTitle {
          let titleWidth = renderer.getTextWidth(text: plotTitle.title, textSize: plotTitle.titleSize)
          results.titleLocation = Point(
            results.plotBorderRect!.midX - titleWidth * 0.5,
            results.plotBorderRect!.maxY + plotTitle.titleSize * 0.5
          )
        }
    }
    
    func calcLegend(_ labels: [(String, LegendIcon)], results: inout Results, renderer: Renderer) {
        guard !labels.isEmpty else { return }
        let maxWidth = labels.lazy.map {
            renderer.getTextWidth(text: $0.0, textSize: self.plotLegend.legendTextSize)
        }.max() ?? 0
        
        let legendWidth  = maxWidth + 3.5 * plotLegend.legendTextSize
        let legendHeight = (Float(labels.count)*2.0 + 1.0) * plotLegend.legendTextSize
        
        results.legendRect = Rect(
            origin: results.plotLegendTopLeft!,
            size: Size(width: legendWidth, height: -legendHeight)
        ).normalized
    }
    
    // Drawing.
    
    func drawBackground(results: Results, renderer: Renderer) {
        drawGrid(results: results, renderer: renderer)
        drawBorder(results: results, renderer: renderer)
        drawMarkers(results: results, renderer: renderer)
    }
    
    func drawForeground(results: Results, renderer: Renderer) {
        drawTitle(results: results, renderer: renderer)
        drawLabels(results: results, renderer: renderer)
        drawLegend(legendLabels, results: results, renderer: renderer)
    }
    
    func drawTitle(results: Results, renderer: Renderer) {
        guard let plotTitle = self.plotTitle, let location = results.titleLocation else { return }
        renderer.drawText(text: plotTitle.title,
                          location: location,
                          textSize: plotTitle.titleSize,
                          strokeWidth: 1.2,
                          angle: 0,
                          isOriginShifted: false)
    }

    func drawLabels(results: Results, renderer: Renderer) {
        guard let plotLabel = self.plotLabel else { return }
        if let xLocation = results.xLabelLocation {
            renderer.drawText(text: plotLabel.xLabel,
                              location: xLocation,
                              textSize: plotLabel.labelSize,
                              strokeWidth: 1.2,
                              angle: 0,
                              isOriginShifted: false)
        }
        if let yLocation = results.yLabelLocation {
            renderer.drawText(text: plotLabel.yLabel,
                              location: yLocation,
                              textSize: plotLabel.labelSize,
                              strokeWidth: 1.2,
                              angle: 90,
                              isOriginShifted: false)
        }
    }
    
    func drawBorder(results: Results, renderer: Renderer) {
        guard let borderRect = results.plotBorderRect else { return }
        renderer.drawRect(borderRect,
                          strokeWidth: plotBorder.borderThickness,
                          strokeColor: Color.black, isOriginShifted: false)
    }
    
    func drawGrid(results: Results, renderer: Renderer) {
        guard enablePrimaryAxisGrid || enablePrimaryAxisGrid else { return }
        for index in 0..<results.primaryAxisPlotMarkers.xMarkers.count {
            let p1 = Point(results.primaryAxisPlotMarkers.xMarkers[index].x, 0)
            let p2 = Point(results.primaryAxisPlotMarkers.xMarkers[index].x, plotDimensions.graphHeight)
            renderer.drawLine(startPoint: p1,
                              endPoint: p2,
                              strokeWidth: gridLineThickness,
                              strokeColor: gridColor,
                              isDashed: false,
                              isOriginShifted: true)
        }
    
        if (enablePrimaryAxisGrid) {
            for index in 0..<results.primaryAxisPlotMarkers.yMarkers.count {
                let p1 = Point(0, results.primaryAxisPlotMarkers.yMarkers[index].y)
                let p2 = Point(plotDimensions.graphWidth, results.primaryAxisPlotMarkers.yMarkers[index].y)
                renderer.drawLine(startPoint: p1,
                                  endPoint: p2,
                                  strokeWidth: gridLineThickness,
                                  strokeColor: gridColor,
                                  isDashed: false,
                                  isOriginShifted: true)
            }
        }
        if (enableSecondaryAxisGrid) {
            if let secondaryAxisMarkers = results.secondaryAxisPlotMarkers {
                for index in 0..<secondaryAxisMarkers.yMarkers.count {
                    let p1 = Point(0, secondaryAxisMarkers.yMarkers[index].y)
                    let p2 = Point(plotDimensions.graphWidth, secondaryAxisMarkers.yMarkers[index].y)
                    renderer.drawLine(startPoint: p1,
                                      endPoint: p2,
                                      strokeWidth: gridLineThickness,
                                      strokeColor: gridColor,
                                      isDashed: false,
                                      isOriginShifted: true)
                }
            }
        }
    }

    func drawMarkers(results: Results, renderer: Renderer) {
        for index in 0..<results.primaryAxisPlotMarkers.xMarkers.count {
            let p1 = Point(results.primaryAxisPlotMarkers.xMarkers[index].x, -6)
            let p2 = Point(results.primaryAxisPlotMarkers.xMarkers[index].x, 0)
            renderer.drawLine(startPoint: p1,
                              endPoint: p2,
                              strokeWidth: plotBorder.borderThickness,
                              strokeColor: Color.black,
                              isDashed: false,
                              isOriginShifted: true)
            renderer.drawText(text: results.primaryAxisPlotMarkers.xMarkersText[index],
                              location: results.primaryAxisPlotMarkers.xMarkersTextLocation[index],
                              textSize: markerTextSize,
                              strokeWidth: 0.7,
                              angle: 0,
                              isOriginShifted: true)
        }

        for index in 0..<results.primaryAxisPlotMarkers.yMarkers.count {
            let p1 = Point(-6, results.primaryAxisPlotMarkers.yMarkers[index].y)
            let p2 = Point(0, results.primaryAxisPlotMarkers.yMarkers[index].y)
            renderer.drawLine(startPoint: p1,
                              endPoint: p2,
                              strokeWidth: plotBorder.borderThickness,
                              strokeColor: Color.black,
                              isDashed: false,
                              isOriginShifted: true)
            renderer.drawText(text: results.primaryAxisPlotMarkers.yMarkersText[index],
                              location: results.primaryAxisPlotMarkers.yMarkersTextLocation[index],
                              textSize: markerTextSize,
                              strokeWidth: 0.7,
                              angle: 0,
                              isOriginShifted: true)
        }
        
        if let secondaryAxisMarkers = results.secondaryAxisPlotMarkers {
            for index in 0..<secondaryAxisMarkers.yMarkers.count {
                let p1 = Point(plotDimensions.graphWidth,
                               (secondaryAxisMarkers.yMarkers[index].y))
                let p2 = Point(plotDimensions.graphWidth + 6,
                               (secondaryAxisMarkers.yMarkers[index].y))
                renderer.drawLine(startPoint: p1,
                                  endPoint: p2,
                                  strokeWidth: plotBorder.borderThickness,
                                  strokeColor: Color.black,
                                  isDashed: false,
                                  isOriginShifted: true)
                renderer.drawText(text: secondaryAxisMarkers.yMarkersText[index],
                                  location: secondaryAxisMarkers.yMarkersTextLocation[index],
                                  textSize: secondaryAxisMarkers.markerTextSize,
                                  strokeWidth: 0.7,
                                  angle: 0,
                                  isOriginShifted: true)
            }
        }
    }
    
    func drawLegend(_ entries: [(String, LegendIcon)], results: Results, renderer: Renderer) {
        
        guard let legendRect = results.legendRect else { return }
        renderer.drawSolidRectWithBorder(legendRect,
                                         strokeWidth: plotBorder.borderThickness,
                                         fillColor: .transluscentWhite,
                                         borderColor: .black,
                                         isOriginShifted: false)
        
        for i in 0..<entries.count {
            let seriesIcon = Rect(
                origin: Point(legendRect.origin.x + plotLegend.legendTextSize,
                              legendRect.maxY - (2.0*Float(i) + 1.0)*plotLegend.legendTextSize),
                size: Size(width: plotLegend.legendTextSize, height: -plotLegend.legendTextSize)
            )
            switch entries[i].1 {
            case .square(let color):
                renderer.drawSolidRect(seriesIcon,
                                       fillColor: color,
                                       hatchPattern: .none,
                                       isOriginShifted: false)
            case .shape(let shape, let color):
                shape.draw(in: seriesIcon,
                           color: color,
                           renderer: renderer)
            }
            let p = Point(seriesIcon.maxX + plotLegend.legendTextSize, seriesIcon.minY)
            renderer.drawText(text: entries[i].0,
                              location: p,
                              textSize: plotLegend.legendTextSize,
                              strokeWidth: 1.2,
                              angle: 0,
                              isOriginShifted: false)
        }
    }
}

public protocol HasGraphLayout: AnyObject {
    
    var layout: GraphLayout { get set }
    
    var legendLabels: [(String, LegendIcon)] { get }
    
    func calculateScaleAndMarkerLocations(primaryMarkers: inout PlotMarkers,
                                          secondaryMarkers: inout PlotMarkers?,
                                          renderer: Renderer)
    
    func drawData(primaryMarkers: PlotMarkers, renderer: Renderer)
}

extension HasGraphLayout {
    public var plotTitle: PlotTitle? {
        get { layout.plotTitle }
        set { layout.plotTitle = newValue }
    }
    public var plotLabel: PlotLabel? {
        get { layout.plotLabel }
        set { layout.plotLabel = newValue }
    }
    public var plotLegend: PlotLegend {
        get { layout.plotLegend }
        set { layout.plotLegend = newValue }
    }
    //    public var plotBorder: PlotBorder {
    //        get { layout.plotBorder }
    //        set { layout.plotBorder = newValue }
    //    }
    public var plotDimensions: PlotDimensions {
        get { layout.plotDimensions }
        set { layout.plotDimensions = newValue }
    }
    public var gridColor: Color {
        get { layout.gridColor }
        set { layout.gridColor = newValue }
    }
    public var gridLineThickness: Float {
        get { layout.gridLineThickness }
        set { layout.gridLineThickness = newValue }
    }
    public var markerTextSize: Float {
        get { layout.markerTextSize }
        set { layout.markerTextSize = newValue }
    }
}

extension Plot where Self: HasGraphLayout {
    
    public func drawGraph(renderer: Renderer) {
        renderer.xOffset = xOffset
        renderer.yOffset = yOffset
        
        layout.legendLabels = self.legendLabels
        let results = layout.layout(renderer: renderer, calculateMarkers: { primary, secondary in
            calculateScaleAndMarkerLocations(primaryMarkers: &primary,
                                             secondaryMarkers: &secondary,
                                             renderer: renderer)
        })
        layout.drawBackground(results: results, renderer: renderer)
        drawData(primaryMarkers: results.primaryAxisPlotMarkers, renderer: renderer)
        layout.drawForeground(results: results, renderer: renderer)
    }
    
}
