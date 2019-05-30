import Foundation

// class defining a barGraph and all it's logic
public class BarGraph: Plot {

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

	public var scaleY: Float = 1
  public var plotMarkers: PlotMarkers = PlotMarkers()
  public var series: Series = Series()

  var barWidth : Int = 0
  public var space: Int = 10

  public init(width: Float = 1000, height: Float = 660){
		plotDimensions = PlotDimensions(frameWidth: width, frameHeight: height)
	}
  public func addSeries(_ s: Series){
		series = s
	}
  public func addSeries(points p: [Point], label: String, color: Color = Color.lightBlue){
		let s = Series(points: p,label: label, color: color)
		addSeries(s)
	}
  public func addSeries(_ x: [Float], _ y: [Float], label: String, color: Color = Color.lightBlue){
		var pts = [Point]()
		for i in 0..<x.count {
			pts.append(Point(x[i], y[i]))
		}
		let s = Series(points: pts, label: label, color: color)
		addSeries(s)
	}
  public func addSeries(_ x: [String], _ y: [Float], label: String, color: Color = Color.lightBlue){
		var pts = [Point]()
		for i in 0..<x.count {
			pts.append(Point(x[i], y[i]))
		}
		let s = Series(points: pts, label: label, color: color)
		addSeries(s)
	}

}

// extension containing drawing logic
extension BarGraph {

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

    barWidth = Int(round(plotDimensions.graphWidth/Float(series.points.count)))

		plotMarkers.xMarkers = [Point]()
		plotMarkers.yMarkers = [Point]()
		plotMarkers.xMarkersTextLocation = [Point]()
		plotMarkers.yMarkersTextLocation = [Point]()
		plotMarkers.xMarkersText = [String]()
		plotMarkers.xMarkersText = [String]()

		var maximumY: Float = getMaxY(points: series.points)
		var minimumY: Float = getMinY(points: series.points)

    let pts = series.points
    var y: Float = getMaxY(points: pts)
    if (y > maximumY) {
      maximumY = y
    }
    y = getMinY(points: pts)
    if (y < minimumY) {
      minimumY = y
    }

		let origin: Point = Point(0.0, (plotDimensions.graphHeight/(maximumY-minimumY))*(-minimumY))

		let topScaleMargin: Float = (plotDimensions.subHeight - plotDimensions.graphHeight)/2.0 - 10.0;
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

    for i in 0..<series.points.count {
      let p: Point = Point(Float(i*barWidth) + Float(barWidth)/2.0, 0)
      plotMarkers.xMarkers.append(p)
      let bW: Int = barWidth*(i+1)
      let textWidth: Float = renderer.getTextWidth(text: "\(series.points[i].xString)", textSize: plotMarkers.markerTextSize)
      let text_p: Point = Point(Float(bW) - textWidth/2.0 - Float(barWidth)/2.0, -2.0*plotMarkers.markerTextSize)
      plotMarkers.xMarkersTextLocation.append(text_p)
      plotMarkers.xMarkersText.append("\(series.points[i].xString)")
    }

		// scale points to be plotted according to plot size
		let scaleYInv: Float = 1.0/scaleY
    series.scaledPoints.removeAll();
    for j in 0..<pts.count {
      let pt: Point = Point(pts[j].x, (pts[j].y)*scaleYInv + origin.y)
      if (pt.x >= 0.0 && pt.x <= plotDimensions.graphWidth && pt.y >= 0.0 && pt.y <= plotDimensions.graphHeight) {
        series.scaledPoints.append(pt)
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
			renderer.drawTransformedLine(startPoint: p1, endPoint: p2, strokeWidth: plotBorder.borderThickness, strokeColor: Color.black, isDashed: false)
			renderer.drawTransformedText(text: plotMarkers.xMarkersText[index], location: plotMarkers.xMarkersTextLocation[index], textSize: plotMarkers.markerTextSize, strokeWidth: 0.7, angle: 0)
		}

		for index in 0..<plotMarkers.yMarkers.count {
			let p1: Point = Point(-3, plotMarkers.yMarkers[index].y)
			let p2: Point = Point(0, plotMarkers.yMarkers[index].y)
			renderer.drawTransformedLine(startPoint: p1, endPoint: p2, strokeWidth: plotBorder.borderThickness, strokeColor: Color.black, isDashed: false)
			renderer.drawTransformedText(text: plotMarkers.yMarkersText[index], location: plotMarkers.yMarkersTextLocation[index], textSize: plotMarkers.markerTextSize, strokeWidth: 0.7, angle: 0)
		}

	}

	func drawPlots(renderer: Renderer) {

    for index in 0..<series.points.count {
        let tL: Point = Point(plotMarkers.xMarkers[index].x - Float(barWidth)/2.0, series.scaledPoints[index].y)
        let tR: Point = Point(plotMarkers.xMarkers[index].x + Float(barWidth)/2.0, series.scaledPoints[index].y)
        let bL: Point = Point(plotMarkers.xMarkers[index].x - Float(barWidth)/2.0, 0.0)
        let bR: Point = Point(plotMarkers.xMarkers[index].x + Float(barWidth)/2.0, 0.0)

        renderer.drawSolidRect(topLeftPoint: tL, topRightPoint: tR, bottomRightPoint: bR, bottomLeftPoint: bL, fillColor: series.color)
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
		// var maxWidth: Float = 0
		// for s in series {
		// 	let w = renderer.getTextWidth(text: s.label, textSize: plotLegend.legendTextSize)
		// 	if (w > maxWidth) {
		// 		maxWidth = w
		// 	}
		// }
    //
		// plotLegend.legendWidth  = maxWidth + 3.5*plotLegend.legendTextSize
		// plotLegend.legendHeight = (Float(series.count)*2.0 + 1.0)*plotLegend.legendTextSize
    //
		// let p1: Point = Point(plotLegend.legendTopLeft.x, plotLegend.legendTopLeft.y)
		// let p2: Point = Point(plotLegend.legendTopLeft.x + plotLegend.legendWidth, plotLegend.legendTopLeft.y)
		// let p3: Point = Point(plotLegend.legendTopLeft.x + plotLegend.legendWidth, plotLegend.legendTopLeft.y - plotLegend.legendHeight)
		// let p4: Point = Point(plotLegend.legendTopLeft.x, plotLegend.legendTopLeft.y - plotLegend.legendHeight)
    //
		// renderer.drawSolidRectWithBorder(topLeftPoint: p1, topRightPoint: p2, bottomRightPoint: p3, bottomLeftPoint: p4, strokeWidth: plotBorder.borderThickness, fillColor: Color.transluscentWhite, borderColor: Color.black)
    //
		// for i in 0..<primaryAxis.series.count {
		// 	let tL: Point = Point(plotLegend.legendTopLeft.x + plotLegend.legendTextSize, plotLegend.legendTopLeft.y - (2.0*Float(i) + 1.0)*plotLegend.legendTextSize)
		// 	let bR: Point = Point(tL.x + plotLegend.legendTextSize, tL.y - plotLegend.legendTextSize)
		// 	let tR: Point = Point(bR.x, tL.y)
		// 	let bL: Point = Point(tL.x, bR.y)
		// 	renderer.drawSolidRect(topLeftPoint: tL, topRightPoint: tR, bottomRightPoint: bR, bottomLeftPoint: bL, fillColor: primaryAxis.series[i].color)
		// 	let p: Point = Point(bR.x + plotLegend.legendTextSize, bR.y)
		// 	renderer.drawText(text: primaryAxis.series[i].label, location: p, textSize: plotLegend.legendTextSize, strokeWidth: 1.2)
		// }

	}

	func saveImage(fileName name: String, renderer: Renderer) {
		renderer.drawOutput(fileName: name)
	}

}
