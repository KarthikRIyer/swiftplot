import Foundation

fileprivate let MAX_DIV: Float = 50

// class defining a barGraph and all it's logic
public struct Histogram<T:FloatConvertible>: Plot {

    public var layout = GraphLayout()
    // Data.
    var histogramSeries = HistogramSeries<T>()
    var histogramStackSeries = [HistogramSeries<T>]()
    // Histogram layout properties.
    public var strokeWidth: Float = 2
    public var isNormalized = false
    
    public init(isNormalized: Bool = false,
                enableGrid: Bool = false){
        self.isNormalized = isNormalized
        self.enableGrid = enableGrid
    }
}

// Setting data.

extension Histogram {
    
    public mutating func addSeries(_ s: HistogramSeries<T>){
        histogramSeries = s
    }
    public mutating func addSeries(data: [T],
                          bins: Int,
                          label: String,
                          color: Color = .lightBlue,
                          histogramType: HistogramSeriesOptions.HistogramType = .bar){
        let series = HistogramSeries<T>(
            data: data,
            bins: bins,
            label: label,
            color: color,
            histogramType: histogramType
        )
        addSeries(series)
    }
    public mutating func addStackSeries(data: [T],
                               label: String,
                               color: Color = .lightBlue){
        let series = HistogramSeries<T>(
            data: data,
            bins: histogramSeries.bins,
            label: label,
            color: color,
            histogramType: histogramSeries.histogramSeriesOptions.histogramType
        )
        histogramStackSeries.append(series)
    }
}

// Layout properties.

extension Histogram {
    
    public var enableGrid: Bool {
        get { layout.enablePrimaryAxisGrid }
        set { layout.enablePrimaryAxisGrid = newValue }
    }
}

// extension containing drawing logic
extension Histogram: HasGraphLayout {

    public var legendLabels: [(String, LegendIcon)] {
        var legendSeries = histogramStackSeries.map { ($0.label, LegendIcon.square($0.color)) }
        legendSeries.insert((histogramSeries.label, .square(histogramSeries.color)), at: 0)
        return legendSeries
    }
    
    public struct DrawingData {

        var series_scaledBinFrequency = [Float]()
        var stack_scaledBinFrequency = [[Float]]()
        
        var barWidth: Float = 0
        let xMargin: Float = 5
        var origin = zeroPoint
    }

    // functions implementing plotting logic
    public func layoutData(size: Size, renderer: Renderer) -> (DrawingData, PlotMarkers?) {
        
        var results = DrawingData()
        var markers = PlotMarkers()
        
        var minimumX = histogramSeries.data.first!
        var maximumX = histogramSeries.data.last!
        for series in histogramStackSeries {
            minimumX = min(minimumX, series.data.first!)
            maximumX = max(maximumX, series.data.last!)
        }
        minimumX = T(roundFloor10(Float(minimumX)))
        maximumX = T(roundCeil10(Float(maximumX)))
        let binInterval = (maximumX-minimumX)/T(histogramSeries.bins)
        let (series_binFrequency, series_maxFreq) = recalculateBins(series: histogramSeries,
                        binStart: minimumX,
                        binEnd: maximumX,
                        binInterval: binInterval)
        
        var stack_binFrequencies = [[Float]]()
        for index in 0..<histogramStackSeries.count {
            let (stack_binFreq, _) = recalculateBins(series: histogramStackSeries[index],
                            binStart: minimumX,
                            binEnd: maximumX,
                            binInterval: binInterval)
            stack_binFrequencies.append(stack_binFreq)
        }
        
        let minimumY = Float(0)
        var maximumY = series_maxFreq
        for index in 0..<histogramSeries.bins {
            var tempFrequency = series_binFrequency[index]
            for stack in stack_binFrequencies {
                tempFrequency += stack[index]
            }
            if (tempFrequency>maximumY) {
                maximumY = tempFrequency
            }
        }

        results.barWidth = round((size.width - Float(2.0*results.xMargin))/Float(histogramSeries.bins))

        results.origin = Point((size.width-(2.0*results.xMargin))/Float(maximumX-minimumX)*Float(T(-1)*minimumX), 0.0)

        let topScaleMargin: Float = size.height * 0.10
        let scaleY = Float(maximumY - minimumY) / (size.height - topScaleMargin)
        let scaleX = Float(maximumX - minimumX) / (size.width-Float(2.0*results.xMargin))

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

        var yM: Float = results.origin.y
        while yM<=size.height {
            if(yM+inc1<0.0 || yM<0.0){
                yM = yM + inc1
                continue
            }
            markers.yMarkers.append(yM)
            markers.yMarkersText.append("\(roundToN(scaleY*(yM-results.origin.y), yIncRound))")
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
        let xM: Float = results.xMargin
        let scaleXInv = 1.0/scaleX
        let xIncrement = inc2
        for i in stride(from: Float(minimumX), through: Float(maximumX), by: xIncrement)  {
            markers.xMarkers.append((i-Float(minimumX))*scaleXInv + xM)
            markers.xMarkersText.append("\(i)")
        }

        // scale points to be plotted according to plot size
        let scaleYInv: Float = 1.0/scaleY
        results.series_scaledBinFrequency = series_binFrequency.map { ($0 * scaleYInv) + results.origin.y }
        results.stack_scaledBinFrequency = stack_binFrequencies.map {
            stackVals in stackVals.map { freq in (freq * scaleYInv) + results.origin.y }
        }
        
        return (results, markers)
    }
    
    /// Draw with rectangles if `histogramType` is `.bar` or with lines if `histogramType` is `.step`.
    public func drawData(_ data: DrawingData, size: Size, renderer: Renderer) {
        let binCount = histogramSeries.bins
        let allSeries = [data.series_scaledBinFrequency] + data.stack_scaledBinFrequency
        let allSeriesInfo = [histogramSeries] + histogramStackSeries
        
        switch histogramSeries.histogramSeriesOptions.histogramType {
        case .bar:
            let xStart = Float(data.xMargin)
            let xValues = stride(from: xStart, to: xStart + Float(binCount) * data.barWidth, by: data.barWidth)
            
            // Iterate through each bar stacking the corresponding bar of each series.
            for (x, binIdx) in zip(xValues, 0..<binCount) {
                var currentHeight: Float = 0.0
                for seriesIdx in allSeriesInfo.indices {
                    let height = allSeries[seriesIdx][binIdx]
                    let rect = Rect(origin: Point(x, currentHeight), size: Size(width: data.barWidth, height: height))
                    renderer.drawSolidRect(rect, fillColor: allSeriesInfo[seriesIdx].color, hatchPattern: .none)
                    currentHeight += height
                }
            }
        case .step:
            /// Accumulate the frequencies of each series.
            // One heights array for each series.
            let xStart = Float(data.xMargin)
            let xValues = stride(from: xStart, through: xStart + Float(binCount) * data.barWidth, by: data.barWidth)

            // One heights array for each series
            var seriesHeights: [[Float]] = [[Float](repeating: 0.0, count: binCount + 2)]
            
            // Sum the bin frequencies from two series together and append to `seriesHeights`.
            var currentHeights = seriesHeights[seriesHeights.startIndex]
            for series in allSeries {
                for (newHeight, index) in zip(series, currentHeights.indices.dropFirst().dropLast()) {
                    currentHeights[index] += newHeight
                }
                seriesHeights.append(currentHeights)
            }
            
            // Iterate over the series in reverse to draw from back to front.
            var seriesHeightsSlice = seriesHeights.reversed()[...]
            var backHeightsSlice = seriesHeightsSlice.removeFirst()[...]
            for (frontHeights, seriesIdx) in zip(seriesHeightsSlice, allSeries.indices.reversed()) {
                var frontHeightsSlice = frontHeights[...]
                let series = allSeries[seriesIdx]
                
                /// Iterate over bin edges focusing on the height of the left and right bins of the series on the back and in front.
                var line = [Point]()
                var backLeftBinHeight = backHeightsSlice.removeFirst()
                var frontLeftBinHeight = frontHeightsSlice.removeFirst()
                for ((backRightBinHeight, frontRightBinHeight), x) in zip(zip(backHeightsSlice, frontHeightsSlice), xValues) {
                    func endLine() {
                        renderer.drawPlotLines(points: line, strokeWidth: strokeWidth,
                                               strokeColor: allSeriesInfo[seriesIdx].color,
                                               isDashed: false)
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

// Helpers.

private extension Histogram {
    
    func recalculateBins(series: HistogramSeries<T>,
                         binStart: T,
                         binEnd: T,
                         binInterval: T) -> (binFrequency: [Float], maxFrequency: Float) {
        
        var maximumFrequency = Float(0)
        var binFrequency = stride(from: Float(binStart), through: Float(binEnd), by: Float(binInterval)).map {
            start -> Float in
            let end = start + Float(binInterval)
            var count: Float = 0
            for d in series.data {
                if(d < T(end) && d >= T(start)) {
                    count += 1
                }
            }
            maximumFrequency = max(count, maximumFrequency)
            return count
        }
        if (isNormalized) {
            let factor = Float(series.data.count)*Float(binInterval)
            for index in 0..<binFrequency.count {
                binFrequency[index]/=factor
            }
            maximumFrequency/=factor
        }
        return (binFrequency, maximumFrequency)
    }
}
