import Foundation

fileprivate let MAX_DIV: Float = 50

// class defining a barGraph and all it's logic
public struct BarGraph<T:LosslessStringConvertible,U:FloatConvertible>: Plot {

    public var layout = GraphLayout()
    // Data.
    var series = Series<T,U>()
    var stackSeries = [Series<T,U>]()
    // BarGraph layout properties.
    public enum GraphOrientation {
        case vertical
        case horizontal
    }
    public var graphOrientation: GraphOrientation = .vertical
    public var space: Int = 20

    public init(enableGrid: Bool = false){
        self.enableGrid = enableGrid
    }
}

// Setting data.

extension BarGraph {

    public mutating func addSeries(_ s: Series<T,U>){
        series = s
    }

    public mutating func addStackSeries(_ s: Series<T,U>) {
        precondition(series.count != 0 && series.count == s.count,
                     "Stack point count does not match the Series point count.")
        stackSeries.append(s)
    }
    public mutating func addStackSeries(_ x: [U],
                               label: String,
                               color: Color = .lightBlue,
                               hatchPattern: BarGraphSeriesOptions.Hatching = .none) {
        let s = Series<T,U>(values: (0..<x.count).map { i in Pair(series.values[i].x, x[i]) },
                            label: label,
                            color: color,
                            hatchPattern: hatchPattern)
        addStackSeries(s)
    }
    public mutating func addSeries(values: [Pair<T,U>],
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
    public mutating func addSeries(_ x: [T],
                          _ y: [U],
                          label: String,
                          color: Color = Color.lightBlue,
                          hatchPattern: BarGraphSeriesOptions.Hatching = .none,
                          graphOrientation: BarGraph.GraphOrientation = .vertical){
        self.addSeries(values: zip(x, y).map { Pair($0.0, $0.1) },
                       label: label, color: color, hatchPattern: hatchPattern,
                       graphOrientation: graphOrientation)
    }
}

// Layout properties.

extension BarGraph {

    public var enableGrid: Bool {
        get { layout.enablePrimaryAxisGrid }
        set { layout.enablePrimaryAxisGrid = newValue }
    }
}

// Layout and drawing of data.

extension BarGraph: HasGraphLayout {

    public var legendLabels: [(String, LegendIcon)] {
        var legendSeries = stackSeries.map { ($0.label, LegendIcon.square($0.color)) }
        legendSeries.insert((series.label, .square(series.color)), at: 0)
        return legendSeries
    }

    public struct DrawingData {
        var series_scaledValues = [Pair<Float,Float>]()
        var stackSeries_scaledValues = [[Pair<Float,Float>]]()
        var scaleY: Float = 1
        var scaleX: Float = 1
        var barWidth : Int = 0
        var origin = zeroPoint
    }

    // functions implementing plotting logic
    public func layoutData(size: Size, renderer: Renderer) -> (DrawingData, PlotMarkers?) {

        var results = DrawingData()
        var markers = PlotMarkers()

        var maximumY: U = U(0)
        var minimumY: U = U(0)
        var maximumX: U = U(0)
        var minimumX: U = U(0)

        guard series.count > 0 else { return (results, markers) }
        if (graphOrientation == .vertical) {
            results.barWidth = Int(round(size.width/Float(series.count)))
            maximumY = maxY(points: series.values)
            minimumY = minY(points: series.values)
        }
        else{
            results.barWidth = Int(round(size.height/Float(series.count)))
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
                results.origin = zeroPoint
                minimumY = U(0)
            }
            else{
                results.origin = Point(0.0,
                               (size.height/Float(maximumY-minimumY))*Float(U(-1)*minimumY))
            }

            let topScaleMargin: Float = size.height * 0.1
            results.scaleY = Float(maximumY - minimumY) / (size.height - topScaleMargin);

            let nD1: Int = max(getNumberOfDigits(Float(maximumY)), getNumberOfDigits(Float(minimumY)))
            var v1: Float
            if (nD1 > 1 && maximumY <= U(pow(Float(10), Float(nD1 - 1)))) {
                v1 = Float(pow(Float(10), Float(nD1 - 2)))
            } else if (nD1 > 1) {
                v1 = Float(pow(Float(10), Float(nD1 - 1)))
            } else {
                v1 = Float(pow(Float(10), Float(0)))
            }

            let nY: Float = v1/results.scaleY
            var inc1: Float = nY
            if(size.height/nY > MAX_DIV){
                inc1 = (size.height/nY)*inc1/MAX_DIV
            }

            var yM = Float(results.origin.y)
            while yM<=size.height {
                if(yM+inc1<0.0 || yM<0.0){
                    yM = yM + inc1
                    continue
                }
                markers.yMarkers.append(yM)
                markers.yMarkersText.append("\(round(results.scaleY*(yM-results.origin.y)))")
                yM = yM + inc1
            }
            yM = results.origin.y - inc1
            while yM>0.0 {
                markers.yMarkers.append(yM)
                markers.yMarkersText.append("\(round(results.scaleY*(yM-results.origin.y)))")
                yM = yM - inc1
            }

            func xMarkerLocationForBar(_ index: Int) -> Float {
                Float(index*results.barWidth) + Float(results.barWidth)*Float(0.5)
            }
            func xLocationForBar(_ index: Int) -> Float {
                xMarkerLocationForBar(index) - Float(results.barWidth)*Float(0.5) + Float(space)*Float(0.5)
            }

            for i in 0..<series.count {
                markers.xMarkers.append(xMarkerLocationForBar(i))
                markers.xMarkersText.append("\(series[i].x)")
            }

            // scale points to be plotted according to plot size
            let scaleYInv: Float = 1.0/results.scaleY
            results.series_scaledValues = (0..<series.values.count).map { i in
                let pt = series.values[i]
                return Pair(xLocationForBar(i),
                            Float(pt.y*U(scaleYInv) + U(results.origin.y)))
            }
            results.stackSeries_scaledValues = stackSeries.map { series in
                (0..<series.values.count).map { i in
                    let pt = series[i]
                    return Pair(xLocationForBar(i),
                                Float((pt.y)*U(scaleYInv)+U(results.origin.y)))
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
                results.origin = zeroPoint
                minimumX = U(0)
            }
            else{
                results.origin = Point((size.width/Float(maximumX-minimumX))*Float(U(-1)*minimumX), 0.0)
            }

            let rightScaleMargin: Float = size.width * 0.1
            results.scaleX = Float(maximumX - minimumX) / (size.width - rightScaleMargin)

            let nD1: Int = max(getNumberOfDigits(Float(maximumX)), getNumberOfDigits(Float(minimumX)))
            var v1: Float
            if (nD1 > 1 && maximumX <= U(pow(Float(10), Float(nD1 - 1)))) {
                v1 = Float(pow(Float(10), Float(nD1 - 2)))
            } else if (nD1 > 1) {
                v1 = Float(pow(Float(10), Float(nD1 - 1)))
            } else {
                v1 = Float(pow(Float(10), Float(0)))
            }

            let nX: Float = v1/results.scaleX
            var inc1: Float = nX
            if(size.width/nX > MAX_DIV){
                inc1 = (size.width/nX)*inc1/MAX_DIV
            }

            var xM = results.origin.x
            while xM<=size.width {
                if(xM+inc1<0.0 || xM<0.0){
                    xM = xM + inc1
                    continue
                }
                markers.xMarkers.append(xM)
                markers.xMarkersText.append("\(ceil(results.scaleX*(xM-results.origin.x)))")
                xM = xM + inc1
            }
            xM = results.origin.x - inc1
            while xM>0.0 {
                markers.xMarkers.append(xM)
                markers.xMarkersText.append("\(floor(results.scaleX*(xM-results.origin.x)))")
                xM = xM - inc1
            }

            func yMarkerLocationForBar(_ index: Int) -> Float {
                Float(index*results.barWidth) + Float(results.barWidth)*Float(0.5)
            }
            func yLocationForBar(_ index: Int) -> Float {
                yMarkerLocationForBar(index) - Float(results.barWidth)*Float(0.5) + Float(space)*Float(0.5)
            }
            for i in 0..<series.count {
                markers.yMarkers.append(yMarkerLocationForBar(i))
                markers.yMarkersText.append("\(series[i].x)")
            }

            // scale points to be plotted according to plot size
            let scaleXInv: Float = 1.0/results.scaleX
            results.series_scaledValues = (0..<series.values.count).map { i in
                let pt = series.values[i]
                return Pair(Float(pt.y*U(scaleXInv)+U(results.origin.x)), yLocationForBar(i))
            }
            results.stackSeries_scaledValues = stackSeries.map { series in
                (0..<series.values.count).map { i in
                    let pt = series.values[i]
                    return Pair(Float(pt.y*U(scaleXInv)+U(results.origin.x)), yLocationForBar(i))
                }
            }
        }
        return (results, markers)
    }

    //functions to draw the plot
    public func drawData(_ data: DrawingData, size: Size, renderer: Renderer) {
        if (graphOrientation == .vertical) {
            for index in 0..<data.series_scaledValues.count {
                var currentHeightPositive: Float = 0
                var currentHeightNegative: Float = 0
                var rect = Rect(
                    origin: Point(data.series_scaledValues[index].x, data.origin.y),
                    size: Size(
                        width: Float(data.barWidth - space),
                        height: data.series_scaledValues[index].y - data.origin.y)
                )
                if (rect.size.height >= 0) {
                    currentHeightPositive = rect.size.height
                }
                else {
                    currentHeightNegative = rect.size.height
                }
                renderer.drawSolidRectWithBorder(rect,
                                       strokeWidth: 2.0,
                                       fillColor: series.color,
                                       borderColor: series.color,
                                       hatchPattern: stackSeries[i].barGraphSeriesOptions.hatchPattern)
                for i in 0..<data.stackSeries_scaledValues.count {
                    let stackValue = Float(data.stackSeries_scaledValues[i][index].y)
                    if (stackValue - data.origin.y >= 0) {
                        rect.origin.y = data.origin.y + currentHeightPositive
                        rect.size.height = stackValue - data.origin.y
                        currentHeightPositive += stackValue
                    }
                    else {
                        rect.origin.y = data.origin.y - currentHeightNegative - stackValue
                        rect.size.height = stackValue - data.origin.y
                        currentHeightNegative += stackValue
                    }
                renderer.drawSolidRectWithBorder(rect,
                                       strokeWidth: 2.0,
                                       fillColor: series.color,
                                       borderColor: series.color,
                                       hatchPattern: stackSeries[i].barGraphSeriesOptions.hatchPattern)
                }
            }
        }
        else {
            for index in 0..<series.count {
                var currentWidthPositive: Float = 0
                var currentWidthNegative: Float = 0
                var rect = Rect(
                    origin: Point(data.origin.x, data.series_scaledValues[index].y),
                    size: Size(
                        width: data.series_scaledValues[index].x - data.origin.x,
                        height: Float(data.barWidth - space))
                )
                if (rect.size.width >= 0) {
                    currentWidthPositive = rect.size.width
                }
                else {
                    currentWidthNegative = rect.size.width
                }
                renderer.drawSolidRectWithBorder(rect,
                                       strokeWidth: 2.0,
                                       fillColor: series.color,
                                       borderColor: series.color,
                                       hatchPattern: stackSeries[i].barGraphSeriesOptions.hatchPattern)
                for i in 0..<stackSeries.count {
                    let stackValue = Float(data.stackSeries_scaledValues[i][index].x)
                    if (stackValue - data.origin.x >= 0) {
                        rect.origin.x = data.origin.x + currentWidthPositive
                        rect.size.width = stackValue - data.origin.x
                        currentWidthPositive += stackValue
                    }
                    else {
                        rect.origin.x = data.origin.x - currentWidthNegative - stackValue
                        rect.size.width = stackValue - data.origin.x
                        currentWidthNegative += stackValue
                    }
                renderer.drawSolidRectWithBorder(rect,
                                       strokeWidth: 2.0,
                                       fillColor: series.color,
                                       borderColor: series.color,
                                       hatchPattern: stackSeries[i].barGraphSeriesOptions.hatchPattern)
                }
            }
        }
    }
}
