import Foundation

// class defining a lineGraph and all its logic
public class LineGraph: Plot {

	let MAX_DIV: Float = 50

	var scaleX: Float = 1
	var scaleY: Float = 1

	public var xOffset: Float = 0
	public var yOffset: Float = 0

	var series = [Series]()

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
	var plotMarkers: PlotMarkers = PlotMarkers()

	public var plotLineThickness: Float = 3

	public init(points p: [Point], width: Float = 1000, height: Float = 660){
		plotDimensions = PlotDimensions(frameWidth: width, frameHeight: height)
		plotDimensions.calculateGraphDimensions()

		let s = Series(points: p,label: "Plot")
		series.append(s)
	}

	public init(width: Float = 1000, height: Float = 660){
		plotDimensions = PlotDimensions(frameWidth: width, frameHeight: height)
	}

	// functions to add series
	public func addSeries(_ s: Series){
		series.append(s)
	}
	public func addSeries(points p: [Point], label: String, color: Color = Color.lightBlue){
		let s = Series(points: p,label: label, color: color)
		series.append(s)
	}
	public func addSeries(_ x: [Float], _ y: [Float], label: String, color: Color = Color.lightBlue){
		var pts = [Point]()
		for i in 0..<x.count {
			pts.append(Point(x[i], y[i]))
		}
		let s = Series(points: pts, label: label, color: color)
		series.append(s)
	}
	public func addFunction(_ function: (Float)->Float, minX: Float, maxX: Float, numberOfSamples: Int = 400, label: String, color: Color = Color.lightBlue) {
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
		series.append(s)
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

		plotMarkers.xMarkers = [Point]()
		plotMarkers.yMarkers = [Point]()
		plotMarkers.xMarkersTextLocation = [Point]()
		plotMarkers.yMarkersTextLocation = [Point]()
		plotMarkers.xMarkersText = [String]()
		plotMarkers.xMarkersText = [String]()

		var maximumX: Float = getMaxX(points: series[0].points)
		var maximumY: Float = getMaxY(points: series[0].points)
		var minimumX: Float = getMinX(points: series[0].points)
		var minimumY: Float = getMinY(points: series[0].points)

		for index in 1..<series.count {

			let s: Series = series[index]
			let pts = s.points
			var x: Float = getMaxX(points: pts)
			var y: Float = getMaxY(points: pts)
			if (x > maximumX) {
				maximumX = x
			}
			if (y > maximumY) {
				maximumY = y
			}
			x = getMinX(points: pts)
			y = getMinY(points: pts)
			if (x < minimumX) {
				minimumX = x
			}
			if (y < minimumY) {
				minimumY = y
			}
		}

		let origin: Point = Point((plotDimensions.graphWidth/(maximumX-minimumX))*(-minimumX), (plotDimensions.graphHeight/(maximumY-minimumY))*(-minimumY))

		let rightScaleMargin: Float = (plotDimensions.subWidth - plotDimensions.graphWidth)/2.0 - 10.0;
		let topScaleMargin: Float = (plotDimensions.subHeight - plotDimensions.graphHeight)/2.0 - 10.0;
		scaleX = (maximumX - minimumX) / (plotDimensions.graphWidth - rightScaleMargin);
		scaleY = (maximumY - minimumY) / (plotDimensions.graphHeight - topScaleMargin);

		let nD1: Int = max(getNumberOfDigits(maximumY), getNumberOfDigits(minimumY))
		var v1: Float
		if (nD1 > 1 && maximumY <= pow(Float(10), Float(nD1 - 1))) {
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

		let nD2: Int = max(getNumberOfDigits(maximumY), getNumberOfDigits(minimumY))
		var v2: Float
		if (nD2 > 1 && maximumX <= pow(Float(10), Float(nD2 - 1))) {
			v2 = Float(pow(Float(10), Float(nD2 - 2)))
		} else if (nD2 > 1) {
			v2 = Float(pow(Float(10), Float(nD2 - 1)))
		} else {
			v2 = Float(pow(Float(10), Float(0)))
		}

		let nX: Float = v2/scaleX
		var inc2: Float = nX
		var noXD: Float = plotDimensions.graphWidth/nX
		if(noXD > MAX_DIV){
			inc2 = (plotDimensions.graphWidth/nX)*inc2/MAX_DIV
			noXD = MAX_DIV
		}

		var xM: Float = origin.x
		while xM<=plotDimensions.graphWidth {
			if(xM+inc2<0.0 || xM<0.0) {
				xM = xM+inc2
				continue
			}
			let p: Point = Point(xM, 0)
			plotMarkers.xMarkers.append(p)
			let text_p: Point = Point(xM - (renderer.getTextWidth(text: "\(floor(scaleX*(xM-origin.x)))", textSize: plotMarkers.markerTextSize)/2.0) + 8, -15)
			plotMarkers.xMarkersTextLocation.append(text_p)
			plotMarkers.xMarkersText.append("\(floor(scaleX*(xM-origin.x)))")
			xM = xM + inc2
		}

		xM = origin.x - inc2
		while xM>0.0 {
			if (xM > plotDimensions.graphWidth) {
				xM = xM - inc2
				continue
			}
			let p: Point = Point(xM, 0)
			plotMarkers.xMarkers.append(p)
			let text_p: Point = Point(xM - (renderer.getTextWidth(text: "\(ceil(scaleX*(xM-origin.x)))", textSize: plotMarkers.markerTextSize)/2.0) + 8, -15)
			plotMarkers.xMarkersTextLocation.append(text_p)
			plotMarkers.xMarkersText.append("\(ceil(scaleX*(xM-origin.x)))")
			xM = xM - inc2
		}

		var yM: Float = origin.y
		while yM<=plotDimensions.graphHeight {
			if(yM+inc1<0.0 || yM<0.0){
				yM = yM + inc1
				continue
			}
			let p: Point = Point(0, yM)
			plotMarkers.yMarkers.append(p)
			let text_p: Point = Point(-(renderer.getTextWidth(text: "\(ceil(scaleY*(yM-origin.y)))", textSize: plotMarkers.markerTextSize)+5), yM - 4)
			plotMarkers.yMarkersTextLocation.append(text_p)
			plotMarkers.yMarkersText.append("\(ceil(scaleY*(yM-origin.y)))")
			yM = yM + inc1
		}
		yM = origin.y - inc1
		while yM>0.0 {
			let p: Point = Point(0, yM)
			plotMarkers.yMarkers.append(p)
			let text_p: Point = Point(-(renderer.getTextWidth(text: "\(floor(scaleY*(yM-origin.y)))", textSize: plotMarkers.markerTextSize)+5), yM - 4)
			plotMarkers.yMarkersTextLocation.append(text_p)
			plotMarkers.yMarkersText.append("\(floor(scaleY*(yM-origin.y)))")
			yM = yM - inc1
		}



		// scale points to be plotted according to plot size
		let scaleXInv: Float = 1.0/scaleX;
		let scaleYInv: Float = 1.0/scaleY
		for i in 0..<series.count {
			let pts = series[i].points
			series[i].scaledPoints.removeAll();

			for j in 0..<pts.count {

				let pt: Point = Point((pts[j].x)*scaleXInv + origin.x, (pts[j].y)*scaleYInv + origin.y)
				if (pt.x >= 0.0 && pt.x <= plotDimensions.graphWidth && pt.y >= 0.0 && pt.y <= plotDimensions.graphHeight) {
					series[i].scaledPoints.append(pt)
				}
			}
		}
	}

	//functions to draw the plot
	func drawBorder(renderer: Renderer){
		renderer.drawRect(topLeftPoint: plotBorder.topLeft, topRightPoint: plotBorder.topRight, bottomRightPoint: plotBorder.bottomRight, bottomLeftPoint: plotBorder.bottomLeft, strokeWidth: plotBorder.borderThickness, strokeColor: Color.black)
	}

	func drawMarkers(renderer: Renderer) {
		for index in 0..<plotMarkers.xMarkers.count {
			let p1: Point = Point(plotMarkers.xMarkers[index].x, -3)
			let p2: Point = Point(plotMarkers.xMarkers[index].x, 0)
			renderer.drawTransformedLine(startPoint: p1, endPoint: p2, strokeWidth: plotBorder.borderThickness, strokeColor: Color.black)
			renderer.drawTransformedText(text: plotMarkers.xMarkersText[index], location: plotMarkers.xMarkersTextLocation[index], textSize: plotMarkers.markerTextSize, strokeWidth: 0.7, angle: 0)
		}

		for index in 0..<plotMarkers.yMarkers.count {
			let p1: Point = Point(-3, plotMarkers.yMarkers[index].y)
			let p2: Point = Point(0, plotMarkers.yMarkers[index].y)
			renderer.drawTransformedLine(startPoint: p1, endPoint: p2, strokeWidth: plotBorder.borderThickness, strokeColor: Color.black)
			renderer.drawTransformedText(text: plotMarkers.yMarkersText[index], location: plotMarkers.yMarkersTextLocation[index], textSize: plotMarkers.markerTextSize, strokeWidth: 0.7, angle: 0)
		}

	}

	func drawPlots(renderer: Renderer) {
		for s in series {
			renderer.drawPlotLines(points: s.scaledPoints, strokeWidth: plotLineThickness, strokeColor: s.color)
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
		for s in series {
			let w = renderer.getTextWidth(text: s.label, textSize: plotLegend.legendTextSize)
			if (w > maxWidth) {
				maxWidth = w
			}
		}

		plotLegend.legendWidth  = maxWidth + 3.5*plotLegend.legendTextSize
		plotLegend.legendHeight = (Float(series.count)*2.0 + 1.0)*plotLegend.legendTextSize

		let p1: Point = Point(plotLegend.legendTopLeft.x, plotLegend.legendTopLeft.y)
		let p2: Point = Point(plotLegend.legendTopLeft.x + plotLegend.legendWidth, plotLegend.legendTopLeft.y)
		let p3: Point = Point(plotLegend.legendTopLeft.x + plotLegend.legendWidth, plotLegend.legendTopLeft.y - plotLegend.legendHeight)
		let p4: Point = Point(plotLegend.legendTopLeft.x, plotLegend.legendTopLeft.y - plotLegend.legendHeight)

		renderer.drawSolidRectWithBorder(topLeftPoint: p1, topRightPoint: p2, bottomRightPoint: p3, bottomLeftPoint: p4, strokeWidth: plotBorder.borderThickness, fillColor: Color.transluscentWhite, borderColor: Color.black)

		for i in 0..<series.count {
			let tL: Point = Point(plotLegend.legendTopLeft.x + plotLegend.legendTextSize, plotLegend.legendTopLeft.y - (2.0*Float(i) + 1.0)*plotLegend.legendTextSize)
			let bR: Point = Point(tL.x + plotLegend.legendTextSize, tL.y - plotLegend.legendTextSize)
			let tR: Point = Point(bR.x, tL.y)
			let bL: Point = Point(tL.x, bR.y)
			renderer.drawSolidRect(topLeftPoint: tL, topRightPoint: tR, bottomRightPoint: bR, bottomLeftPoint: bL, fillColor: series[i].color)
			let p: Point = Point(bR.x + plotLegend.legendTextSize, bR.y)
			renderer.drawText(text: series[i].label, location: p, textSize: plotLegend.legendTextSize, strokeWidth: 1.2)
		}

	}

	func saveImage(fileName name: String, renderer: Renderer) {
		renderer.drawOutput(fileName: name)
	}
}
