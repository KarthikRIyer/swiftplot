import Foundation

// class defining a barGraph and all it's logic
public class Histogram: Plot {

  let MAX_DIV: Float = 50

  public var xOffset: Float = 0
  public var yOffset: Float = 0

  public var plotTitle: PlotTitle? = nil
  public var plotLabel: PlotLabel? = nil
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
  public var scaleX: Float = 1
  public var plotMarkers: PlotMarkers = PlotMarkers()
  public var histogramSeries: HistogramSeries = HistogramSeries()

  var barWidth: Float = 0
  var xMargin: Float = 5

  var origin: Point = Point.zero

  public init(width: Float = 1000, height: Float = 660){
    plotDimensions = PlotDimensions(frameWidth: width, frameHeight: height)
  }
  public func addSeries(_ s: HistogramSeries){
    histogramSeries = s
  }
  public func addSeries(data: [Float], bins: Int, label: String, color: Color = Color.lightBlue){
    let s = HistogramSeries(data: data, bins: bins, label: label, color: color)
    addSeries(s)
  }
}

// extension containing drawing logic
extension Histogram {

  // call functions to draw the graph
  public func drawGraphAndOutput(fileName name: String = "swift_plot_histogram", renderer: Renderer){
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

  public func drawGraphOutput(fileName name: String = "swift_plot_histogram", renderer: Renderer){
    renderer.plotDimensions = plotDimensions
    renderer.drawOutput(fileName: name)
  }

  // functions implementing plotting logic
  func calcLabelLocations(renderer: Renderer){
    if (plotLabel != nil) {
      let xWidth   : Float = renderer.getTextWidth(text: plotLabel!.xLabel, textSize: plotLabel!.labelSize)
      let yWidth    : Float = renderer.getTextWidth(text: plotLabel!.yLabel, textSize: plotLabel!.labelSize)
      plotLabel!.xLabelLocation = Point(((plotBorder.bottomRight.x + plotBorder.bottomLeft.x)*Float(0.5)) - xWidth*Float(0.5), plotBorder.bottomLeft.y - plotLabel!.labelSize - 0.05*plotDimensions.graphHeight)
      plotLabel!.yLabelLocation = Point((plotBorder.bottomLeft.x - plotLabel!.labelSize - 0.05*plotDimensions.graphWidth), ((plotBorder.bottomLeft.y + plotBorder.topLeft.y)*Float(0.5) - yWidth))
    }
    if (plotTitle != nil) {
      let titleWidth: Float = renderer.getTextWidth(text: plotTitle!.title, textSize: plotTitle!.titleSize)
      plotTitle!.titleLocation = Point(((plotBorder.topRight.x + plotBorder.topLeft.x)*Float(0.5)) - titleWidth*Float(0.5), plotBorder.topLeft.y + plotTitle!.titleSize*Float(0.5))
    }
  }

  func calcMarkerLocAndScalePts(renderer: Renderer){

    let maximumY: Float = Float(histogramSeries.maximumFrequency)
    let minimumY: Float = 0
    let maximumX: Float = histogramSeries.maximumX
    let minimumX: Float = histogramSeries.minimumX

    barWidth = round((plotDimensions.graphWidth - Float(2.0*xMargin))/Float(histogramSeries.bins))

    plotMarkers.xMarkers = [Point]()
    plotMarkers.yMarkers = [Point]()
    plotMarkers.xMarkersTextLocation = [Point]()
    plotMarkers.yMarkersTextLocation = [Point]()
    plotMarkers.xMarkersText = [String]()
    plotMarkers.xMarkersText = [String]()

    origin = Point((plotDimensions.graphWidth-(2.0*xMargin))/(maximumX-minimumX)*(-minimumX), 0.0)

    let topScaleMargin: Float = (plotDimensions.subHeight - plotDimensions.graphHeight)*Float(0.5) - 10.0;
    scaleY = (maximumY - minimumY) / (plotDimensions.graphHeight - topScaleMargin);
    scaleX = (maximumX - minimumX) / (plotDimensions.graphWidth-Float(2.0*xMargin));
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
      let text_p: Point = Point(-(renderer.getTextWidth(text: "\(round(scaleY*(yM-origin.y)))", textSize: plotMarkers.markerTextSize)+5), yM - 4)
      plotMarkers.yMarkersTextLocation.append(text_p)
      plotMarkers.yMarkersText.append("\(round(scaleY*(yM-origin.y)))")
      yM = yM + inc1
    }

    let xRange = niceRoundFloor(maximumX - minimumX)
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
    if(plotDimensions.graphWidth/nX > MAX_DIV){
      inc2 = (plotDimensions.graphHeight/nY)*inc1/MAX_DIV
    }
    let xM: Float = xMargin
    let scaleXInv = 1.0/scaleX
    let xIncrement = inc2*scaleX
    for i in stride(from: minimumX, through: maximumX, by: xIncrement)  {
      let p: Point = Point((i-minimumX)*scaleXInv + xM , 0)
      plotMarkers.xMarkers.append(p)
      let textWidth: Float = renderer.getTextWidth(text: "\(i)", textSize: plotMarkers.markerTextSize)
      let text_p: Point = Point((i - minimumX)*scaleXInv - textWidth/Float(2), -2.0*plotMarkers.markerTextSize)
      plotMarkers.xMarkersTextLocation.append(text_p)
      plotMarkers.xMarkersText.append("\(i)")
    }

    // scale points to be plotted according to plot size
    let scaleYInv: Float = 1.0/scaleY
    histogramSeries.scaledBinFrequency.removeAll();
    for j in 0..<histogramSeries.binFrequency.count {
      let frequency = Float(histogramSeries.binFrequency[j])
      histogramSeries.scaledBinFrequency.append(frequency*scaleYInv + origin.y)
    }
  }

  //functions to draw the plot
  func drawBorder(renderer: Renderer){
    renderer.drawRect(topLeftPoint: plotBorder.topLeft, topRightPoint: plotBorder.topRight, bottomRightPoint: plotBorder.bottomRight, bottomLeftPoint: plotBorder.bottomLeft, strokeWidth: plotBorder.borderThickness, strokeColor: Color.black, isOriginShifted: false)
  }

  func drawMarkers(renderer: Renderer) {
    for index in 0..<plotMarkers.xMarkers.count {
      let p1: Point = Point(plotMarkers.xMarkers[index].x, -3)
      let p2: Point = Point(plotMarkers.xMarkers[index].x, 0)
      renderer.drawLine(startPoint: p1, endPoint: p2, strokeWidth: plotBorder.borderThickness, strokeColor: Color.black, isDashed: false, isOriginShifted: true)
      renderer.drawText(text: plotMarkers.xMarkersText[index], location: plotMarkers.xMarkersTextLocation[index], textSize: plotMarkers.markerTextSize, strokeWidth: 0.7, angle: 0, isOriginShifted: true)
    }

    for index in 0..<plotMarkers.yMarkers.count {
      let p1: Point = Point(-3, plotMarkers.yMarkers[index].y)
      let p2: Point = Point(0, plotMarkers.yMarkers[index].y)
      renderer.drawLine(startPoint: p1, endPoint: p2, strokeWidth: plotBorder.borderThickness, strokeColor: Color.black, isDashed: false, isOriginShifted: true)
      renderer.drawText(text: plotMarkers.yMarkersText[index], location: plotMarkers.yMarkersTextLocation[index], textSize: plotMarkers.markerTextSize, strokeWidth: 0.7, angle: 0, isOriginShifted: true)
    }

  }

  func drawPlots(renderer: Renderer) {
    var xM = Float(xMargin)
    for i in 0..<histogramSeries.bins {
      let height = histogramSeries.scaledBinFrequency[i]
      let bL = Point(xM,0.0)
      let bR = Point(xM+barWidth,0.0)
      let tL = Point(xM,height)
      let tR = Point(xM+barWidth,height)
      renderer.drawSolidRect(topLeftPoint: tL, topRightPoint: tR, bottomRightPoint: bR, bottomLeftPoint: bL, fillColor: histogramSeries.color, hatchPattern: .none, isOriginShifted: true)
      xM+=barWidth
    }
  }

  func drawTitle(renderer: Renderer) {
    guard let plotTitle = self.plotTitle else { return }
    renderer.drawText(text: plotTitle.title, location: plotTitle.titleLocation, textSize: plotTitle.titleSize, strokeWidth: 1.2, angle: 0, isOriginShifted: false)
  }

  func drawLabels(renderer: Renderer) {
    guard let plotLabel = self.plotLabel else { return }
    renderer.drawText(text: plotLabel.xLabel, location: plotLabel.xLabelLocation, textSize: plotLabel.labelSize, strokeWidth: 1.2, angle: 0, isOriginShifted: false)
    renderer.drawText(text: plotLabel.yLabel, location: plotLabel.yLabelLocation, textSize: plotLabel.labelSize, strokeWidth: 1.2, angle: 90, isOriginShifted: false)
  }

  func drawLegends(renderer: Renderer) {
    // var maxWidth: Float = 0
    // var legendSeries = stackSeries
    // legendSeries.insert(series, at: 0)
    // for s in legendSeries {
    //   let w = renderer.getTextWidth(text: s.label, textSize: plotLegend.legendTextSize)
    //   if (w > maxWidth) {
    //     maxWidth = w
    //   }
    // }
    // plotLegend.legendWidth  = maxWidth + 3.5*plotLegend.legendTextSize
    // plotLegend.legendHeight = (Float(stackSeries.count + 1)*2.0 + 1.0)*plotLegend.legendTextSize
    //
    // let p1: Point = Point(plotLegend.legendTopLeft.x, plotLegend.legendTopLeft.y)
    // let p2: Point = Point(plotLegend.legendTopLeft.x + plotLegend.legendWidth, plotLegend.legendTopLeft.y)
    // let p3: Point = Point(plotLegend.legendTopLeft.x + plotLegend.legendWidth, plotLegend.legendTopLeft.y - plotLegend.legendHeight)
    // let p4: Point = Point(plotLegend.legendTopLeft.x, plotLegend.legendTopLeft.y - plotLegend.legendHeight)
    //
    // renderer.drawSolidRectWithBorder(topLeftPoint: p1, topRightPoint: p2, bottomRightPoint: p3, bottomLeftPoint: p4, strokeWidth: plotBorder.borderThickness, fillColor: Color.transluscentWhite, borderColor: Color.black, isOriginShifted: false)
    //
    // for i in 0..<legendSeries.count {
    //   let tL: Point = Point(plotLegend.legendTopLeft.x + plotLegend.legendTextSize, plotLegend.legendTopLeft.y - (2.0*Float(i) + 1.0)*plotLegend.legendTextSize)
    //   let bR: Point = Point(tL.x + plotLegend.legendTextSize, tL.y - plotLegend.legendTextSize)
    //   let tR: Point = Point(bR.x, tL.y)
    //   let bL: Point = Point(tL.x, bR.y)
    //   renderer.drawSolidRect(topLeftPoint: tL, topRightPoint: tR, bottomRightPoint: bR, bottomLeftPoint: bL, fillColor: legendSeries[i].color, hatchPattern: .none, isOriginShifted: false)
    //   let p: Point = Point(bR.x + plotLegend.legendTextSize, bR.y)
    //   renderer.drawText(text: legendSeries[i].label, location: p, textSize: plotLegend.legendTextSize, strokeWidth: 1.2, angle: 0, isOriginShifted: false)
    // }

  }

  func saveImage(fileName name: String, renderer: Renderer) {
    renderer.drawOutput(fileName: name)
  }

}
