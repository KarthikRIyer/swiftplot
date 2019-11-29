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
    }
    
    var plotTitle: PlotTitle? = nil
    var plotLabel: PlotLabel? = nil
    var plotLegend = PlotLegend()
    var plotBorder = PlotBorder()
    var grid = Grid()
    var legendLabels: [(String, LegendIcon)] = []
    
    var enablePrimaryAxisGrid = true
    var enableSecondaryAxisGrid = true
    var markerTextSize: Float = 12
    
    struct Results {
        var plotBorderRect: Rect?
        
        var xLabelLocation: Rect?
        var yLabelLocation: Rect?
        var titleLocation: Rect?
        
        var plotMarkers = PlotMarkers()
        var xMarkersTextLocation = [Point]()
        var yMarkersTextLocation = [Point]()
        var y2MarkersTextLocation = [Point]()
        
        var legendRect: Rect?
    }
    
//    public var graphWidth: Float { plotDimensions.subWidth * 0.8 }
//    public var graphHeight: Float { plotDimensions.subHeight * 0.8 }

    
    // Layout.
        
    func layout(renderer: Renderer, calculateMarkers: (inout PlotMarkers, Rect)->Void) -> Results {
        var results = Results()
        calcLabelLocations(renderer: renderer, results: &results)
        calcBorder(results: &results)

        calculateMarkers(&results.plotMarkers, results.plotBorderRect!)
        
        calcMarkerTextLocations(renderer: renderer, results: &results)
        calcLegend(legendLabels, renderer: renderer, results: &results)
        return results
    }
    
    func calcBorder(results: inout Results) {
        var borderRect = Rect(
            origin: zeroPoint,
            size: Size(width: plotDimensions.subWidth, height: plotDimensions.subHeight)
        )
        if let xLabel = results.xLabelLocation {
            borderRect.clampingShift(dy: xLabel.maxY + 10)
        }
        if let yLabel = results.yLabelLocation {
            borderRect.clampingShift(dx: yLabel.origin.x + 10)
        }
        if let titleLabel = results.titleLocation {
            borderRect.size.height = titleLabel.origin.y - borderRect.origin.y - 10
        }
        borderRect.contract(by: plotBorder.thickness)
        // Approximate space for the markers :S
        borderRect.contract(by: markerTextSize)
        borderRect.size.height += markerTextSize // no markers on the top.

        results.plotBorderRect = borderRect
    }

    func calcLabelLocations(renderer: Renderer, results: inout Results) {
        if let plotLabel = plotLabel {
            let xLabelSize = renderer.getTextLayoutSize(text: plotLabel.xLabel, textSize: plotLabel.size)
            let yLabelSize = renderer.getTextLayoutSize(text: plotLabel.yLabel, textSize: plotLabel.size)
            results.xLabelLocation = Rect(origin: Point(plotDimensions.subWidth/2 - xLabelSize.width/2, 10),
                                          size: xLabelSize)
            results.yLabelLocation = Rect(origin: Point(10 + xLabelSize.height,
                                                        plotDimensions.subHeight/2 - yLabelSize.width/2),
                                          size: yLabelSize)
        }
        if let plotTitle = plotTitle {
          let titleSize = renderer.getTextLayoutSize(text: plotTitle.title, textSize: plotTitle.size)
          results.titleLocation = Rect(origin: Point(
            plotDimensions.subWidth/2 - titleSize.width/2,
            plotDimensions.subHeight  - titleSize.height - 10
          ), size: titleSize)
        }
    }
    
    func calcMarkerTextLocations(renderer: Renderer, results: inout Results) {
        
        for i in 0..<results.plotMarkers.xMarkers.count {
            let textWidth = renderer.getTextWidth(text: results.plotMarkers.xMarkersText[i], textSize: markerTextSize)
            let text_p = Point(
                results.plotMarkers.xMarkers[i] - (textWidth/2),
                -2.0 * markerTextSize
            )
            results.xMarkersTextLocation.append(text_p)
        }
        
        for i in 0..<results.plotMarkers.yMarkers.count {
            let text_p = Point(
                -(renderer.getTextWidth(text: results.plotMarkers.yMarkersText[i], textSize: markerTextSize)+8),
                results.plotMarkers.yMarkers[i] - 4
            )
            results.yMarkersTextLocation.append(text_p)
        }
        
        for i in 0..<results.plotMarkers.y2Markers.count {
            let text_p = Point(
                results.plotBorderRect!.width + 8,
                results.plotMarkers.y2Markers[i] - 4
            )
            results.y2MarkersTextLocation.append(text_p)
        }
    }
    
    func calcLegend(_ labels: [(String, LegendIcon)], renderer: Renderer, results: inout Results) {
        guard !labels.isEmpty else { return }
        let maxWidth = labels.lazy.map {
            renderer.getTextWidth(text: $0.0, textSize: self.plotLegend.textSize)
        }.max() ?? 0
        
        let legendWidth  = maxWidth + 3.5 * plotLegend.textSize
        let legendHeight = (Float(labels.count)*2.0 + 1.0) * plotLegend.textSize
        
        let legendTopLeft = Point(results.plotBorderRect!.minX + Float(20),
                                  results.plotBorderRect!.maxY - Float(20))
        results.legendRect = Rect(
            origin: legendTopLeft,
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
                          location: location.origin,
                          textSize: plotTitle.size,
                          color: plotTitle.color,
                          strokeWidth: 1.2,
                          angle: 0,
                          isOriginShifted: false)
    }

    func drawLabels(results: Results, renderer: Renderer) {
        guard let plotLabel = self.plotLabel else { return }
        if let xLocation = results.xLabelLocation {
            renderer.drawText(text: plotLabel.xLabel,
                              location: xLocation.origin,
                              textSize: plotLabel.size,
                              color: plotLabel.color,
                              strokeWidth: 1.2,
                              angle: 0,
                              isOriginShifted: false)
        }
        if let yLocation = results.yLabelLocation {
            renderer.drawText(text: plotLabel.yLabel,
                              location: yLocation.origin,
                              textSize: plotLabel.size,
                              color: plotLabel.color,
                              strokeWidth: 1.2,
                              angle: 90,
                              isOriginShifted: false)
        }
    }
    
    func drawBorder(results: Results, renderer: Renderer) {
        guard let borderRect = results.plotBorderRect else { return }
        renderer.drawRect(borderRect,
                          strokeWidth: plotBorder.thickness,
                          strokeColor: plotBorder.color, isOriginShifted: false)
    }
    
    func drawGrid(results: Results, renderer: Renderer) {
        guard enablePrimaryAxisGrid || enablePrimaryAxisGrid,
            let rect = results.plotBorderRect else { return }
        
        for index in 0..<results.plotMarkers.xMarkers.count {
            let p1 = Point(results.plotMarkers.xMarkers[index] + rect.minX, rect.minY)
            let p2 = Point(results.plotMarkers.xMarkers[index] + rect.minX, rect.maxY)
            renderer.drawLine(startPoint: p1,
                              endPoint: p2,
                              strokeWidth: grid.thickness,
                              strokeColor: grid.color,
                              isDashed: false,
                              isOriginShifted: false)
        }
    
        if (enablePrimaryAxisGrid) {
            for index in 0..<results.plotMarkers.yMarkers.count {
                let p1 = Point(rect.minX, results.plotMarkers.yMarkers[index] + rect.minY)
                let p2 = Point(rect.maxX, results.plotMarkers.yMarkers[index] + rect.minY)
                renderer.drawLine(startPoint: p1,
                                  endPoint: p2,
                                  strokeWidth: grid.thickness,
                                  strokeColor: grid.color,
                                  isDashed: false,
                                  isOriginShifted: false)
            }
        }
        if (enableSecondaryAxisGrid) {
            for index in 0..<results.plotMarkers.y2Markers.count {
                let p1 = Point(rect.minX, results.plotMarkers.y2Markers[index] + rect.minY)
                let p2 = Point(rect.maxX, results.plotMarkers.y2Markers[index] + rect.minY)
                renderer.drawLine(startPoint: p1,
                                  endPoint: p2,
                                  strokeWidth: grid.thickness,
                                  strokeColor: grid.color,
                                  isDashed: false,
                                  isOriginShifted: false)
            }
        }
    }

    func drawMarkers(results: Results, renderer: Renderer) {
        guard let rect = results.plotBorderRect else { return }
        for index in 0..<results.plotMarkers.xMarkers.count {
            let p1 = Point(results.plotMarkers.xMarkers[index], -6) + rect.origin
            let p2 = Point(results.plotMarkers.xMarkers[index], 0) + rect.origin
            renderer.drawLine(startPoint: p1,
                              endPoint: p2,
                              strokeWidth: plotBorder.thickness,
                              strokeColor: plotBorder.color,
                              isDashed: false,
                              isOriginShifted: false)
            renderer.drawText(text: results.plotMarkers.xMarkersText[index],
                              location: results.xMarkersTextLocation[index] + rect.origin,
                              textSize: markerTextSize,
                              color: plotBorder.color,
                              strokeWidth: 0.7,
                              angle: 0,
                              isOriginShifted: false)
        }

        for index in 0..<results.plotMarkers.yMarkers.count {
            let p1 = Point(-6, results.plotMarkers.yMarkers[index]) + rect.origin
            let p2 = Point(0, results.plotMarkers.yMarkers[index]) + rect.origin
            renderer.drawLine(startPoint: p1,
                              endPoint: p2,
                              strokeWidth: plotBorder.thickness,
                              strokeColor: plotBorder.color,
                              isDashed: false,
                              isOriginShifted: false)
            renderer.drawText(text: results.plotMarkers.yMarkersText[index],
                              location: results.yMarkersTextLocation[index]  + rect.origin,
                              textSize: markerTextSize,
                              color: plotBorder.color,
                              strokeWidth: 0.7,
                              angle: 0,
                              isOriginShifted: false)
        }
        
        if !results.plotMarkers.y2Markers.isEmpty {
            for index in 0..<results.plotMarkers.y2Markers.count {
                let p1 = Point(results.plotBorderRect!.width,
                               (results.plotMarkers.y2Markers[index])) + rect.origin
                let p2 = Point(results.plotBorderRect!.width + 6,
                               (results.plotMarkers.y2Markers[index])) + rect.origin
                renderer.drawLine(startPoint: p1,
                                  endPoint: p2,
                                  strokeWidth: plotBorder.thickness,
                                  strokeColor: plotBorder.color,
                                  isDashed: false,
                                  isOriginShifted: false)
                renderer.drawText(text: results.plotMarkers.y2MarkersText[index],
                                  location: results.y2MarkersTextLocation[index]  + rect.origin,
                                  textSize: markerTextSize,
                                  color: plotBorder.color,
                                  strokeWidth: 0.7,
                                  angle: 0,
                                  isOriginShifted: false)
            }
        }
    }
    
    func drawLegend(_ entries: [(String, LegendIcon)], results: Results, renderer: Renderer) {
        
        guard let legendRect = results.legendRect else { return }
        renderer.drawSolidRectWithBorder(legendRect,
                                         strokeWidth: plotLegend.borderThickness,
                                         fillColor: plotLegend.backgroundColor,
                                         borderColor: plotLegend.borderColor,
                                         isOriginShifted: false)
        
        for i in 0..<entries.count {
            let seriesIcon = Rect(
                origin: Point(legendRect.origin.x + plotLegend.textSize,
                              legendRect.maxY - (2.0*Float(i) + 1.0)*plotLegend.textSize),
                size: Size(width: plotLegend.textSize, height: -plotLegend.textSize)
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
            let p = Point(seriesIcon.maxX + plotLegend.textSize, seriesIcon.minY)
            renderer.drawText(text: entries[i].0,
                              location: p,
                              textSize: plotLegend.textSize,
                              color: plotLegend.textColor,
                              strokeWidth: 1.2,
                              angle: 0,
                              isOriginShifted: false)
        }
    }
}

public protocol HasGraphLayout: AnyObject {
    
    var layout: GraphLayout { get set }
    
    var legendLabels: [(String, LegendIcon)] { get }
    
    func calculateScaleAndMarkerLocations(markers: inout PlotMarkers, rect: Rect, renderer: Renderer)
    
    func drawData(markers: PlotMarkers, renderer: Renderer)
}

extension HasGraphLayout {
    
    public var plotDimensions: PlotDimensions {
        get { layout.plotDimensions }
        set { layout.plotDimensions = newValue }
    }
    
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
    public var plotBorder: PlotBorder {
        get { layout.plotBorder }
        set { layout.plotBorder = newValue }
    }
    public var grid: Grid {
        get { layout.grid }
        set { layout.grid = newValue }
    }

    public var markerTextSize: Float {
        get { layout.markerTextSize }
        set { layout.markerTextSize = newValue }
    }
}

extension Plot where Self: HasGraphLayout {
    
    public func drawGraph(renderer: Renderer) {
        layout.legendLabels = self.legendLabels
        let results = layout.layout(renderer: renderer, calculateMarkers: { markers, rect in
            calculateScaleAndMarkerLocations(
                markers: &markers,
                rect: rect,
                renderer: renderer)
        })
        layout.drawBackground(results: results, renderer: renderer)
        renderer.withOffset(results.plotBorderRect!.origin) { renderer in
            drawData(markers: results.plotMarkers, renderer: renderer)
        }
        layout.drawForeground(results: results, renderer: renderer)
    }
    
}

extension Renderer {
    func withOffset(_ offset: Point, _ perform: (Renderer)->Void) {
        let oldOffset = (self.xOffset, self.yOffset)
        (self.xOffset, self.yOffset) = (oldOffset.0 + offset.x, oldOffset.1 + offset.y)
        perform(self)
        (self.xOffset, self.yOffset) = oldOffset
    }
}
