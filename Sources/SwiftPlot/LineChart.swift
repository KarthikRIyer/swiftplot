import Foundation

fileprivate let MAX_DIV: Float = 50

// class defining a lineGraph and all its logic
public struct LineGraph<T:FloatConvertible,U:FloatConvertible>: Plot {

    public var layout = GraphLayout()
    // Data.
    var primaryAxis = Axis<T,U>()
    var secondaryAxis: Axis<T,U>? = nil
    // Linegraph layout properties.
    public var plotLineThickness: Float = 1.5
    
    public init(enablePrimaryAxisGrid: Bool = false,
                enableSecondaryAxisGrid: Bool = false){
        self.enablePrimaryAxisGrid = enablePrimaryAxisGrid
        self.enableSecondaryAxisGrid = enableSecondaryAxisGrid
    }
    
    public init(points : [Pair<T,U>],
                enablePrimaryAxisGrid: Bool = false,
                enableSecondaryAxisGrid: Bool = false){
        self.init(enablePrimaryAxisGrid: enablePrimaryAxisGrid, enableSecondaryAxisGrid: enableSecondaryAxisGrid)
        primaryAxis.series.append(Series(values: points, label: "Plot"))
    }
}

// Setting data.

extension LineGraph {

    // functions to add series
    public mutating func addSeries(_ s: Series<T,U>,
                          axisType: Axis<T,U>.Location = .primaryAxis){
        switch axisType {
        case .primaryAxis:
            primaryAxis.series.append(s)
        case .secondaryAxis:
            if secondaryAxis == nil {
                secondaryAxis = Axis()
            }
            secondaryAxis!.series.append(s)
        }
    }
    public mutating func addSeries(points : [Pair<T,U>],
                          label: String, color: Color = Color.lightBlue,
                          axisType: Axis<T,U>.Location = .primaryAxis){
        let s = Series<T,U>(values: points,label: label, color: color)
        addSeries(s, axisType: axisType)
    }
    public mutating func addSeries(_ y: [U],
                          label: String,
                          color: Color = Color.lightBlue,
                        axisType: Axis<T,U>.Location = .primaryAxis){
        var points = [Pair<T,U>]()
        for i in 0..<y.count {
            points.append(Pair<T,U>(T(i), y[i]))
        }
        let s = Series<T,U>(values: points, label: label, color: color)
        addSeries(s, axisType: axisType)
    }
    public mutating func addSeries(_ x: [T],
                          _ y: [U],
                          label: String,
                          color: Color = .lightBlue,
                          axisType: Axis<T,U>.Location = .primaryAxis){
        var points = [Pair<T,U>]()
        for i in 0..<x.count {
            points.append(Pair<T,U>(x[i], y[i]))
        }
        let s = Series<T,U>(values: points, label: label, color: color)
        addSeries(s, axisType: axisType)
    }
    public mutating func addFunction(_ function: (T)->U,
                            minX: T,
                            maxX: T,
                            numberOfSamples: Int = 400,
                            clampY: ClosedRange<U>? = nil,
                            label: String,
                            color: Color = Color.lightBlue,
                            axisType: Axis<T,U>.Location = .primaryAxis) {
        
        let step = Float(maxX - minX)/Float(numberOfSamples)
        let points = stride(from: Float(minX), through: Float(maxX), by: step).compactMap { i -> Pair<T,U>? in
            let result = function(T(i))
            guard Float(result).isFinite else { return nil }
            if let clampY = clampY, !clampY.contains(result) {
                return nil
            }
            return Pair(T(i), result)
        }
        let s = Series<T,U>(values: points, label: label, color: color)
        addSeries(s, axisType: axisType)
    }
}

// Layout properties.

extension LineGraph {
    
    public var enablePrimaryAxisGrid: Bool {
        get { layout.enablePrimaryAxisGrid }
        set { layout.enablePrimaryAxisGrid = newValue }
    }
    
    public var enableSecondaryAxisGrid: Bool {
        get { layout.enableSecondaryAxisGrid }
        set { layout.enableSecondaryAxisGrid = newValue }
    }
}

// Layout and drawing of data.

extension LineGraph: HasGraphLayout {

    public var legendLabels: [(String, LegendIcon)] {
        var allSeries: [Series] = primaryAxis.series
        if (secondaryAxis != nil) {
            allSeries = allSeries + secondaryAxis!.series
        }
        return allSeries.map { ($0.label, .square($0.color)) }
    }
    
    public struct DrawingData {
      var primaryAxisInfo: AxisLayoutInfo?
      var secondaryAxisInfo: AxisLayoutInfo?
    }
  
  // functions implementing plotting logic
  public func layoutData(size: Size, renderer: Renderer) -> (DrawingData, PlotMarkers?) {
    var results = DrawingData()
    var markers = PlotMarkers()
    guard !primaryAxis.series.isEmpty, !primaryAxis.series[0].values.isEmpty else { return (results, markers) }
    
    results.primaryAxisInfo   = AxisLayoutInfo(series: primaryAxis.series, size: size)
    results.secondaryAxisInfo = secondaryAxis.map {
      var info = AxisLayoutInfo(series: $0.series, size: size)
      info.mergeXAxis(with: &results.primaryAxisInfo!)
      return info
    }
    
    (markers.xMarkers, markers.xMarkersText, markers.yMarkers, markers.yMarkersText) =
      results.primaryAxisInfo!.calculateMarkers()
    if let secondaryAxisInfo = results.secondaryAxisInfo {
      (_, _, markers.y2Markers, markers.y2MarkersText) = secondaryAxisInfo.calculateMarkers()
    }
    
    return (results, markers)
  }
  
  //functions to draw the plot
  public func drawData(_ data: DrawingData, size: Size, renderer: Renderer) {
    if let axisInfo = data.primaryAxisInfo {
      for dataset in primaryAxis.series {
        let points = dataset.values.map { axisInfo.convertCoordinate(fromData: $0) }
        guard let polyline = Polyline(points) else {
            fatalError("LineChart.drawData: Expecting 2 or more points, got \(points.count) instead")
        }
        renderer.drawPolyline(polyline,
                              strokeWidth: plotLineThickness,
                              strokeColor: dataset.color,
                              isDashed: false)
      }
    }
    if let secondaryAxis = secondaryAxis, let axisInfo = data.secondaryAxisInfo {
      for dataset in secondaryAxis.series {
        let points = dataset.values.map { axisInfo.convertCoordinate(fromData: $0) }
        guard let polyline = Polyline(points) else {
            fatalError("LineChart.drawData: Expecting 2 or more points, got \(points.count) instead")
        }
        renderer.drawPolyline(polyline,
                              strokeWidth: plotLineThickness,
                              strokeColor: dataset.color,
                              isDashed: true)
      }
    }
  }
}

extension LineGraph {
  
  struct AxisLayoutInfo {
    let size: Size
    let rightMargin: Float
    let topMargin: Float
    var bounds: (x: ClosedRange<T>, y: ClosedRange<U>)
    
    var scaleX: Float = 1
    var scaleY: Float = 1
    // The "origin" is just a known value at a known location,
    // used for calculating where other points are located.
    var origin: Point = .zero
    var originValue = Pair(T(0), U(0))
    
    init(series: [Series<T, U>], size: Size) {
      self.size   = size
      rightMargin = size.width  * 0.05
      topMargin   = size.height * 0.05
      bounds      = AxisLayoutInfo.getBounds(series)
      boundsDidChange()
    }
    
    private static func getBounds(_ series: [Series<T, U>]) -> (x: ClosedRange<T>, y: ClosedRange<U>) {
      var maximumX: T = maxX(points: series[0].values)
      var minimumX: T = minX(points: series[0].values)
      var maximumY: U = maxY(points: series[0].values)
      var minimumY: U = minY(points: series[0].values)
      for s in series {
        var x: T = maxX(points: s.values)
        var y: U = maxY(points: s.values)
        maximumX = max(x, maximumX)
        maximumY = max(y, maximumY)
        x = minX(points: s.values)
        y = minY(points: s.values)
        minimumX = min(x, minimumX)
        minimumY = min(y, minimumY)
      }
      return (x: minimumX...maximumX, y: minimumY...maximumY)
    }
    
    private mutating func boundsDidChange() {
      let availableWidth   = size.width  - (2 * rightMargin)
      let availableHeight  = size.height - (2 * topMargin)
      let xRange_primary = Float(bounds.x.upperBound - bounds.x.lowerBound)
      let yRange_primary = Float(bounds.y.upperBound - bounds.y.lowerBound)
      
      scaleX = xRange_primary / availableWidth
      scaleY = yRange_primary / availableHeight
      calculateOrigin()
    }
    
    private mutating func calculateOrigin() {
      let originLocX: Float
      let originLocY: Float
      if Float(bounds.x.lowerBound) >= 0, Float(bounds.x.upperBound) >= 0 {
        // All points on positive X axis.
        originLocX = rightMargin
        originValue.x = bounds.x.lowerBound
      } else if Float(bounds.x.lowerBound) < 0, Float(bounds.x.upperBound) < 0 {
        // All points on negative X axis.
        originLocX = size.width - rightMargin
        originValue.x = bounds.x.upperBound
      } else {
        // Both sides of X axis.
        originLocX = (Float(bounds.x.lowerBound).magnitude / scaleX) + rightMargin
        originValue.x = T(0)
      }
      
      if Float(bounds.y.lowerBound) >= 0, Float(bounds.y.upperBound) >= 0 {
        // All points on positive Y axis.
        originLocY = topMargin
        originValue.y = bounds.y.lowerBound
      } else if Float(bounds.y.lowerBound) < 0, Float(bounds.y.upperBound) < 0 {
        // All points on negative Y axis.
        originLocY = size.height - topMargin
        originValue.y = bounds.y.upperBound
      } else {
        // Both sides of Y axis.
        originLocY = (Float(bounds.y.lowerBound).magnitude / scaleY) + topMargin
        originValue.y = U(0)
      }
      origin = Pair(originLocX, originLocY)
      
      // If the zero-coordinate is already in view, snap the origin to it.
      let zeroLocation = convertCoordinate(fromData: Pair(T(0), U(0)))
      if (0...size.width).contains(zeroLocation.x) {
        origin.x = zeroLocation.x
        originValue.x = T(0)
      }
      if (0...size.height).contains(zeroLocation.y) {
        origin.y = zeroLocation.y
        originValue.y = U(0)
      }
    }
    
    func calculateMarkers() -> (x: [Float], xLabels: [String], y: [Float], yLabels: [String]) {
      var yIncrement: Float = -1
      var xIncrement: Float = -1
      var xIncRound: Int   = 1
      var yIncRound: Int = 1
      let xRange = Float(bounds.x.upperBound - bounds.x.lowerBound)
      let yRange = Float(bounds.y.upperBound - bounds.y.lowerBound)
      
      if yRange <= 2.0, yRange >= 1.0 {
        let differenceY = yRange
        yIncrement = 0.5*(1.0/differenceY)
        var c = 0
        while(abs(yIncrement)*pow(10.0,Float(c))<1.0) {
          c+=1
        }
        yIncrement = yIncrement/scaleY
        yIncRound = c+1
      } else if yRange < 1.0 {
        let differenceY = yRange
        yIncrement = differenceY/10.0
        var c = 0
        while(abs(yIncrement)*pow(10.0,Float(c))<1.0) {
          c+=1
        }
        yIncrement = yIncrement/scaleY
        yIncRound = c+1
      }
      
      if xRange <= 2.0, xRange >= 1.0 {
        let differenceX = xRange
        xIncrement = 0.5*(1.0/differenceX)
        var c = 0
        while(abs(xIncrement)*pow(10.0,Float(c))<1.0) {
          c+=1
        }
        xIncrement = xIncrement/scaleX
        xIncRound = c+1
      } else if xRange < 1.0 {
        let differenceX = xRange
        xIncrement = differenceX/10
        var c = 0
        while(abs(xIncrement)*pow(10.0,Float(c))<1.0) {
          c+=1
        }
        xIncrement = xIncrement/scaleX
        xIncRound = c+1
      }
      
      let nD1: Int = max(getNumberOfDigits(Float(bounds.y.upperBound)), getNumberOfDigits(Float(bounds.y.lowerBound)))
      var v1: Float
      if (nD1 > 1 && bounds.y.upperBound <= U(pow(Float(10), Float(nD1 - 1)))) {
          v1 = Float(pow(Float(10), Float(nD1 - 2)))
      } else if (nD1 > 1) {
          v1 = Float(pow(Float(10), Float(nD1 - 1)))
      } else {
          v1 = Float(pow(Float(10), Float(0)))
      }
      let nY: Float = v1/scaleY
      if(yIncrement == -1) {
          yIncrement = nY
          if(size.height/nY > MAX_DIV){
              yIncrement = (size.height/nY)*yIncrement/MAX_DIV
          }
      }

      let nD2: Int = max(getNumberOfDigits(Float(bounds.x.upperBound)), getNumberOfDigits(Float(bounds.x.lowerBound)))
      var v2: Float
      if (nD2 > 1 && bounds.x.upperBound <= T(pow(Float(10), Float(nD2 - 1)))) {
          v2 = Float(pow(Float(10), Float(nD2 - 2)))
      } else if (nD2 > 1) {
          v2 = Float(pow(Float(10), Float(nD2 - 1)))
      } else {
          v2 = Float(pow(Float(10), Float(0)))
      }

      let nX: Float = v2/scaleX
      if(xIncrement == -1) {
          xIncrement = nX
          var noXD: Float = size.width/nX
          if(noXD > MAX_DIV){
              xIncrement = (size.width/nX)*xIncrement/MAX_DIV
              noXD = MAX_DIV
          }
      }

      var xMarkerLocations = [Float]()
      var xM = origin.x
      if size.width > 0 {
          while xM<=size.width {
              if(xM+xIncrement<0.0 || xM<0.0) {
                  xM = xM+xIncrement
                  continue
              }
              xMarkerLocations.append(xM)
              xM = xM + xIncrement
          }

          xM = origin.x - xIncrement
          while xM>0.0 {
              if (xM > size.width) {
                  xM = xM - xIncrement
                  continue
              }
              xMarkerLocations.append(xM)
              xM = xM - xIncrement
          }
      }
      let xMarkerLabels = xMarkerLocations.map { offset -> String in
        let offsetValue = scaleX * (offset - origin.x)
        return "\(roundToN(offsetValue + Float(originValue.x), xIncRound))"
      }

      var yMarkerLocations = [Float]()
      var yM = origin.y
      if size.height > 0 {
          while yM<=size.height {
              if(yM+yIncrement<0.0 || yM<0.0){
                  yM = yM + yIncrement
                  continue
              }
              yMarkerLocations.append(yM)
              yM = yM + yIncrement
          }
          yM = origin.y - yIncrement
          while yM>0.0 {
              yMarkerLocations.append(yM)
              yM = yM - yIncrement
          }
      }
      let yMarkerLabels = yMarkerLocations.map { offset -> String in
        let offsetValue = scaleY * (offset - origin.y)
        return "\(roundToN(offsetValue + Float(originValue.y), yIncRound))"
      }
      
      return (x: xMarkerLocations, xLabels: xMarkerLabels,
              y: yMarkerLocations, yLabels: yMarkerLabels)
    }
    
    func convertCoordinate(fromData value: Pair<T,U>) -> Point {
      return Point(Float(((value.x - originValue.x) / T(scaleX)) + T(origin.x)),
                   Float(((value.y - originValue.y) / U(scaleY)) + U(origin.y)))
    }
    
    mutating func mergeXAxis(with other: inout AxisLayoutInfo) {
      bounds.x =
        min(bounds.x.lowerBound, other.bounds.x.lowerBound)...max(bounds.x.upperBound, other.bounds.x.upperBound)
      other.bounds.x = self.bounds.x
      boundsDidChange()
      other.boundsDidChange()
    }
  }
}
