import Foundation

// class defining a lineGraph and all its logic
public class LineGraph<T:FloatConvertible,U:FloatConvertible>: Plot {

    let MAX_DIV: Float = 50

    public var layout: GraphLayout

    public var plotLineThickness: Float = 1.5

    var primaryAxis = Axis<T,U>()
    var secondaryAxis: Axis<T,U>? = nil

    public convenience init(points : [Pair<T,U>],
                width: Float = 1000,
                height: Float = 660,
                enablePrimaryAxisGrid: Bool = false,
                enableSecondaryAxisGrid: Bool = false){
        self.init(width: width, height: height,
                  enablePrimaryAxisGrid: enablePrimaryAxisGrid, enableSecondaryAxisGrid: enableSecondaryAxisGrid)

        let s = Series<T,U>(values: points,label: "Plot")
        primaryAxis.series.append(s)
    }

    public init(width: Float = 1000,
                height: Float = 660,
                enablePrimaryAxisGrid: Bool = false,
                enableSecondaryAxisGrid: Bool = false){
        layout = GraphLayout(size: Size(width: width, height: height))
        self.enablePrimaryAxisGrid = enablePrimaryAxisGrid
        self.enableSecondaryAxisGrid = enableSecondaryAxisGrid
    }
    
    public var enablePrimaryAxisGrid: Bool {
        get { layout.enablePrimaryAxisGrid }
        set { layout.enablePrimaryAxisGrid = newValue }
    }
    
    public var enableSecondaryAxisGrid: Bool {
        get { layout.enableSecondaryAxisGrid }
        set { layout.enableSecondaryAxisGrid = newValue }
    }

    // functions to add series
    public func addSeries(_ s: Series<T,U>,
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
    public func addSeries(points : [Pair<T,U>],
                          label: String, color: Color = Color.lightBlue,
                          axisType: Axis<T,U>.Location = .primaryAxis){
        let s = Series<T,U>(values: points,label: label, color: color)
        addSeries(s, axisType: axisType)
    }
    public func addSeries(_ y: [U],
                          label: String,
                          color: Color = Color.lightBlue,
                        axisType: Axis<T,U>.Location = .primaryAxis){
        var points = [Pair<T,U>]()
        for i in 0..<y.count {
            points.append(Pair<T,U>(T(i+1), y[i]))
        }
        let s = Series<T,U>(values: points, label: label, color: color)
        addSeries(s, axisType: axisType)
    }
    public func addSeries(_ x: [T],
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
    public func addFunction(_ function: (T)->U,
                            minX: T,
                            maxX: T,
                            numberOfSamples: Int = 400,
                            label: String,
                            color: Color = Color.lightBlue,
                            axisType: Axis<T,U>.Location = .primaryAxis) {
        var x = [T]()
        var y = [U]()
        let step = Float(maxX - minX)/Float(numberOfSamples)
        var r: Float = 0.0
        for i in stride(from: Float(minX), through: Float(maxX), by: step) {
            r = Float(function(T(i)))
            if (r.isNaN || r.isInfinite) {
                continue
            }
            x.append(T(i))
            y.append(clamp(U(r), minValue: U(-1.0/step), maxValue: U(1.0/step)))
            // y.append(r)
        }
        var points = [Pair<T,U>]()
        for i in 0..<x.count {
            points.append(Pair<T,U>(x[i], y[i]))
        }
        let s = Series<T,U>(values: points, label: label, color: color)
        addSeries(s, axisType: axisType)
    }
}

// extension containing drawing logic
extension LineGraph: HasGraphLayout {

    public var legendLabels: [(String, LegendIcon)] {
        var allSeries: [Series] = primaryAxis.series
        if (secondaryAxis != nil) {
            allSeries = allSeries + secondaryAxis!.series
        }
        return allSeries.map { ($0.label, .square($0.color)) }
    }

    // functions implementing plotting logic
    public func calculateScaleAndMarkerLocations(markers: inout PlotMarkers, size: Size, renderer: Renderer) {

        var maximumXPrimary: T = maxX(points: primaryAxis.series[0].values)
        var maximumYPrimary: U = maxY(points: primaryAxis.series[0].values)
        var minimumXPrimary: T = minX(points: primaryAxis.series[0].values)
        var minimumYPrimary: U = minY(points: primaryAxis.series[0].values)

        for index in 1..<primaryAxis.series.count {

            let s: Series<T,U> = primaryAxis.series[index]

            var x: T = maxX(points: s.values)
            var y: U = maxY(points: s.values)
            if (x > maximumXPrimary) {
                maximumXPrimary = x
            }
            if (y > maximumYPrimary) {
                maximumYPrimary = y
            }
            x = minX(points: s.values)
            y = minY(points: s.values)
            if (x < minimumXPrimary) {
                minimumXPrimary = x
            }
            if (y < minimumYPrimary) {
                minimumYPrimary = y
            }
        }

        var maximumXSecondary = T(0)
        var maximumYSecondary = U(0)
        var minimumXSecondary = T(0)
        var minimumYSecondary = U(0)

        if secondaryAxis != nil {

            maximumXSecondary = maxX(points: secondaryAxis!.series[0].values)
            maximumYSecondary = maxY(points: secondaryAxis!.series[0].values)
            minimumXSecondary = minX(points: secondaryAxis!.series[0].values)
            minimumYSecondary = minY(points: secondaryAxis!.series[0].values)
            for index in 1..<secondaryAxis!.series.count {
                let s: Series<T,U> = secondaryAxis!.series[index]

                var x: T = maxX(points: s.values)
                var y: U = maxY(points: s.values)
                if (x > maximumXSecondary) {
                    maximumXSecondary = x
                }
                if (y > maximumYSecondary) {
                    maximumYSecondary = y
                }
                x = minX(points: s.values)
                y = minY(points: s.values)
                if (x < minimumXSecondary) {
                    minimumXSecondary = x
                }
                if (y < minimumYSecondary) {
                    minimumYSecondary = y
                }
            }
            maximumXPrimary = max(maximumXPrimary, maximumXSecondary)
            minimumXPrimary = min(minimumXPrimary, minimumXSecondary)
        }

        let rightScaleMargin: Float = size.width * 0.05
        let topScaleMargin: Float = size.height * 0.05
        var originPrimaryX: Float = (size.width/Float(maximumXPrimary-minimumXPrimary))*Float(T(-1)*minimumXPrimary)
        var originPrimaryY: Float = (size.height/Float(maximumYPrimary-minimumYPrimary))*Float(U(-1)*minimumYPrimary)
        if(minimumXPrimary >= T(0)) {
            originPrimaryX+=rightScaleMargin
        }
        if(minimumYPrimary >= U(0)) {
            originPrimaryY+=topScaleMargin
        }
        let originPrimary = Point(originPrimaryX, originPrimaryY)
        primaryAxis.scaleX = Float(maximumXPrimary - minimumXPrimary) / (size.width - 2*rightScaleMargin);
        primaryAxis.scaleY = Float(maximumYPrimary - minimumYPrimary) / (size.height - 2*topScaleMargin);

        var originSecondary: Point? = nil
        if (secondaryAxis != nil) {
            var originSecondaryX: Float = (size.width/Float(maximumXSecondary-minimumXSecondary))*Float(T(-1)*minimumXSecondary)
            var originSecondaryY: Float = (size.height/Float(maximumYSecondary-minimumYSecondary))*Float(U(-1)*minimumYSecondary)
            if(minimumXSecondary >= T(0)) {
                originSecondaryX+=rightScaleMargin
            }
            if(minimumYSecondary >= U(0)) {
                originSecondaryY+=topScaleMargin
            }
            originSecondary = Point(originSecondaryX, originSecondaryY)
            secondaryAxis!.scaleX = Float(maximumXSecondary - minimumXSecondary) / (size.width - 2*rightScaleMargin);
            secondaryAxis!.scaleY = Float(maximumYSecondary - minimumYSecondary) / (size.height - 2*topScaleMargin);
        }

        //calculations for primary axis
        var inc1Primary: Float = -1
        var inc2Primary: Float = -1
        var xIncRound: Int   = 1
        var yIncRoundPrimary: Int = 1
        var yIncRoundSecondary: Int = 1
        // var inc2Primary: Float
        if(Float(maximumYPrimary-minimumYPrimary)<=2.0 && Float(maximumYPrimary-minimumYPrimary)>=1.0) {
          let differenceY = Float(maximumYPrimary-minimumYPrimary)
          inc1Primary = 0.5*(1.0/differenceY)
          var c = 0
          while(abs(inc1Primary)*pow(10.0,Float(c))<1.0) {
            c+=1
          }
          inc1Primary = inc1Primary/primaryAxis.scaleY
          yIncRoundPrimary = c+1
        }
        else if(Float(maximumYPrimary-minimumYPrimary)<1.0) {
          let differenceY = Float(maximumYPrimary-minimumYPrimary)
          inc1Primary = differenceY/10.0
          var c = 0
          while(abs(inc1Primary)*pow(10.0,Float(c))<1.0) {
            c+=1
          }
          inc1Primary = inc1Primary/primaryAxis.scaleY
          yIncRoundPrimary = c+1
        }
        if(Float(maximumXPrimary-minimumXPrimary)<=2.0 && Float(maximumXPrimary-minimumXPrimary)>=1.0) {
          let differenceX = Float(maximumXPrimary-minimumXPrimary)
          inc2Primary = 0.5*(1.0/differenceX)
          var c = 0
          while(abs(inc2Primary)*pow(10.0,Float(c))<1.0) {
            c+=1
          }
          inc2Primary = inc1Primary/primaryAxis.scaleX
          xIncRound = c+1
        }
        if(Float(maximumXPrimary-minimumXPrimary)<1.0) {
          let differenceX = Float(maximumXPrimary-minimumXPrimary)
          inc2Primary = differenceX/10
          var c = 0
          while(abs(inc2Primary)*pow(10.0,Float(c))<1.0) {
            c+=1
          }
          inc2Primary = inc1Primary/primaryAxis.scaleX
          xIncRound = c+1
        }
        var nD1: Int = max(getNumberOfDigits(Float(maximumYPrimary)), getNumberOfDigits(Float(minimumYPrimary)))
        var v1: Float
        if (nD1 > 1 && maximumYPrimary <= U(pow(Float(10), Float(nD1 - 1)))) {
            v1 = Float(pow(Float(10), Float(nD1 - 2)))
        } else if (nD1 > 1) {
            v1 = Float(pow(Float(10), Float(nD1 - 1)))
        } else {
            v1 = Float(pow(Float(10), Float(0)))
        }
        var nY: Float = v1/primaryAxis.scaleY
        if(inc1Primary == -1) {
            inc1Primary = nY
            if(size.height/nY > MAX_DIV){
                inc1Primary = (size.height/nY)*inc1Primary/MAX_DIV
            }
        }

        let nD2: Int = max(getNumberOfDigits(Float(maximumXPrimary)), getNumberOfDigits(Float(minimumXPrimary)))
        var v2: Float
        if (nD2 > 1 && maximumXPrimary <= T(pow(Float(10), Float(nD2 - 1)))) {
            v2 = Float(pow(Float(10), Float(nD2 - 2)))
        } else if (nD2 > 1) {
            v2 = Float(pow(Float(10), Float(nD2 - 1)))
        } else {
            v2 = Float(pow(Float(10), Float(0)))
        }

        let nX: Float = v2/primaryAxis.scaleX
        if(inc2Primary == -1) {
            inc2Primary = nX
            var noXD: Float = size.width/nX
            if(noXD > MAX_DIV){
                inc2Primary = (size.width/nX)*inc2Primary/MAX_DIV
                noXD = MAX_DIV
            }
        }

        var xM = originPrimary.x
        while xM<=size.width {
            if(xM+inc2Primary<0.0 || xM<0.0) {
                xM = xM+inc2Primary
                continue
            }
            markers.xMarkers.append(xM)
            markers.xMarkersText.append("\(roundToN(primaryAxis.scaleX*(xM-originPrimary.x), xIncRound))")
            xM = xM + inc2Primary
        }

        xM = originPrimary.x - inc2Primary
        while xM>0.0 {
            if (xM > size.width) {
                xM = xM - inc2Primary
                continue
            }
            markers.xMarkers.append(xM)
            markers.xMarkersText.append("\(roundToN(primaryAxis.scaleX*(xM-originPrimary.x), xIncRound))")
            xM = xM - inc2Primary
        }

        var yM = originPrimary.y
        while yM<=size.height {
            if(yM+inc1Primary<0.0 || yM<0.0){
                yM = yM + inc1Primary
                continue
            }
            markers.yMarkers.append(yM)
            markers.yMarkersText.append("\(roundToN(primaryAxis.scaleY*(yM-originPrimary.y), yIncRoundPrimary))")
            yM = yM + inc1Primary
        }
        yM = originPrimary.y - inc1Primary
        while yM>0.0 {
            markers.yMarkers.append(yM)
            markers.yMarkersText.append("\(roundToN(primaryAxis.scaleY*(yM-originPrimary.y), yIncRoundPrimary))")
            yM = yM - inc1Primary
        }



        // scale points to be plotted according to plot size
        let scaleXInvPrimary: Float = 1.0/primaryAxis.scaleX;
        let scaleYInvPrimary: Float = 1.0/primaryAxis.scaleY
        for i in 0..<primaryAxis.series.count {
            primaryAxis.series[i].scaledValues.removeAll();
            for j in 0..<primaryAxis.series[i].count {
                let scaledPair = Pair<T,U>(((primaryAxis.series[i])[j].x)*T(scaleXInvPrimary) + T(originPrimary.x),
                                           ((primaryAxis.series[i])[j].y)*U(scaleYInvPrimary) + U(originPrimary.y))
                if (0...size.width).contains(Float(scaledPair.x)) && (0...size.height).contains(Float(scaledPair.y)) {
                    primaryAxis.series[i].scaledValues.append(scaledPair)
                }
            }
        }

        //calculations for secondary axis
        if (secondaryAxis != nil) {
            var inc1Secondary: Float = -1
            if(Float(maximumYSecondary-minimumYSecondary)<=2.0){
              let differenceY = Float(maximumYSecondary-minimumYSecondary)
              inc1Secondary = 0.5*(1.0/differenceY)
              var c = 0
              while(abs(inc1Secondary)*pow(10.0,Float(c))<1.0){
                c+=1
              }
              inc1Secondary = inc1Secondary/secondaryAxis!.scaleY
              yIncRoundSecondary = c+1
            }

            nD1 = max(getNumberOfDigits(Float(maximumYSecondary)), getNumberOfDigits(Float(minimumYSecondary)))
            if (nD1 > 1 && maximumYSecondary <= U(pow(Float(10), Float(nD1 - 1)))) {
                v1 = Float(pow(Float(10), Float(nD1 - 2)))
            } else if (nD1 > 1) {
                v1 = Float(pow(Float(10), Float(nD1 - 1)))
            } else {
                v1 = Float(pow(Float(10), Float(0)))
            }

            nY = v1/secondaryAxis!.scaleY
            if(inc1Secondary == -1) {
                inc1Secondary = nY
                if(size.height/nY > MAX_DIV){
                    inc1Secondary = (size.height/nY)*inc1Secondary/MAX_DIV
                }
            }
            yM = originSecondary!.y

            while yM<=size.height {
                if(yM+inc1Secondary<0.0 || yM<0.0){
                    yM = yM + inc1Secondary
                    continue
                }
                markers.y2Markers.append(yM)
                markers.y2MarkersText.append("\(roundToN(secondaryAxis!.scaleY*(yM-originSecondary!.y), yIncRoundSecondary))")
                yM = yM + inc1Secondary
            }
            yM = originSecondary!.y - inc1Secondary
            while yM>0.0 {
                markers.y2Markers.append(yM)
                markers.y2MarkersText.append("\(roundToN(secondaryAxis!.scaleY*(yM-originSecondary!.y), yIncRoundSecondary))")
                yM = yM - inc1Secondary
            }



            // scale points to be plotted according to plot size
            let scaleYInvSecondary: Float = 1.0/secondaryAxis!.scaleY
            for i in 0..<secondaryAxis!.series.count {
                // let pairs = secondaryAxis!.series[i].pairs
                secondaryAxis!.series[i].scaledValues.removeAll();
                for j in 0..<secondaryAxis!.series[i].count {
                    let scaledPair = Pair<T,U>(((secondaryAxis!.series[i])[j].x)*T(scaleXInvPrimary) + T(originPrimary.x),
                                               ((secondaryAxis!.series[i])[j].y)*U(scaleYInvSecondary) + U(originSecondary!.y))
                    if (Float(scaledPair.x) >= 0.0 && Float(scaledPair.x) <= size.width && Float(scaledPair.y) >= 0.0 && Float(scaledPair.y) <= size.height) {
                        secondaryAxis!.series[i].scaledValues.append(scaledPair)
                    }
                }
            }
        }
    }

    //functions to draw the plot
    public func drawData(markers: PlotMarkers, size: Size, renderer: Renderer) {
        for s in primaryAxis.series {
            var points = [Point]()
            for p in s.scaledValues {
                points.append(Point(Float(p.x),Float(p.y)))
            }
            renderer.drawPlotLines(points: points,
                                   strokeWidth: plotLineThickness,
                                   strokeColor: s.color,
                                   isDashed: false)
        }
        if (secondaryAxis != nil) {
            for s in secondaryAxis!.series {
                var points = [Point]()
                for p in s.scaledValues {
                    points.append(Point(Float(p.x),Float(p.y)))
                }
                renderer.drawPlotLines(points: points,
                                       strokeWidth: plotLineThickness,
                                       strokeColor: s.color,
                                       isDashed: true)
            }
        }
    }
}
