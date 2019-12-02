import Foundation

// class defining a barGraph and all it's logic
public class Histogram<T:FloatConvertible>: Plot {

    let MAX_DIV: Float = 50

    public var layout = GraphLayout()

    public var strokeWidth: Float = 2
    
    var histogramSeries = HistogramSeries<T>()
    var histogramSeriesInfo = HistogramSeriesInfo()
    
    var histogramStackSeries = [HistogramSeries<T>]()
    var histogramStackSeriesInfo = [HistogramSeriesInfo]()
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
                                  minimumX: minimumX,
                                  maximumX: maximumX,
                                  binInterval: binInterval)
    }
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
    }

    // functions implementing plotting logic
    public func layoutData(size: Size, renderer: Renderer) -> (DrawingData, PlotMarkers?) {
        
        var results = DrawingData()
        var markers = PlotMarkers()
        
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
        var inc2: Float = nX
        if(size.width/nX > MAX_DIV){
            inc2 = (size.height/nX)*inc1/MAX_DIV
        }
        let xM: Float = xMargin
        let scaleXInv = 1.0/scaleX
        let xIncrement = inc2*scaleX
        for i in stride(from: Float(minimumX), through: Float(maximumX), by: xIncrement)  {
            markers.xMarkers.append((i-Float(minimumX))*scaleXInv + xM)
            markers.xMarkersText.append("\(i)")
        }

        // scale points to be plotted according to plot size
        let scaleYInv: Float = 1.0/scaleY
        results.series_scaledBinFrequency = series_binFrequency.map { ($0 * scaleYInv) + origin.y }
        results.stack_scaledBinFrequency = stack_binFrequencies.map {
            stackVals in stackVals.map { freq in (freq * scaleYInv) + origin.y }
        }
        
        return (results, markers)
    }
    //functions to draw the plot
    public func drawData(_ data: DrawingData, size: Size, renderer: Renderer) {
        let binCount = histogramSeries.bins
        let allSeries = [data.series_scaledBinFrequency] + data.stack_scaledBinFrequency
        let allSeriesInfo = [histogramSeries] + histogramStackSeries
        switch histogramSeries.histogramSeriesOptions.histogramType {
        case .bar:
            let xStart = Float(xMargin)
            let xValues = stride(from: xStart, to: xStart + Float(binCount) * barWidth, by: barWidth)
            
            // Get a `Slice` of frequencies for each series so we can take one element from each series for each x value
            var frequencySlices = allSeries.map { $0[...] }
            for x in xValues {
                var currentHeight: Float = 0.0
                for (series, index) in zip(allSeries, frequencySlices.indices) {
                    let height = frequencySlices[index].removeFirst()
                    let rect = Rect(origin: Point(x, currentHeight), size: Size(width: barWidth, height:
                        height))
                    renderer.drawSolidRect(rect, fillColor: allSeriesInfo[index].color,
                                           hatchPattern: .none)
                    currentHeight += height
                }
                currentHeight = 0.0
            }
        case .step:
            let xStart = Float(xMargin)
            let xValues = stride(from: xStart, through: xStart + Float(binCount) * barWidth, by: barWidth)
            
            // One heights array for each series
            var seriesHeights: [[Float]] = [[Float](repeating: 0.0, count: binCount + 2)]
            
            // Update `currentHeights` with the height from the series and add ìt to `heights`
            var currentHeights = seriesHeights[seriesHeights.startIndex]
            for series in allSeries {
                for (newHeight, index) in zip(series, currentHeights.indices.dropFirst().dropLast()) {
                    currentHeights[index] += newHeight
                }
                seriesHeights.append(currentHeights)
            }
            
            // Draw only the line segments that will actually be visible, unobstructed from other lines that will be on top
            // We iterate over the series in reverse to draw them from back to front
            var seriesHeightsSlice = seriesHeights.reversed()[...]
            var backHeightsSlice = seriesHeightsSlice.removeFirst()[...]
            for (frontHeights, seriesIdx) in zip(seriesHeightsSlice, allSeries.indices.reversed()) {
                var frontHeightsSlice = frontHeights[...]
                let series = allSeries[seriesIdx]
                
                // Iterate over bin edges focusing on the height of the left and right bins of the series on the back and in front
                var backLeftBinHeight = backHeightsSlice.removeFirst()
                var frontLeftBinHeight = frontHeightsSlice.removeFirst()
                var line = [Point]()
                for ((backRightBinHeight, frontRightBinHeight), x) in zip(zip(backHeightsSlice, frontHeightsSlice), xValues) {
                    
                    func endLine() {
                        renderer.drawPlotLines(points: line, strokeWidth: strokeWidth,
                                               strokeColor: allSeriesInfo[seriesIdx].color,
                                               isDashed: false)
                        line.removeAll(keepingCapacity: true)
                    }
                    
                    // Conditions for appending specific points or ending the line at different places based on the relative heights (4 measures)
                    let c1 = backLeftBinHeight  > frontLeftBinHeight
                    let c2 = backRightBinHeight > frontRightBinHeight
                    let c3 = backLeftBinHeight  > frontRightBinHeight
                    let c4 = backRightBinHeight > frontLeftBinHeight
                    
                    if  c1 ||  c3 && c4 { line.append(Point(x, backLeftBinHeight)) }
                    if !c3              { endLine() }
                    if  c1 && !c4       { line.append(Point(x, frontLeftBinHeight)) }
                    if !c4              { endLine() }
                    if  c2 && !c3       { line.append(Point(x, frontRightBinHeight)) }
                    if  c2 ||  c3 && c4 { line.append(Point(x, backRightBinHeight)) }
                    if !c2              { endLine() }
                    
                    backLeftBinHeight  = backRightBinHeight
                    frontLeftBinHeight = frontRightBinHeight
                }
                backHeightsSlice = frontHeights[...]
            }
        }
    }
}
