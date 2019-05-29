import Foundation

// class defining a lineGraph and all its logic
public class LineGraph: Plot {

	let MAX_DIV: Float = 50

	public var xOffset: Float = 0
	public var yOffset: Float = 0

	public var plotTitle: PlotTitle = PlotTitle()
	public var plotLabel: PlotLabel = PlotLabel()
	public var plotLegend: PlotLegend = PlotLegend()
	public var plotBorder: PlotBorder = PlotBorder()
	public var plotDimensions: PlotDimensions {
		willSet{
			plotBorder.topLeft       = Point(newValue.subWidth*0.1, newValue.subHeight*0.9)
			plotBorder.topRight      = Point(newValue.subWidth*0.9, newValue.subHeight*0.9)
			plotBorder.bottomLeft    = Point(newValue.subWidth*0.1, newValue.subHeight*0.1)
			plotBorder.bottomRight   = Point(newValue.subWidth*0.9, newValue.subHeight*0.1)
			plotLegend.legendTopLeft = Point(plotBorder.topLeft.x + 20, plotBorder.topLeft.y - 20)
		}
	}

	var primaryAxis: Axis = Axis()
	var secondaryAxis: Axis? = nil

	public var plotLineThickness: Float = 3

	public init(points p: [Point], width: Float = 1000, height: Float = 660){
		plotDimensions = PlotDimensions(frameWidth: width, frameHeight: height)
		plotDimensions.calculateGraphDimensions()

		let s = Series(points: p,label: "Plot")
		primaryAxis.series.append(s)
	}

	public init(width: Float = 1000, height: Float = 660){
		plotDimensions = PlotDimensions(frameWidth: width, frameHeight: height)
	}

	// functions to add series
	public func addSeries(_ s: Series, axisType: Int = Axis.PRIMARY_AXIS){
		switch axisType {
			case Axis.PRIMARY_AXIS:
				primaryAxis.series.append(s)
			case Axis.SECONDARY_AXIS:
				if secondaryAxis == nil {
				    secondaryAxis = Axis()
				}
				secondaryAxis!.series.append(s)
			default:
				primaryAxis.series.append(s)
		}
	}
	public func addSeries(points p: [Point], label: String, color: Color = Color.lightBlue, axisType: Int = Axis.PRIMARY_AXIS){
		let s = Series(points: p,label: label, color: color)
		addSeries(s, axisType: axisType)
	}
	public func addSeries(_ x: [Float], _ y: [Float], label: String, color: Color = Color.lightBlue, axisType: Int = Axis.PRIMARY_AXIS){
		var pts = [Point]()
		for i in 0..<x.count {
			pts.append(Point(x[i], y[i]))
		}
		let s = Series(points: pts, label: label, color: color)
		addSeries(s, axisType: axisType)
	}
	public func addSeries(_ y: [Float], label: String, color: Color = Color.lightBlue, axisType: Int = Axis.PRIMARY_AXIS){
		var pts = [Point]()
		for i in 0..<y.count {
			pts.append(Point(i+1, y[i]))
		}
		let s = Series(points: pts, label: label, color: color)
		addSeries(s, axisType: axisType)
	}
	public func addFunction(_ function: (Float)->Float, minX: Float, maxX: Float, numberOfSamples: Int = 400, label: String, color: Color = Color.lightBlue, axisType: Int = Axis.PRIMARY_AXIS) {
		var x = [Float]()
		var y = [Float]()
		let step: Float = (maxX-minX)/Float(numberOfSamples)
		var r: Float = 0
		for i in stride(from: minX, through: maxX, by: step) {
			r = function(i)
			if (r.isNaN || r.isInfinite) {
				continue
			}
			x.append(i)
			y.append(clamp(r, minValue: -1.0/step, maxValue: 1.0/step))
			// y.append(r)
		}
		var pts = [Point]()
		for i in 0..<x.count {
			pts.append(Point(x[i], y[i]))
		}
		let s = Series(points: pts, label: label, color: color)
		addSeries(s, axisType: axisType)
	}
}

// extension containing drawing logic
extension LineGraph{

	// call functions to draw the graph
	public func drawGraphAndOutput(fileName name: String = "swift_plot_line_graph", renderer: Renderer){
		renderer.xOffset = xOffset
		renderer.yOffset = yOffset
		renderer.plotDimensions = plotDimensions
		plotBorder.topLeft       = Point(plotDimensions.subWidth*0.1, plotDimensions.subHeight*0.9)
		plotBorder.topRight      = Point(plotDimensions.subWidth*0.9, plotDimensions.subHeight*0.9)
		plotBorder.bottomLeft    = Point(plotDimensions.subWidth*0.1, plotDimensions.subHeight*0.1)
		plotBorder.bottomRight   = Point(plotDimensions.subWidth*0.9, plotDimensions.subHeight*0.1)
		plotLegend.legendTopLeft = Point(plotBorder.topLeft.x + 20, plotBorder.topLeft.y - 20)
		calcLabelLocations(renderer: renderer)
		calcMarkerLocAndScalePts(renderer: renderer)
		drawBorder(renderer: renderer)
		drawMarkers(renderer: renderer)
		drawPlots(renderer: renderer)
		drawTitle(renderer: renderer)
		drawLabels(renderer: renderer)
		drawLegends(renderer: renderer)
		saveImage(fileName: name, renderer: renderer)
	}

	public func drawGraph(renderer: Renderer){
		renderer.xOffset = xOffset
		renderer.yOffset = yOffset
		plotBorder.topLeft       = Point(plotDimensions.subWidth*0.1, plotDimensions.subHeight*0.9)
		plotBorder.topRight      = Point(plotDimensions.subWidth*0.9, plotDimensions.subHeight*0.9)
		plotBorder.bottomLeft    = Point(plotDimensions.subWidth*0.1, plotDimensions.subHeight*0.1)
		plotBorder.bottomRight   = Point(plotDimensions.subWidth*0.9, plotDimensions.subHeight*0.1)
		plotLegend.legendTopLeft = Point(plotBorder.topLeft.x + 20, plotBorder.topLeft.y - 20)
		calcLabelLocations(renderer: renderer)
		calcMarkerLocAndScalePts(renderer: renderer)
		drawBorder(renderer: renderer)
		drawMarkers(renderer: renderer)
		drawPlots(renderer: renderer)
		drawTitle(renderer: renderer)
		drawLabels(renderer: renderer)
		drawLegends(renderer: renderer)
	}

	public func drawGraphOutput(fileName name: String = "swift_plot_line_graph", renderer: Renderer){
		renderer.plotDimensions = plotDimensions
		renderer.drawOutput(fileName: name)
	}

	// utility functions for implementing logic
	func getNumberOfDigits(_ n: Float) -> Int{

		var x: Int = Int(n)
		var count: Int = 0
		while (x != 0){
			x /= 10;
			count += 1
		}
		return count

	}

	func getMaxX(points p: [Point]) -> Float {
		var max = p[0].x
		for index in 1..<p.count {
			if (p[index].x > max) {
				max = p[index].x
			}
		}
		return max
	}

	func getMaxY(points p: [Point]) -> Float {
		var max = p[0].y
		for index in 1..<p.count {
			if (p[index].y > max) {
				max = p[index].y
			}
		}
		return max
	}

	func getMinX(points p: [Point]) -> Float {
		var min = p[0].x
		for index in 1..<p.count {
			if (p[index].x < min) {
				min = p[index].y
			}
		}
		return min
	}

	func getMinY(points p: [Point]) -> Float {
		var min = p[0].y
		for index in 1..<p.count {
			if (p[index].y < min) {
				min = p[index].y
			}
		}
		return min
	}

	// functions implementing plotting logic
	func calcLabelLocations(renderer: Renderer){

		let xWidth   : Float = renderer.getTextWidth(text: plotLabel.xLabel, textSize: plotLabel.labelSize)
		let yWidth    : Float = renderer.getTextWidth(text: plotLabel.yLabel, textSize: plotLabel.labelSize)
		let titleWidth: Float = renderer.getTextWidth(text: plotTitle.title, textSize: plotTitle.titleSize)

		plotLabel.xLabelLocation = Point(((plotBorder.bottomRight.x + plotBorder.bottomLeft.x)/2.0) - xWidth/2.0, plotBorder.bottomLeft.y - plotTitle.titleSize - 0.05*plotDimensions.graphHeight)
		plotLabel.yLabelLocation = Point((plotBorder.bottomLeft.x - plotTitle.titleSize - 0.05*plotDimensions.graphWidth), ((plotBorder.bottomLeft.y + plotBorder.topLeft.y)/2.0 - yWidth))
		plotTitle.titleLocation = Point(((plotBorder.topRight.x + plotBorder.topLeft.x)/2.0) - titleWidth/2.0, plotBorder.topLeft.y + plotTitle.titleSize/2.0)

	}

	func calcMarkerLocAndScalePts(renderer: Renderer){

		primaryAxis.plotMarkers.xMarkers = [Point]()
		primaryAxis.plotMarkers.yMarkers = [Point]()
		primaryAxis.plotMarkers.xMarkersTextLocation = [Point]()
		primaryAxis.plotMarkers.yMarkersTextLocation = [Point]()
		primaryAxis.plotMarkers.xMarkersText = [String]()
		primaryAxis.plotMarkers.xMarkersText = [String]()

		var maximumXPrimary: Float = getMaxX(points: primaryAxis.series[0].points)
		var maximumYPrimary: Float = getMaxY(points: primaryAxis.series[0].points)
		var minimumXPrimary: Float = getMinX(points: primaryAxis.series[0].points)
		var minimumYPrimary: Float = getMinY(points: primaryAxis.series[0].points)

		for index in 1..<primaryAxis.series.count {

			let s: Series = primaryAxis.series[index]
			let pts = s.points
			var x: Float = getMaxX(points: pts)
			var y: Float = getMaxY(points: pts)
			if (x > maximumXPrimary) {
				maximumXPrimary = x
			}
			if (y > maximumYPrimary) {
				maximumYPrimary = y
			}
			x = getMinX(points: pts)
			y = getMinY(points: pts)
			if (x < minimumXPrimary) {
				minimumXPrimary = x
			}
			if (y < minimumYPrimary) {
				minimumYPrimary = y
			}
		}

		var maximumXSecondary: Float = 0
		var maximumYSecondary: Float = 0
		var minimumXSecondary: Float = 0
		var minimumYSecondary: Float = 0

		if secondaryAxis != nil {
			secondaryAxis!.plotMarkers.xMarkers = [Point]()
			secondaryAxis!.plotMarkers.yMarkers = [Point]()
			secondaryAxis!.plotMarkers.xMarkersTextLocation = [Point]()
			secondaryAxis!.plotMarkers.yMarkersTextLocation = [Point]()
			secondaryAxis!.plotMarkers.xMarkersText = [String]()
			secondaryAxis!.plotMarkers.xMarkersText = [String]()

			maximumXSecondary = getMaxX(points: secondaryAxis!.series[0].points)
			maximumYSecondary = getMaxY(points: secondaryAxis!.series[0].points)
			minimumXSecondary = getMinX(points: secondaryAxis!.series[0].points)
			minimumYSecondary = getMinY(points: secondaryAxis!.series[0].points)
			for index in 1..<secondaryAxis!.series.count {
				let s: Series = secondaryAxis!.series[index]
				let pts = s.points
				var x: Float = getMaxX(points: pts)
				var y: Float = getMaxY(points: pts)
				if (x > maximumXSecondary) {
					maximumXSecondary = x
				}
				if (y > maximumYSecondary) {
					maximumYSecondary = y
				}
				x = getMinX(points: pts)
				y = getMinY(points: pts)
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

		let originPrimary: Point = Point((plotDimensions.graphWidth/(maximumXPrimary-minimumXPrimary))*(-minimumXPrimary), (plotDimensions.graphHeight/(maximumYPrimary-minimumYPrimary))*(-minimumYPrimary))

		let rightScaleMargin: Float = (plotDimensions.subWidth - plotDimensions.graphWidth)/2.0 - 10.0;
		let topScaleMargin: Float = (plotDimensions.subHeight - plotDimensions.graphHeight)/2.0 - 10.0;
		primaryAxis.scaleX = (maximumXPrimary - minimumXPrimary) / (plotDimensions.graphWidth - rightScaleMargin);
		primaryAxis.scaleY = (maximumYPrimary - minimumYPrimary) / (plotDimensions.graphHeight - topScaleMargin);

		var originSecondary: Point? = nil
		if (secondaryAxis != nil) {
		    originSecondary = Point((plotDimensions.graphWidth/(maximumXSecondary-minimumXSecondary))*(-minimumXSecondary), (plotDimensions.graphHeight/(maximumYSecondary-minimumYSecondary))*(-minimumYSecondary))
				secondaryAxis!.scaleX = (maximumXSecondary - minimumXSecondary) / (plotDimensions.graphWidth - rightScaleMargin);
				secondaryAxis!.scaleY = (maximumYSecondary - minimumYSecondary) / (plotDimensions.graphHeight - topScaleMargin);
		}

		//calculations for primary axis
		var nD1: Int = max(getNumberOfDigits(maximumYPrimary), getNumberOfDigits(minimumYPrimary))
		var v1: Float
		if (nD1 > 1 && maximumYPrimary <= pow(Float(10), Float(nD1 - 1))) {
			v1 = Float(pow(Float(10), Float(nD1 - 2)))
		} else if (nD1 > 1) {
			v1 = Float(pow(Float(10), Float(nD1 - 1)))
		} else {
			v1 = Float(pow(Float(10), Float(0)))
		}

		var nY: Float = v1/primaryAxis.scaleY
		var inc1Primary: Float = nY
		if(plotDimensions.graphHeight/nY > MAX_DIV){
			inc1Primary = (plotDimensions.graphHeight/nY)*inc1Primary/MAX_DIV
		}

		let nD2: Int = max(getNumberOfDigits(maximumXPrimary), getNumberOfDigits(minimumXPrimary))
		var v2: Float
		if (nD2 > 1 && maximumXPrimary <= pow(Float(10), Float(nD2 - 1))) {
			v2 = Float(pow(Float(10), Float(nD2 - 2)))
		} else if (nD2 > 1) {
			v2 = Float(pow(Float(10), Float(nD2 - 1)))
		} else {
			v2 = Float(pow(Float(10), Float(0)))
		}

		let nX: Float = v2/primaryAxis.scaleX
		var inc2Primary: Float = nX
		var noXD: Float = plotDimensions.graphWidth/nX
		if(noXD > MAX_DIV){
			inc2Primary = (plotDimensions.graphWidth/nX)*inc2Primary/MAX_DIV
			noXD = MAX_DIV
		}

		var xM: Float = originPrimary.x
		while xM<=plotDimensions.graphWidth {
			if(xM+inc2Primary<0.0 || xM<0.0) {
				xM = xM+inc2Primary
				continue
			}
			let p: Point = Point(xM, 0)
			primaryAxis.plotMarkers.xMarkers.append(p)
			let text_p: Point = Point(xM - (renderer.getTextWidth(text: "\(floor(primaryAxis.scaleX*(xM-originPrimary.x)))", textSize: primaryAxis.plotMarkers.markerTextSize)/2.0) + 8, -15)
			primaryAxis.plotMarkers.xMarkersTextLocation.append(text_p)
			primaryAxis.plotMarkers.xMarkersText.append("\(floor(primaryAxis.scaleX*(xM-originPrimary.x)))")
			xM = xM + inc2Primary
		}

		xM = originPrimary.x - inc2Primary
		while xM>0.0 {
			if (xM > plotDimensions.graphWidth) {
				xM = xM - inc2Primary
				continue
			}
			let p: Point = Point(xM, 0)
			primaryAxis.plotMarkers.xMarkers.append(p)
			let text_p: Point = Point(xM - (renderer.getTextWidth(text: "\(ceil(primaryAxis.scaleX*(xM-originPrimary.x)))", textSize: primaryAxis.plotMarkers.markerTextSize)/2.0) + 8, -15)
			primaryAxis.plotMarkers.xMarkersTextLocation.append(text_p)
			primaryAxis.plotMarkers.xMarkersText.append("\(ceil(primaryAxis.scaleX*(xM-originPrimary.x)))")
			xM = xM - inc2Primary
		}

		var yM: Float = originPrimary.y
		while yM<=plotDimensions.graphHeight {
			if(yM+inc1Primary<0.0 || yM<0.0){
				yM = yM + inc1Primary
				continue
			}
			let p: Point = Point(0, yM)
			primaryAxis.plotMarkers.yMarkers.append(p)
			let text_p: Point = Point(-(renderer.getTextWidth(text: "\(ceil(primaryAxis.scaleY*(yM-originPrimary.y)))", textSize: primaryAxis.plotMarkers.markerTextSize)+5), yM - 4)
			primaryAxis.plotMarkers.yMarkersTextLocation.append(text_p)
			primaryAxis.plotMarkers.yMarkersText.append("\(ceil(primaryAxis.scaleY*(yM-originPrimary.y)))")
			yM = yM + inc1Primary
		}
		yM = originPrimary.y - inc1Primary
		while yM>0.0 {
			let p: Point = Point(0, yM)
			primaryAxis.plotMarkers.yMarkers.append(p)
			let text_p: Point = Point(-(renderer.getTextWidth(text: "\(floor(primaryAxis.scaleY*(yM-originPrimary.y)))", textSize: primaryAxis.plotMarkers.markerTextSize)+5), yM - 4)
			primaryAxis.plotMarkers.yMarkersTextLocation.append(text_p)
			primaryAxis.plotMarkers.yMarkersText.append("\(floor(primaryAxis.scaleY*(yM-originPrimary.y)))")
			yM = yM - inc1Primary
		}



		// scale points to be plotted according to plot size
		let scaleXInvPrimary: Float = 1.0/primaryAxis.scaleX;
		let scaleYInvPrimary: Float = 1.0/primaryAxis.scaleY
		for i in 0..<primaryAxis.series.count {
			let pts = primaryAxis.series[i].points
			primaryAxis.series[i].scaledPoints.removeAll();
			for j in 0..<pts.count {
				let pt: Point = Point((pts[j].x)*scaleXInvPrimary + originPrimary.x, (pts[j].y)*scaleYInvPrimary + originPrimary.y)
				if (pt.x >= 0.0 && pt.x <= plotDimensions.graphWidth && pt.y >= 0.0 && pt.y <= plotDimensions.graphHeight) {
					primaryAxis.series[i].scaledPoints.append(pt)
				}
			}
		}

		//calculations for secondary axis
		if (secondaryAxis != nil) {
			nD1 = max(getNumberOfDigits(maximumYSecondary), getNumberOfDigits(minimumYSecondary))
			if (nD1 > 1 && maximumYSecondary <= pow(Float(10), Float(nD1 - 1))) {
				v1 = Float(pow(Float(10), Float(nD1 - 2)))
			} else if (nD1 > 1) {
				v1 = Float(pow(Float(10), Float(nD1 - 1)))
			} else {
				v1 = Float(pow(Float(10), Float(0)))
			}

			nY = v1/secondaryAxis!.scaleY
			var inc1Secondary: Float = nY
			if(plotDimensions.graphHeight/nY > MAX_DIV){
				inc1Secondary = (plotDimensions.graphHeight/nY)*inc1Secondary/MAX_DIV
			}
			yM = originSecondary!.y

			while yM<=plotDimensions.graphHeight {
				if(yM+inc1Secondary<0.0 || yM<0.0){
					yM = yM + inc1Secondary
					continue
				}
				let p: Point = Point(0, yM)
				secondaryAxis!.plotMarkers.yMarkers.append(p)
				let text_p: Point = Point(plotDimensions.graphWidth + (renderer.getTextWidth(text: "\(ceil(secondaryAxis!.scaleY*(yM-originSecondary!.y)))", textSize: secondaryAxis!.plotMarkers.markerTextSize)/2.0 - 5), yM - 4)
				secondaryAxis!.plotMarkers.yMarkersTextLocation.append(text_p)
				secondaryAxis!.plotMarkers.yMarkersText.append("\(ceil(secondaryAxis!.scaleY*(yM-originSecondary!.y)))")
				yM = yM + inc1Secondary
			}
			yM = originSecondary!.y - inc1Secondary
			while yM>0.0 {
				let p: Point = Point(0, yM)
				secondaryAxis!.plotMarkers.yMarkers.append(p)
				let text_p: Point = Point(plotDimensions.graphWidth + (renderer.getTextWidth(text: "\(floor(secondaryAxis!.scaleY*(yM-originSecondary!.y)))", textSize: secondaryAxis!.plotMarkers.markerTextSize)/2.0 - 5), yM - 4)
				secondaryAxis!.plotMarkers.yMarkersTextLocation.append(text_p)
				secondaryAxis!.plotMarkers.yMarkersText.append("\(floor(secondaryAxis!.scaleY*(yM-originSecondary!.y)))")
				yM = yM - inc1Secondary
			}



			// scale points to be plotted according to plot size
			let scaleYInvSecondary: Float = 1.0/secondaryAxis!.scaleY
			for i in 0..<secondaryAxis!.series.count {
				let pts = secondaryAxis!.series[i].points
				secondaryAxis!.series[i].scaledPoints.removeAll();
				for j in 0..<pts.count {
					let pt: Point = Point((pts[j].x)*scaleXInvPrimary + originPrimary.x, (pts[j].y)*scaleYInvSecondary + originSecondary!.y)
					if (pt.x >= 0.0 && pt.x <= plotDimensions.graphWidth && pt.y >= 0.0 && pt.y <= plotDimensions.graphHeight) {
						secondaryAxis!.series[i].scaledPoints.append(pt)
					}
				}
			}
		}
	}

	//functions to draw the plot
	func drawBorder(renderer: Renderer){
		renderer.drawRect(topLeftPoint: plotBorder.topLeft, topRightPoint: plotBorder.topRight, bottomRightPoint: plotBorder.bottomRight, bottomLeftPoint: plotBorder.bottomLeft, strokeWidth: plotBorder.borderThickness, strokeColor: Color.black)
	}

	func drawMarkers(renderer: Renderer) {
		for index in 0..<primaryAxis.plotMarkers.xMarkers.count {
			let p1: Point = Point(primaryAxis.plotMarkers.xMarkers[index].x, -3)
			let p2: Point = Point(primaryAxis.plotMarkers.xMarkers[index].x, 0)
			renderer.drawTransformedLine(startPoint: p1, endPoint: p2, strokeWidth: plotBorder.borderThickness, strokeColor: Color.black, isDashed: false)
			renderer.drawTransformedText(text: primaryAxis.plotMarkers.xMarkersText[index], location: primaryAxis.plotMarkers.xMarkersTextLocation[index], textSize: primaryAxis.plotMarkers.markerTextSize, strokeWidth: 0.7, angle: 0)
		}

		for index in 0..<primaryAxis.plotMarkers.yMarkers.count {
			let p1: Point = Point(-3, primaryAxis.plotMarkers.yMarkers[index].y)
			let p2: Point = Point(0, primaryAxis.plotMarkers.yMarkers[index].y)
			renderer.drawTransformedLine(startPoint: p1, endPoint: p2, strokeWidth: plotBorder.borderThickness, strokeColor: Color.black, isDashed: false)
			renderer.drawTransformedText(text: primaryAxis.plotMarkers.yMarkersText[index], location: primaryAxis.plotMarkers.yMarkersTextLocation[index], textSize: primaryAxis.plotMarkers.markerTextSize, strokeWidth: 0.7, angle: 0)
		}

		if (secondaryAxis != nil) {
			for index in 0..<secondaryAxis!.plotMarkers.yMarkers.count {
				let p1: Point = Point(plotDimensions.graphWidth, secondaryAxis!.plotMarkers.yMarkers[index].y)
				let p2: Point = Point(plotDimensions.graphWidth + 3, secondaryAxis!.plotMarkers.yMarkers[index].y)
				renderer.drawTransformedLine(startPoint: p1, endPoint: p2, strokeWidth: plotBorder.borderThickness, strokeColor: Color.black, isDashed: false)
				renderer.drawTransformedText(text: secondaryAxis!.plotMarkers.yMarkersText[index], location: secondaryAxis!.plotMarkers.yMarkersTextLocation[index], textSize: secondaryAxis!.plotMarkers.markerTextSize, strokeWidth: 0.7, angle: 0)
			}
		}

	}

	func drawPlots(renderer: Renderer) {
		for s in primaryAxis.series {
			renderer.drawPlotLines(points: s.scaledPoints, strokeWidth: plotLineThickness, strokeColor: s.color, isDashed: false)
		}
		if (secondaryAxis != nil) {
			for s in secondaryAxis!.series {
				renderer.drawPlotLines(points: s.scaledPoints, strokeWidth: plotLineThickness, strokeColor: s.color, isDashed: true)
			}
		}
	}

	func drawTitle(renderer: Renderer) {
		renderer.drawText(text: plotTitle.title, location: plotTitle.titleLocation, textSize: plotTitle.titleSize, strokeWidth: 1.2)
	}

	func drawLabels(renderer: Renderer) {
		renderer.drawText(text: plotLabel.xLabel, location: plotLabel.xLabelLocation, textSize: plotLabel.labelSize, strokeWidth: 1.2)
		renderer.drawRotatedText(text: plotLabel.yLabel, location: plotLabel.yLabelLocation, textSize: plotLabel.labelSize, strokeWidth: 1.2, angle: 90)
	}

	func drawLegends(renderer: Renderer) {
		var maxWidth: Float = 0
		var allSeries: [Series] = primaryAxis.series
		if (secondaryAxis != nil) {
		    allSeries = allSeries + secondaryAxis!.series
		}
		for s in allSeries {
			let w = renderer.getTextWidth(text: s.label, textSize: plotLegend.legendTextSize)
			if (w > maxWidth) {
				maxWidth = w
			}
		}

		plotLegend.legendWidth  = maxWidth + 3.5*plotLegend.legendTextSize
		plotLegend.legendHeight = (Float(allSeries.count)*2.0 + 1.0)*plotLegend.legendTextSize

		let p1: Point = Point(plotLegend.legendTopLeft.x, plotLegend.legendTopLeft.y)
		let p2: Point = Point(plotLegend.legendTopLeft.x + plotLegend.legendWidth, plotLegend.legendTopLeft.y)
		let p3: Point = Point(plotLegend.legendTopLeft.x + plotLegend.legendWidth, plotLegend.legendTopLeft.y - plotLegend.legendHeight)
		let p4: Point = Point(plotLegend.legendTopLeft.x, plotLegend.legendTopLeft.y - plotLegend.legendHeight)

		renderer.drawSolidRectWithBorder(topLeftPoint: p1, topRightPoint: p2, bottomRightPoint: p3, bottomLeftPoint: p4, strokeWidth: plotBorder.borderThickness, fillColor: Color.transluscentWhite, borderColor: Color.black)

		for i in 0..<allSeries.count {
			let tL: Point = Point(plotLegend.legendTopLeft.x + plotLegend.legendTextSize, plotLegend.legendTopLeft.y - (2.0*Float(i) + 1.0)*plotLegend.legendTextSize)
			let bR: Point = Point(tL.x + plotLegend.legendTextSize, tL.y - plotLegend.legendTextSize)
			let tR: Point = Point(bR.x, tL.y)
			let bL: Point = Point(tL.x, bR.y)
			renderer.drawSolidRect(topLeftPoint: tL, topRightPoint: tR, bottomRightPoint: bR, bottomLeftPoint: bL, fillColor: allSeries[i].color)
			let p: Point = Point(bR.x + plotLegend.legendTextSize, bR.y)
			renderer.drawText(text: allSeries[i].label, location: p, textSize: plotLegend.legendTextSize, strokeWidth: 1.2)
		}

	}

	func saveImage(fileName name: String, renderer: Renderer) {
		renderer.drawOutput(fileName: name)
	}
}
