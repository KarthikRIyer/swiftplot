import Foundation

// class defining a barGraph and all it's logic
public class Histogram<T:FloatConvertible>: Plot {

    let MAX_DIV: Float = 50

    public var layout = GraphLayout()

    public var strokeWidth: Float = 2
    
    var histogramSeries = HistogramSeries<T>()
    var histogramStackSeries = [HistogramSeries<T>]()
    var isNormalized = false
    var scaleY: Float = 1
    var scaleX: Float = 1
    var barWidth: Float = 0
    var xMargin: Float = 5
    var origin = zeroPoint

    public init(isNormalized: Bool = false,
                enableGrid: Bool = false){
        self.isNormalized = isNormalized
        self.enableGrid = enableGrid
    }
    
    public var enableGrid: Bool {
        get { layout.enablePrimaryAxisGrid }
        set { layout.enablePrimaryAxisGrid = newValue }
    }
    
    public func addSeries(_ s: HistogramSeries<T>){
        histogramSeries = s
    }
    public func addSeries(data: [T],
                          bins: Int,
                          label: String,
                          color: Color = .lightBlue,
                          histogramType: HistogramSeriesOptions.HistogramType = .bar){
        addSeries(calculateSeriesData(data: data,
                                      bins: bins,
                                      label: label,
                                      color: color,
                                      histogramType: histogramType))
    }
    public func addStackSeries(data: [T],
                               label: String,
                               color: Color = .lightBlue){
        histogramStackSeries.append(calculateSeriesData(data: data,
                                                        bins: histogramSeries.bins,
                                                        label: label,
                                                        color: color,
                                                        histogramType: histogramSeries.histogramSeriesOptions.histogramType))
    }
    func calculateSeriesData(data: [T],
                             bins: Int,
                             label: String,
                             color: Color,
                             histogramType: HistogramSeriesOptions.HistogramType) -> HistogramSeries<T> {
        var sortedData = data
        sortedData.sort()
        let minimumX = T(roundFloor10(Float(sortedData[0])))
        let maximumX = T(roundCeil10(Float(sortedData[sortedData.count-1])))
        let binInterval = (maximumX-minimumX)/T(bins)
        var dataIndex: Int = 0
        var binStart = minimumX
        var binEnd = minimumX + binInterval
        var maximumFrequency: Float = 0
        var binFrequency = [Float]()
        for _ in 1...bins {
            var count: Float = 0
            while (dataIndex<sortedData.count && sortedData[dataIndex] >= binStart && sortedData[dataIndex] < binEnd) {
                count+=1
                dataIndex+=1
            }
            if (count > maximumFrequency) {
                maximumFrequency = count
            }
            binFrequency.append(count)
            binStart = binStart + binInterval
            binEnd = binEnd + binInterval
        }
        if (isNormalized) {
            let factor = Float(sortedData.count)*Float(binInterval)
            for index in 0..<bins {
                binFrequency[index]/=factor
            }
            maximumFrequency/=factor
        }
        return HistogramSeries<T>(data: sortedData,
                                  bins: bins,
                                  isNormalized: isNormalized,
                                  label: label,
                                  color: color,
                                  histogramType: histogramType,
                                  binFrequency: binFrequency,
                                  maximumFrequency: maximumFrequency,
                                  minimumX: minimumX,
                                  maximumX: maximumX,
                                  binInterval: binInterval)
    }
    func recalculateBins(series: HistogramSeries<T>,
                         binStart: T,
                         binEnd: T,
                         binInterval: T) {
    series.binFrequency.removeAll()
        series.maximumFrequency = 0
        for start in stride(from: Float(binStart), through: Float(binEnd), by: Float(binInterval)){
            let end = start + Float(binInterval)
            var count: Float = 0
            for d in series.data {
                if(d < T(end) && d >= T(start)) {
                    count += 1
                }
            }
            if (count > series.maximumFrequency) {
                series.maximumFrequency = count
            }
            series.binFrequency.append(count)
        }
        if (isNormalized) {
            let factor = Float(series.data.count)*Float(binInterval)
            for index in 0..<series.bins {
                series.binFrequency[index]/=factor
            }
            series.maximumFrequency/=factor
        }
    }
}

// extension containing drawing logic
extension Histogram: HasGraphLayout {

    public var legendLabels: [(String, LegendIcon)] {
        var legendSeries = histogramStackSeries.map { ($0.label, LegendIcon.square($0.color)) }
        legendSeries.insert((histogramSeries.label, .square(histogramSeries.color)), at: 0)
        return legendSeries
    }

    // functions implementing plotting logic
    public func calculateScaleAndMarkerLocations(markers: inout PlotMarkers, size: Size, renderer: Renderer) {
        
        var maximumY = Float(histogramSeries.maximumFrequency)
        let minimumY = Float(0)
        var maximumX: T = histogramSeries.maximumX!
        var minimumX: T = histogramSeries.minimumX!

        for series in histogramStackSeries {
            if (series.maximumX! > maximumX) {
                maximumX = series.maximumX!
            }
            if (series.minimumX! < minimumX) {
                minimumX = series.minimumX!
            }
        }
        let binInterval = (maximumX-minimumX)/T(histogramSeries.bins)
        recalculateBins(series: histogramSeries,
                        binStart: minimumX,
                        binEnd: maximumX,
                        binInterval: binInterval)
        for index in 0..<histogramStackSeries.count {
            recalculateBins(series: histogramStackSeries[index],
                            binStart: minimumX,
                            binEnd: maximumX,
                            binInterval: binInterval)
        }
        for index in 0..<histogramSeries.bins {
            var tempFrequency = histogramSeries.binFrequency[index]
            for series in histogramStackSeries {
                tempFrequency += series.binFrequency[index]
            }
            if (tempFrequency>maximumY) {
                maximumY = tempFrequency
            }
        }

        barWidth = round((size.width - Float(2.0*xMargin))/Float(histogramSeries.bins))

        origin = Point((size.width-(2.0*xMargin))/Float(maximumX-minimumX)*Float(T(-1)*minimumX), 0.0)

        let topScaleMargin: Float = size.height * 0.10
        scaleY = Float(maximumY - minimumY) / (size.height - topScaleMargin)
        scaleX = Float(maximumX - minimumX) / (size.width-Float(2.0*xMargin))

        var inc1: Float = -1
        var yIncRound: Int = 1

        if(Float(maximumY-minimumY)<=2.0 && Float(maximumY-minimumY)>=1.0) {
            let differenceY = Float(maximumY-minimumY)
            inc1 = 0.5*(1.0/differenceY)
            // print("\(differenceY)")
            var c = 0
            while(abs(inc1)*pow(10.0,Float(c))<1.0) {
                c+=1
            }
            inc1 = inc1/scaleY
            yIncRound = c+1
        }
        else if(Float(maximumY-minimumY)<1.0) {
            let differenceY = Float(maximumY-minimumY)
            inc1 = differenceY/10.0
            // print("\(differenceY)")
            var c = 0
            while(abs(inc1)*pow(10.0,Float(c))<1.0) {
                c+=1
            }
            inc1 = inc1/scaleY
            yIncRound = c+1
        }

        let nD1: Int = max(getNumberOfDigits(Float(maximumY)), getNumberOfDigits(Float(minimumY)))
        var v1: Float
        if (nD1 > 1 && maximumY <= pow(Float(10), Float(nD1 - 1))) {
            v1 = Float(pow(Float(10), Float(nD1 - 2)))
        } else if (nD1 > 1) {
            v1 = Float(pow(Float(10), Float(nD1 - 1)))
        } else {
            v1 = Float(pow(Float(10), Float(0)))
        }

        if(inc1 == -1) {
            let nY: Float = v1/scaleY
            inc1 = nY
            if(size.height/nY > MAX_DIV){
                inc1 = (size.height/nY)*inc1/MAX_DIV
            }
        }

        var yM: Float = origin.y
        while yM<=size.height {
            if(yM+inc1<0.0 || yM<0.0){
                yM = yM + inc1
                continue
            }
            markers.yMarkers.append(yM)
            markers.yMarkersText.append("\(roundToN(scaleY*(yM-origin.y), yIncRound))")
            yM = yM + inc1
        }

        let xRange = niceRoundFloor(Float(maximumX - minimumX))
        let nD2: Int = getNumberOfDigits(xRange)
        var v2: Float
        if (nD2 > 1 && xRange <= pow(Float(10), Float(nD2 - 1))) {
            v2 = Float(pow(Float(10), Float(nD2 - 2)))
        } else if (nD2 > 1) {
            v2 = Float(pow(Float(10), Float(nD2 - 1)))
        } else {
            v2 = Float(pow(Float(10), Float(0)))
        }

        let nX: Float = v2/scaleX
        var inc2: Float = v2
        if(size.width/nX > MAX_DIV){
            inc2 = (size.height/v2)*inc1/MAX_DIV
        }
        let xM: Float = xMargin
        let scaleXInv = 1.0/scaleX
        let xIncrement = inc2
        for i in stride(from: Float(minimumX), through: Float(maximumX), by: xIncrement)  {
            markers.xMarkers.append((i-Float(minimumX))*scaleXInv + xM)
            markers.xMarkersText.append("\(i)")
        }

        // scale points to be plotted according to plot size
        let scaleYInv: Float = 1.0/scaleY
        histogramSeries.scaledBinFrequency.removeAll();
        for j in 0..<histogramSeries.binFrequency.count {
            let frequency = Float(histogramSeries.binFrequency[j])
            histogramSeries.scaledBinFrequency.append(frequency*scaleYInv + origin.y)
        }
        for index in 0..<histogramStackSeries.count {
            histogramStackSeries[index].scaledBinFrequency.removeAll()
            for j in 0..<histogramStackSeries[index].binFrequency.count {
                let frequency = Float(histogramStackSeries[index].binFrequency[j])
                histogramStackSeries[index].scaledBinFrequency.append(frequency*scaleYInv + origin.y)
            }
        }
    }
    
    /// Draw with rectangles if `histogramType` is `.bar` or with lines if `histogramType` is `.step`.
    public func drawData(markers: PlotMarkers, size: Size, renderer: Renderer) {
        let binCount = histogramSeries.bins
        let allSeries = [histogramSeries] + histogramStackSeries
        let xStart = Float(xMargin)
        
        switch histogramSeries.histogramSeriesOptions.histogramType {
        case .bar:
            let xValues = stride(from: xStart, to: xStart + Float(binCount) * barWidth, by: barWidth)
            
            // Iterate through each bar stacking the corresponding bar of each series.
            for (x, binIndex) in zip(xValues, 0..<binCount) {
                var currentHeight: Float = 0.0
                for series in allSeries {
                    let height = series.scaledBinFrequency[binIndex]
                    let rect = Rect(origin: Point(x, currentHeight), size: Size(width: barWidth, height: height))
                    renderer.drawSolidRect(rect, fillColor: series.color, hatchPattern: .none)
                    currentHeight += height
                }
            }
        case .step:
            /// Accumulate the frequencies of each series.
            // One heights array for each series.
            var seriesHeights: [[Float]] = [[Float](repeating: 0.0, count: binCount + 2)]
            
            // Sum the bin frequencies from two series together and append to `seriesHeights`.
            var currentHeights = seriesHeights[seriesHeights.startIndex]
            for series in allSeries {
                for (newHeight, index) in zip(series.scaledBinFrequency, currentHeights.indices.dropFirst().dropLast()) {
                    currentHeights[index] += newHeight
                }
                seriesHeights.append(currentHeights)
            }
            let xValues = stride(from: xStart, through: xStart + Float(binCount) * barWidth, by: barWidth)
            
            // Iterate over the series in reverse to draw from back to front.
            var seriesHeightsSlice = seriesHeights.reversed()[...]
            var backHeightsSlice = seriesHeightsSlice.removeFirst()[...]
            for (frontHeights, series) in zip(seriesHeightsSlice, allSeries.reversed()) {
                var frontHeightsSlice = frontHeights[...]
                
                /// Iterate over bin edges focusing on the height of the left and right bins of the series on the back and in front.
                var line = [Point]()
                var backLeftBinHeight = backHeightsSlice.removeFirst()
                var frontLeftBinHeight = frontHeightsSlice.removeFirst()
                for ((backRightBinHeight, frontRightBinHeight), x) in zip(zip(backHeightsSlice, frontHeightsSlice), xValues) {
                    func endLine() {
                        renderer.drawPlotLines(points: line, strokeWidth: self.strokeWidth,
                                               strokeColor: series.color, isDashed: false)
                        line.removeAll(keepingCapacity: true)
                    }
                    
                    // Conditions for appending specific points or ending the line at different places based on the relative heights.
                    let c1 = backLeftBinHeight  > frontLeftBinHeight
                    let c2 = backRightBinHeight > frontRightBinHeight
                    let c3 = backLeftBinHeight  > frontRightBinHeight
                    let c4 = backRightBinHeight > frontLeftBinHeight
                    
                    if  c1 ||   c3 &&  c4  { line.append(Point(x, backLeftBinHeight)) }
                    if  c1 &&  !c4         { line.append(Point(x, frontLeftBinHeight)) }
                    if  c1 && (!c3 || !c4) { endLine() }
                    if  c2 &&  !c3         { line.append(Point(x, frontRightBinHeight)) }
                    if  c2 ||   c3 &&  c4  { line.append(Point(x, backRightBinHeight)) }
                    if !c2 &&   c3 &&  c4  { endLine() }
                    
                    backLeftBinHeight  = backRightBinHeight
                    frontLeftBinHeight = frontRightBinHeight
                }
                backHeightsSlice = frontHeights[...]
            }
        }
    }
}
