import Foundation

// class defining a barGraph and all it's logic
public class BarGraph<T:LosslessStringConvertible,U:FloatConvertible>: Plot {

    let MAX_DIV: Float = 50

    public var xOffset: Float = 0
    public var yOffset: Float = 0

    public var layout: GraphLayout
    
    public enum GraphOrientation {
        case vertical
        case horizontal
    }
    public var graphOrientation: GraphOrientation = .vertical
    public var space: Int = 20
    
    var scaleY: Float = 1
    var scaleX: Float = 1

    var series = Series<T,U>()
    var stackSeries = [Series<T,U>]()
    var barWidth : Int = 0
    var origin = zeroPoint

    public init(width: Float = 1000,
                height: Float = 660,
                enableGrid: Bool = false){
        layout = GraphLayout(plotDimensions: PlotDimensions(frameWidth: width, frameHeight: height))
        self.enableGrid = enableGrid
    }
    
    public var enableGrid: Bool {
        get { layout.enablePrimaryAxisGrid }
        set { layout.enablePrimaryAxisGrid = newValue }
    }
    
    public func addSeries(_ s: Series<T,U>){
        series = s
    }
    public func addStackSeries(_ s: Series<T,U>) {
        if (series.count != 0 && series.count == s.count) {
            stackSeries.append(s)
        }
        else {
            print("Stack point count does not match the Series point count.")
        }
    }
    public func addStackSeries(_ x: [U],
                               label: String,
                               color: Color = .lightBlue,
                               hatchPattern: BarGraphSeriesOptions.Hatching = .none) {
        var values = [Pair<T,U>]()
        for i in 0..<x.count {
            values.append(Pair<T,U>(series.values[i].x, x[i]))
        }
        let s = Series<T,U>(values: values,
                            label: label,
                            color: color,
                            hatchPattern: hatchPattern)
        addStackSeries(s)
    }
    public func addSeries(values: [Pair<T,U>],
                          label: String,
                          color: Color = Color.lightBlue,
                          hatchPattern: BarGraphSeriesOptions.Hatching = .none,
                          graphOrientation: BarGraph.GraphOrientation = .vertical){
        let s = Series<T,U>(values: values,
                            label: label,
                            color: color,
                            hatchPattern: hatchPattern)
        addSeries(s)
        self.graphOrientation = graphOrientation
    }
    public func addSeries(_ x: [T],
                          _ y: [U],
                          label: String,
                          color: Color = Color.lightBlue,
                          hatchPattern: BarGraphSeriesOptions.Hatching = .none,
                          graphOrientation: BarGraph.GraphOrientation = .vertical){
        var values = [Pair<T,U>]()
        for i in 0..<x.count {
            values.append(Pair<T,U>(x[i], y[i]))
        }
        let s = Series<T,U>(values: values,
                            label: label,
                            color: color,
                            hatchPattern: hatchPattern)
        addSeries(s)
        self.graphOrientation = graphOrientation
    }
}

// extension containing drawing logic
extension BarGraph: HasGraphLayout {
    
    public var legendLabels: [(String, LegendIcon)] {
        var legendSeries = stackSeries.map { ($0.label, LegendIcon.square($0.color)) }
        legendSeries.insert((series.label, .square(series.color)), at: 0)
        return legendSeries
    }
    
    // functions implementing plotting logic
    public func calculateScaleAndMarkerLocations(primaryMarkers: inout PlotMarkers, secondaryMarkers: inout PlotMarkers?, renderer: Renderer) {
    
        var maximumY: U = U(0)
        var minimumY: U = U(0)
        var maximumX: U = U(0)
        var minimumX: U = U(0)

        if (graphOrientation == .vertical) {
            barWidth = Int(round(plotDimensions.graphWidth/Float(series.count)))
            maximumY = maxY(points: series.values)
            minimumY = minY(points: series.values)
        }
        else{
            barWidth = Int(round(plotDimensions.graphHeight/Float(series.count)))
            maximumX = maxY(points: series.values)
            minimumX = minY(points: series.values)
        }

        if (graphOrientation == .vertical) {
            for s in stackSeries {
                let minStackY = minY(points: s.values)
                let maxStackY = maxY(points: s.values)

                if (maxStackY > U(0)) {
                    maximumY = maximumY + maxStackY
                }
                if (minStackY < U(0)) {
                    minimumY = minimumY + minStackY
                }

            }

            if (minimumY >= U(0)) {
                origin = zeroPoint
                minimumY = U(0)
            }
            else{
                origin = Point(0.0,
                               (plotDimensions.graphHeight/Float(maximumY-minimumY))*Float(U(-1)*minimumY))
            }

            let topScaleMargin: Float = (plotDimensions.subHeight - plotDimensions.graphHeight)*Float(0.5) - 10.0;
            scaleY = Float(maximumY - minimumY) / (plotDimensions.graphHeight - topScaleMargin);

            let nD1: Int = max(getNumberOfDigits(Float(maximumY)), getNumberOfDigits(Float(minimumY)))
            var v1: Float
            if (nD1 > 1 && maximumY <= U(pow(Float(10), Float(nD1 - 1)))) {
                v1 = Float(pow(Float(10), Float(nD1 - 2)))
            } else if (nD1 > 1) {
                v1 = Float(pow(Float(10), Float(nD1 - 1)))
            } else {
                v1 = Float(pow(Float(10), Float(0)))
            }

            let nY: Float = v1/scaleY
            var inc1: Float = nY
            if(plotDimensions.graphHeight/nY > MAX_DIV){
                inc1 = (plotDimensions.graphHeight/nY)*inc1/MAX_DIV
            }

            var yM = Float(origin.y)
            while yM<=plotDimensions.graphHeight {
                if(yM+inc1<0.0 || yM<0.0){
                    yM = yM + inc1
                    continue
                }
                let p = Point(0, yM)
                primaryMarkers.yMarkers.append(p)
                let text_p = Point(-(renderer.getTextWidth(text: "\(ceil(scaleY*(yM-origin.y)))",
                                                           textSize: layout.markerTextSize)+8), yM - 4)
                primaryMarkers.yMarkersTextLocation.append(text_p)
                primaryMarkers.yMarkersText.append("\(round(scaleY*(yM-origin.y)))")
                yM = yM + inc1
            }
            yM = origin.y - inc1
            while yM>0.0 {
                let p = Point(0, yM)
                primaryMarkers.yMarkers.append(p)
                let text_p = Point(-(renderer.getTextWidth(text: "\(floor(scaleY*(yM-origin.y)))",
                                                           textSize: layout.markerTextSize)+8), yM - 4)
                primaryMarkers.yMarkersTextLocation.append(text_p)
                primaryMarkers.yMarkersText.append("\(round(scaleY*(yM-origin.y)))")
                yM = yM - inc1
            }

            for i in 0..<series.count {
                let p = Point(Float(i*barWidth) + Float(barWidth)*Float(0.5), 0)
                primaryMarkers.xMarkers.append(p)
                let bW: Int = barWidth*(i+1)
                let textWidth: Float = renderer.getTextWidth(text: "\(series[i].x)",
                                                             textSize: layout.markerTextSize)
                let text_p = Point(Float(bW) - textWidth*Float(0.5) - Float(barWidth)*Float(0.5),
                                                                     -2.0*layout.markerTextSize)
                primaryMarkers.xMarkersTextLocation.append(text_p)
                primaryMarkers.xMarkersText.append("\(series[i].x)")
            }

            // scale points to be plotted according to plot size
            let scaleYInv: Float = 1.0/scaleY
            series.scaledValues.removeAll();
            for j in 0..<series.count {
                let scaledPair = Pair<T,U>(series[j].x,
                                           series[j].y*U(scaleYInv) + U(origin.y))
                series.scaledValues.append(scaledPair)
            }
            for index in 0..<stackSeries.count {
                stackSeries[index].scaledValues.removeAll()
                for j in 0..<(stackSeries[index]).count {
                    let scaledPair = Pair<T,U>((stackSeries[index])[j].x,
                                               ((stackSeries[index])[j].y)*U(scaleYInv)+U(origin.y))
                    stackSeries[index].scaledValues.append(scaledPair)
                }
            }
        }

        else{
            var x = maxY(points: series.values)
            if (x > maximumX) {
                maximumX = x
            }
            x = minY(points: series.values)
            if (x < minimumX) {
                minimumX = x
            }

            for s in stackSeries {
                let minStackX = minY(points: s.values)
                let maxStackX = maxY(points: s.values)
                maximumX = maximumX + maxStackX
                minimumX = minimumX - minStackX
            }

            if minimumX >= U(0) {
                origin = zeroPoint
                minimumX = U(0)
            }
            else{
                origin = Point((plotDimensions.graphWidth/Float(maximumX-minimumX))*Float(U(-1)*minimumX), 0.0)
            }

            let rightScaleMargin: Float = (plotDimensions.subWidth - plotDimensions.graphWidth)*Float(0.5) - 10.0
            scaleX = Float(maximumX - minimumX) / (plotDimensions.graphWidth - rightScaleMargin)

            let nD1: Int = max(getNumberOfDigits(Float(maximumX)), getNumberOfDigits(Float(minimumX)))
            var v1: Float
            if (nD1 > 1 && maximumX <= U(pow(Float(10), Float(nD1 - 1)))) {
                v1 = Float(pow(Float(10), Float(nD1 - 2)))
            } else if (nD1 > 1) {
                v1 = Float(pow(Float(10), Float(nD1 - 1)))
            } else {
                v1 = Float(pow(Float(10), Float(0)))
            }

            let nX: Float = v1/scaleX
            var inc1: Float = nX
            if(plotDimensions.graphWidth/nX > MAX_DIV){
                inc1 = (plotDimensions.graphWidth/nX)*inc1/MAX_DIV
            }

            var xM = origin.x
            while xM<=plotDimensions.graphWidth {
                if(xM+inc1<0.0 || xM<0.0){
                    xM = xM + inc1
                    continue
                }
                let p = Point(xM, 0)
                primaryMarkers.xMarkers.append(p)
                let text_p = Point(xM - (renderer.getTextWidth(text: "\(floor(scaleX*(xM-origin.x)))",
                                                               textSize: layout.markerTextSize)*Float(0.5)) + 8,
                                   -20)
                primaryMarkers.xMarkersTextLocation.append(text_p)
                primaryMarkers.xMarkersText.append("\(ceil(scaleX*(xM-origin.x)))")
                xM = xM + inc1
            }
            xM = origin.x - inc1
            while xM>0.0 {
                let p = Point(xM, 0)
                primaryMarkers.xMarkers.append(p)
                let text_p = Point(xM - (renderer.getTextWidth(text: "\(floor(scaleX*(xM-origin.x)))",
                                                               textSize: layout.markerTextSize)*Float(0.5)) + 8,
                                   -20)
                primaryMarkers.xMarkersTextLocation.append(text_p)
                primaryMarkers.xMarkersText.append("\(floor(scaleX*(xM-origin.x)))")
                xM = xM - inc1
            }

            for i in 0..<series.count {
                let p = Point(0, Float(i*barWidth) + Float(barWidth)*Float(0.5))
                primaryMarkers.yMarkers.append(p)
                let bW: Int = barWidth*(i+1)
                let textWidth: Float = renderer.getTextWidth(text: "\(series[i].x)", textSize: layout.markerTextSize)
                let text_p = Point(-1.2*textWidth,
                                   Float(bW)
                                   - layout.markerTextSize/2
                                   - Float(barWidth)*Float(0.5))
                primaryMarkers.yMarkersTextLocation.append(text_p)
                primaryMarkers.yMarkersText.append("\(series[i].x)")
            }

            // scale points to be plotted according to plot size
            let scaleXInv: Float = 1.0/scaleX
            series.scaledValues.removeAll();
            for j in 0..<series.count {
                let scaledPair = Pair<T,U>(series[j].x,
                                           series[j].y*U(scaleXInv)+U(origin.x))
                series.scaledValues.append(scaledPair)
            }
            for index in 0..<stackSeries.count {
                stackSeries[index].scaledValues.removeAll()
                for j in 0..<(stackSeries[index]).count {
                    let scaledPair = Pair<T,U>((stackSeries[index])[j].x,
                                                (stackSeries[index])[j].y*U(scaleXInv)+U(origin.x))
                    stackSeries[index].scaledValues.append(scaledPair)
                }
            }
        }

    }

    //functions to draw the plot
    public func drawData(primaryMarkers: PlotMarkers, renderer: Renderer) {
        if (graphOrientation == .vertical) {
            for index in 0..<series.count {
                var currentHeightPositive: Float = 0
                var currentHeightNegative: Float = 0
                var rect = Rect(
                    origin: Point(
                        primaryMarkers.xMarkers[index].x-Float(barWidth)*Float(0.5)+Float(space)*Float(0.5),
                        origin.y),
                    size: Size(
                        width: Float(barWidth - space),
                        height: Float(series.scaledValues[index].y) - origin.y)
                )
                if (rect.size.height >= 0) {
                    currentHeightPositive = rect.size.height
                }
                else {
                    currentHeightNegative = rect.size.height
                }
                renderer.drawSolidRect(rect,
                                       fillColor: series.color,
                                       hatchPattern: series.barGraphSeriesOptions.hatchPattern,
                                       isOriginShifted: true)
                for s in stackSeries {
                    let stackValue = Float(s.scaledValues[index].y)
                    if (stackValue - origin.y >= 0) {
                        rect.origin.y = origin.y + currentHeightPositive
                        rect.size.height = stackValue - origin.y
                        currentHeightPositive += stackValue
                    }
                    else {
                        rect.origin.y = origin.y - currentHeightNegative - stackValue
                        rect.size.height = stackValue - origin.y
                        currentHeightNegative += stackValue
                    }
                    renderer.drawSolidRect(rect,
                                           fillColor: s.color,
                                           hatchPattern: s.barGraphSeriesOptions.hatchPattern,
                                           isOriginShifted: true)
                }
            }
        }
        else {
            for index in 0..<series.count {
                var currentWidthPositive: Float = 0
                var currentWidthNegative: Float = 0
                var rect = Rect(
                    origin: Point(origin.x, primaryMarkers.yMarkers[index].y-Float(barWidth)*Float(0.5)+Float(space)*Float(0.5)),
                    size: Size(
                        width: Float(series.scaledValues[index].y) - origin.x,
                        height: Float(barWidth - space))
                )
                if (rect.size.width >= 0) {
                    currentWidthPositive = rect.size.width
                }
                else {
                    currentWidthNegative = rect.size.width
                }
                renderer.drawSolidRect(rect,
                                       fillColor: series.color,
                                       hatchPattern: series.barGraphSeriesOptions.hatchPattern,
                                       isOriginShifted: true)
                for s in stackSeries {
                    let stackValue = Float(s.scaledValues[index].y)
                    if (stackValue - origin.x >= 0) {
                        rect.origin.x = origin.x + currentWidthPositive
                        rect.size.width = stackValue - origin.x
                        currentWidthPositive += stackValue
                    }
                    else {
                        rect.origin.x = origin.x - currentWidthNegative - stackValue
                        rect.size.width = stackValue - origin.x
                        currentWidthNegative += stackValue
                    }
                    renderer.drawSolidRect(rect,
                                           fillColor: s.color,
                                           hatchPattern: s.barGraphSeriesOptions.hatchPattern,
                                           isOriginShifted: true)
                }
            }
        }
    }
}
