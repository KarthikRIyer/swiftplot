import Foundation

// class defining a lineGraph and all its logic
public class ScatterPlot<T:FloatConvertible,U:FloatConvertible>: Plot {

    let MAX_DIV: Float = 50

    let sqrt3: Float = sqrt(3)

    public var layout = GraphLayout()
    
    // public var plotLineThickness: Float = 3
    public var scatterPatternSize: Float = 10

    var series = [Series<T,U>]()
    var series_scaledValues = [[Pair<T,U>]]()
    var series_maxY: U? = nil
    var series_minY: U? = nil
    var scaleX: Float = 1
    var scaleY: Float = 1

    public convenience init(points p: [Pair<T,U>],
                            enableGrid: Bool = false){
        self.init(enableGrid: enableGrid)
        let s = Series<T,U>(values: p,label: "Plot")
        series.append(s)
    }

    public init(enableGrid: Bool = false){
        self.enableGrid = enableGrid
    }
    
    public var enableGrid: Bool {
        get { layout.enablePrimaryAxisGrid }
        set { layout.enablePrimaryAxisGrid = newValue }
    }

    // functions to add series
    public func addSeries(_ s: Series<T,U>){
        series.append(s)
    }
    public func addSeries(points: [Pair<T,U>],
                          label: String,
                          color: Color = .lightBlue,
                          scatterPattern: ScatterPlotSeriesOptions.ScatterPattern = .circle){
        let s = Series(values: points,label: label, color: color, scatterPattern: scatterPattern)
        addSeries(s)
    }
    public func addSeries(_ x: [T],
                          _ y: [U],
                          label: String,
                          color: Color = .lightBlue,
                          scatterPattern: ScatterPlotSeriesOptions.ScatterPattern = .circle){
        var points = [Pair<T,U>]()
        for i in 0..<x.count {
            points.append(Pair<T,U>(x[i], y[i]))
        }
        let s = Series(values: points,
                       label: label,
                       color: color,
                       scatterPattern: scatterPattern)
        addSeries(s)
    }
    public func addSeries(_ x: [T],
                          _ y: [U],
                          label: String,
                          startColor: Color = .lightBlue,
                          endColor: Color = .lightBlue,
                          scatterPattern: ScatterPlotSeriesOptions.ScatterPattern = .circle){
        var points = [Pair<T,U>]()
        for i in 0..<x.count {
            points.append(Pair<T,U>(x[i], y[i]))
        }
        let s = Series(values: points,
                       label: label,
                       startColor: startColor,
                       endColor: endColor,
                       scatterPattern: scatterPattern)
        addSeries(s)
    }
    public func addSeries(_ y: [U],
                          label: String,
                          color: Color = .lightBlue,
                          scatterPattern: ScatterPlotSeriesOptions.ScatterPattern = .circle){
        var points = [Pair<T,U>]()
        for i in 0..<y.count {
            points.append(Pair<T,U>(T(i+1), y[i]))
        }
        let s = Series(values: points,
                       label: label,
                       color: color,
                       scatterPattern: scatterPattern)
        addSeries(s)
    }
    public func addSeries(_ y: [U],
                          label: String,
                          startColor: Color = .lightBlue,
                          endColor: Color = .lightBlue,
                          scatterPattern: ScatterPlotSeriesOptions.ScatterPattern = .circle){
        var points = [Pair<T,U>]()
        for i in 0..<y.count {
            points.append(Pair<T,U>(T(i+1), y[i]))
        }
        let s = Series(values: points,
                       label: label,
                       startColor: startColor,
                       endColor: endColor,
                       scatterPattern: scatterPattern)
        addSeries(s)
    }
}

// extension containing drawing logic
extension ScatterPlot: HasGraphLayout {

    public var legendLabels: [(String, LegendIcon)] {
        return series.map {
            ($0.label, .shape($0.scatterPlotSeriesOptions.scatterPattern, $0.startColor ?? $0.color))
        }
    }
    
    public struct DrawingData {
        
    }

    // functions implementing plotting logic
    public func layoutData(size: Size, renderer: Renderer) -> (DrawingData, PlotMarkers?) {
        
        var results = DrawingData()
        var markers = PlotMarkers()
        
        var maximumX: T = maxX(points: series[0].values)
        var maximumY: U = maxY(points: series[0].values)
        var minimumX: T = minX(points: series[0].values)
        var minimumY: U = minY(points: series[0].values)

        for index in 1..<series.count {

            let s: Series<T,U> = series[index]
            var x: T = maxX(points: s.values)
            var y: U = maxY(points: s.values)
            if (x > maximumX) {
                maximumX = x
            }
            if (y > maximumY) {
                maximumY = y
            }
            x = minX(points: s.values)
            y = minY(points: s.values)
            if (x < minimumX) {
                minimumX = x
            }
            if (y < minimumY) {
                minimumY = y
            }
        }

        let origin = Point((size.width/Float(maximumX-minimumX))*Float(T(-1)*minimumX),
                           (size.height/Float(maximumY-minimumY))*Float(U(-1)*minimumY))

        let rightScaleMargin: Float = size.width * 0.2
        let topScaleMargin: Float = size.height * 0.2
        scaleX = Float(maximumX - minimumX) / (size.width - rightScaleMargin);
        scaleY = Float(maximumY - minimumY) / (size.height - topScaleMargin);

        var inc1: Float = -1
        var inc2: Float = -1
        var yIncRound: Int = 1
        var xIncRound: Int = 1
        if(Float(maximumY-minimumY)<=2.0 && Float(maximumY-minimumY)>=1.0) {
            let differenceY = Float(maximumY-minimumY)
            inc1 = 0.5*(1.0/differenceY)
            var c = 0
            while(abs(inc1)*pow(10.0,Float(c))<1.0) {
                c+=1
            }
            inc1 = inc1/scaleY
            yIncRound = c+1
        }
        if(Float(maximumY-minimumY)<1.0) {
            let differenceY = Float(maximumY-minimumY)
            inc1 = differenceY/10.0
            var c = 0
            while(abs(inc1)*pow(10.0,Float(c))<1.0) {
                c+=1
            }
            inc1 = inc1/scaleY
            yIncRound = c+1
        }
        if(Float(maximumX-minimumX)<=2.0 && Float(maximumX-minimumX)>=1.0) {
            let differenceX = Float(maximumX-minimumX)
            inc1 = 0.5*(1.0/differenceX)
            var c = 0
            while(abs(inc2)*pow(10.0,Float(c))<1.0) {
                c+=1
            }
            inc2 = inc2/scaleX
            xIncRound = c+1
        }
        else if(Float(maximumX-minimumX)<1.0) {
            let differenceX = Float(maximumX-minimumX)
            inc1 = differenceX/10.0
            var c = 0
            while(abs(inc2)*pow(10.0,Float(c))<1.0) {
                c+=1
            }
            inc2 = inc2/scaleX
            xIncRound = c+1
        }

        let nD1: Int = max(getNumberOfDigits(Float(maximumY)), getNumberOfDigits(Float(minimumY)))
        var v1: Float
        if (nD1 > 1 && maximumY <= U(pow(Float(10), Float(nD1 - 1)))) {
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

        let nD2: Int = max(getNumberOfDigits(Float(maximumX)), getNumberOfDigits(Float(minimumX)))
        var v2: Float
        if (nD2 > 1 && maximumX <= T(pow(Float(10), Float(nD2 - 1)))) {
            v2 = Float(pow(Float(10), Float(nD2 - 2)))
        } else if (nD2 > 1) {
            v2 = Float(pow(Float(10), Float(nD2 - 1)))
        } else {
            v2 = Float(pow(Float(10), Float(0)))
        }

        if(inc2 == -1) {
            let nX: Float = v2/scaleX
            inc2 = nX
            var noXD: Float = size.width/nX
            if(noXD > MAX_DIV){
                inc2 = (size.width/nX)*inc2/MAX_DIV
                noXD = MAX_DIV
            }
        }

        var xM = Float(origin.x)
        while xM<=size.width {
            if(xM+inc2<0.0 || xM<0.0) {
                xM = xM+inc2
                continue
            }
            markers.xMarkers.append(xM)
            markers.xMarkersText.append("\(roundToN(scaleX*(xM-origin.x), xIncRound))")
            xM = xM + inc2
        }

        xM = origin.x - inc2
        while xM>0.0 {
            if (xM > size.width) {
                xM = xM - inc2
                continue
            }
            markers.xMarkers.append(xM)
            markers.xMarkersText.append("\(roundToN(scaleX*(xM-origin.x), xIncRound))")
            xM = xM - inc2
        }

        var yM = origin.y
        while yM<=size.height {
            if(yM+inc1<0.0 || yM<0.0){
                yM = yM + inc1
                continue
            }
            markers.yMarkers.append(yM)
            markers.yMarkersText.append("\(ceilToN(scaleY*(yM-origin.y), yIncRound))")
            yM = yM + inc1
        }
        yM = origin.y - inc1
        while yM>0.0 {
            markers.yMarkers.append(yM)
            markers.yMarkersText.append("\(floorToN(scaleY*(yM-origin.y), xIncRound))")
            yM = yM - inc1
        }



        // scale points to be plotted according to plot size
        let scaleXInv: Float = 1.0/scaleX;
        let scaleYInv: Float = 1.0/scaleY
        series_scaledValues = series.map { series in
            series.values.compactMap { value in
                let scaledPair = Pair<T,U>(value.x * T(scaleXInv) + T(origin.x),
                                           value.y * U(scaleYInv) + U(origin.y))
                guard Float(scaledPair.x) >= 0.0 && Float(scaledPair.x) <= size.width
                    && Float(scaledPair.y) >= 0.0 && Float(scaledPair.y) <= size.height else {
                    return nil
                }
                return scaledPair
            }
        }
        
        return (results, markers)
    }

    //functions to draw the plot
    public func drawData(_ data: DrawingData, size: Size, renderer: Renderer) {
        for seriesIndex in 0..<series.count {
            let s = series[seriesIndex]
            let scaledValues = series_scaledValues[seriesIndex]
            series_maxY = maxY(points: scaledValues)
            series_minY = minY(points: scaledValues)
            let seriesYRangeInverse: Float = 1.0/Float(series_maxY!-series_minY!)

            for value in scaledValues {
                let p = Point(Float(value.x),Float(value.y))
                var color: Color
                if let startColor = s.startColor, let endColor = s.endColor {
                    color = lerp(startColor: startColor,
                                 endColor: endColor,
                                 Float(value.y-series_minY!)*seriesYRangeInverse)
                } else {
                    color = s.color
                }
                switch s.scatterPlotSeriesOptions.scatterPattern {
                case .circle:
                        renderer.drawSolidCircle(center: p,
                                                 radius: scatterPatternSize*Float(0.5),
                                                 fillColor: color)
                case .square:
                    let rect = Rect(size: Size(width: scatterPatternSize, height: scatterPatternSize),
                                    centeredOn: p)
                    renderer.drawSolidRect(rect,
                                           fillColor: color,
                                           hatchPattern: .none)
                case .triangle:
                    let r = scatterPatternSize/sqrt3
                    let p = Point(Float(value.x),Float(value.y))
                    let p1 = Point(p.x + 0,
                                   p.y + r)
                    let p2 = Point(p.x + r*sqrt3/Float(2),
                                   p.y - r*Float(0.5))
                    let p3 = Point(p.x - r*sqrt3/Float(2),
                                   p.y - r*Float(0.5))
                    renderer.drawSolidTriangle(point1: p1,
                                               point2: p2,
                                               point3: p3,
                                               fillColor: color)
                case .diamond:
                    var tL = Point(p.x-scatterPatternSize*Float(0.5),
                                   p.y+scatterPatternSize*Float(0.5))
                    var tR = Point(p.x+scatterPatternSize*Float(0.5),
                                   p.y+scatterPatternSize*Float(0.5))
                    var bR = Point(p.x+scatterPatternSize*Float(0.5),
                                   p.y-scatterPatternSize*Float(0.5))
                    var bL = Point(p.x-scatterPatternSize*Float(0.5),
                                   p.y-scatterPatternSize*Float(0.5))
                    tL = rotatePoint(point: tL, center: p, angleDegrees: 45.0)
                    tR = rotatePoint(point: tR, center: p, angleDegrees: 45.0)
                    bL = rotatePoint(point: bL, center: p, angleDegrees: 45.0)
                    bR = rotatePoint(point: bR, center: p, angleDegrees: 45.0)
                    let diamondPoints: [Point] = [tL, tR, bR, bL]
                    renderer.drawSolidPolygon(points: diamondPoints,
                                              fillColor: color)
                case .hexagon:
                    var hexagonPoint = Point(p.x + 0.0,
                                             p.y + scatterPatternSize*Float(0.5))
                    var hexagonPoints: [Point] = [hexagonPoint]
                    for _ in 2...6 {
                        hexagonPoint = rotatePoint(point: hexagonPoint,
                                                   center: p,
                                                   angleDegrees: 60.0)
                        hexagonPoints.append(hexagonPoint)
                    }
                    renderer.drawSolidPolygon(points: hexagonPoints,
                                              fillColor: color)
                case .pentagon:
                    var pentagonPoint = Point(p.x + 0.0,
                                              p.y + scatterPatternSize*Float(0.5))
                    var pentagonPoints: [Point] = [pentagonPoint]
                    for _ in 2...6 {
                        pentagonPoint = rotatePoint(point: pentagonPoint,
                                                    center: p,
                                                    angleDegrees: 72.0)
                        pentagonPoints.append(pentagonPoint)
                    }
                    renderer.drawSolidPolygon(points: pentagonPoints,
                                              fillColor: color)

                case .star:
                    var starOuterPoint = Point(p.x + 0.0,
                                               p.y + scatterPatternSize*Float(0.5))
                    var starInnerPoint = rotatePoint(point: Point(p.x + 0.0,
                                                                  p.y + scatterPatternSize*Float(0.25)),
                                                     center: p,
                                                     angleDegrees: 36.0)
                    var starPoints: [Point] = [starOuterPoint, starInnerPoint]
                    for _ in 2...6 {
                        starInnerPoint = rotatePoint(point: starInnerPoint,
                                                     center: p,
                                                     angleDegrees: 72.0)
                        starOuterPoint = rotatePoint(point: starOuterPoint,
                                                     center: p,
                                                     angleDegrees: 72.0)
                        starPoints.append(starOuterPoint)
                        starPoints.append(starInnerPoint)
                    }
                    renderer.drawSolidPolygon(points: starPoints,
                                              fillColor: color)
                }
            }
        }
    }
}

extension ScatterPlotSeriesOptions.ScatterPattern {
    
    static let sqrt3: Float = sqrt(3)

    func draw(in rect: Rect, color: Color, renderer: Renderer) {
        let tL = Point(rect.minX, rect.maxY)
        let bR = Point(rect.maxX, rect.minY)
        let tR = Point(bR.x, tL.y)
        let bL = Point(tL.x, bR.y)
        
        switch self {
        case .circle:
            let c = Point((tL.x+bR.x)*Float(0.5),
                          (tL.y+bR.y)*Float(0.5))
            renderer.drawSolidCircle(center: c,
                                     radius: (tR.x-tL.x)*Float(0.5),
                                     fillColor: color)
        case .square:
            renderer.drawSolidRect(rect,
                                   fillColor: color,
                                   hatchPattern: .none)
        case .triangle:
            let c = Point((tL.x+bR.x)*Float(0.5),
                          (tL.y+bR.y)*Float(0.5))
            let r: Float = (tR.x-tL.x)*Float(0.5)
            let p1 = Point(c.x + 0,
                           c.y + r)
            let p2 = Point(c.x + r*Self.sqrt3*Float(0.5),
                           c.y - r*Float(0.5))
            let p3 = Point(c.x - r*Self.sqrt3*Float(0.5),
                           c.y - r*Float(0.5))
            renderer.drawSolidTriangle(point1: p1,
                                       point2: p2,
                                       point3: p3,
                                       fillColor: color)
        case .diamond:
            let c = Point((tL.x+bR.x)*Float(0.5),
                          (tL.y+bR.y)*Float(0.5))
            let p1 = rotatePoint(point: tL, center: c, angleDegrees: 45.0)
            let p2 = rotatePoint(point: tR, center: c, angleDegrees: 45.0)
            let p3 = rotatePoint(point: bR, center: c, angleDegrees: 45.0)
            let p4 = rotatePoint(point: bL, center: c, angleDegrees: 45.0)
            let diamondPoints: [Point] = [p1, p2, p3, p4]
            renderer.drawSolidPolygon(points: diamondPoints,
                                      fillColor: color)
        case .hexagon:
            let c = Point((tL.x+bR.x)*Float(0.5),
                          (tL.y+bR.y)*Float(0.5))
            var hexagonPoint = Point(c.x + 0.0,
                                     c.y + (tL.y-bL.y)*Float(0.5))
            var hexagonPoints: [Point] = [hexagonPoint]
            for _ in 2...6 {
                hexagonPoint = rotatePoint(point: hexagonPoint,
                                           center: c,
                                           angleDegrees: 60.0)
                hexagonPoints.append(hexagonPoint)
            }
            renderer.drawSolidPolygon(points: hexagonPoints,
                                      fillColor: color)
        case .pentagon:
            let c = Point((tL.x+bR.x)*Float(0.5),
                          (tL.y+bR.y)*Float(0.5))
            var pentagonPoint = Point(c.x + 0.0,
                                      c.y + (tL.y-bL.y)*Float(0.5))
            var pentagonPoints: [Point] = [pentagonPoint]
            for _ in 2...6 {
                pentagonPoint = rotatePoint(point: pentagonPoint,
                                            center: c,
                                            angleDegrees: 72.0)
                pentagonPoints.append(pentagonPoint)
            }
            renderer.drawSolidPolygon(points: pentagonPoints,
                                      fillColor: color)
        case .star:
            let c = Point((tL.x+bR.x)*Float(0.5),
                          (tL.y+bR.y)*Float(0.5))
            var starOuterPoint = Point(c.x + 0.0,
                                       c.y + (tL.y-bL.y)*Float(0.5))
            var starInnerPoint = rotatePoint(point: Point(c.x + 0.0,
                                                          c.y + (tL.y-bL.y)*Float(0.25)),
                                             center: c,
                                             angleDegrees: 36.0)
            var starPoints: [Point] = [starOuterPoint, starInnerPoint]
            for _ in 2...6 {
                starOuterPoint = rotatePoint(point: starOuterPoint,
                                             center: c,
                                             angleDegrees: 72.0)
                starInnerPoint = rotatePoint(point: starInnerPoint,
                                             center: c,
                                             angleDegrees: 72.0)
                starPoints.append(starOuterPoint)
                starPoints.append(starInnerPoint)
            }
            renderer.drawSolidPolygon(points: starPoints,
                                      fillColor: color)
        }
    }
}
