import Foundation
import Vectorizer

public var RENDERER_AGG : Int = 0
public var RENDERER_SVG : Int = 1

public var lightBlue : Color = Color(0.529,0.808,0.922,1.0)
public var transluscentWhite : Color = Color(1.0,1.0,1.0,0.8)
public var black : Color = Color(0.0, 0.0, 0.0, 1.0)
public var white : Color = Color(1.0, 1.0, 1.0, 1.0)
public var orange : Color = Color(1.0, 0.647, 0.0, 1.0)

// class defining a lineGraph and all its logic
public class LineGraph {

  let MAX_DIV : Float = 50

  var frame_width  : Float = 1000
  var frame_height : Float = 660
  var graph_width  : Float
  var graph_height : Float

  var scaleX : Float = 1
  var scaleY : Float = 1

  var series = [Series]()

  var topLeft       : Point
  var topRight      : Point
  var bottomLeft    : Point
  var bottomRight   : Point
  var legendTopLeft : Point

  var plotTitle : String = "TITLE"
  var x_label   : String = "X-Axis"
  var y_label   : String = "Y-Axis"

  var x_markers = [Point]()
  var y_markers = [Point]()
  var x_markers_text_loc = [Point]()
  var y_markers_text_loc = [Point]()
  var x_markers_text = [String]()
  var y_markers_text = [String]()

  var x_label_loc : Point!
  var y_label_loc : Point!
  var title_loc   : Point!

  var title_size : Float       = 15
  var label_size : Float       = 10
  var marker_text_size : Float = 8
  var legend_text_size : Float = 8
  var border_thickness : Float = 2
  var plot_line_thickness : Float = 3

  var renderer : Int = RENDERER_AGG

  var vectorizer : Vectorizer?

  public init(p: [Point], w : Float = 1000, h : Float = 660, renderer r : Int = RENDERER_AGG){
    renderer = r
    frame_width = w
    frame_height = h
    vectorizer = Vectorizer(renderer : r, width : frame_width, height : frame_height)

    topLeft       = Point(frame_width*0.1, frame_height*0.9)
    topRight      = Point(frame_width*0.9, frame_height*0.9)
    bottomLeft    = Point(frame_width*0.1, frame_height*0.1)
    bottomRight   = Point(frame_width*0.9, frame_height*0.1)
    legendTopLeft = Point(topLeft.x + 20, topLeft.y - 20)

    graph_width  = 0.8*frame_width
    graph_height = 0.8*frame_height

    let s = Series(points: p,label: "Plot")
    series.append(s)
  }

  public init(w : Float = 1000, h : Float = 660, renderer r : Int = RENDERER_AGG){
    renderer = r
    frame_width = w
    frame_height = h
    vectorizer = Vectorizer(renderer : r, width : frame_width, height : frame_height)

    topLeft       = Point(frame_width*0.1, frame_height*0.9)
    topRight      = Point(frame_width*0.9, frame_height*0.9)
    bottomLeft    = Point(frame_width*0.1, frame_height*0.1)
    bottomRight   = Point(frame_width*0.9, frame_height*0.1)
    legendTopLeft = Point(topLeft.x + 20, topLeft.y - 20)

    graph_width  = 0.8*frame_width
    graph_height = 0.8*frame_height
  }

  public func setRenderer(renderer r: Int) {
    renderer = r
    vectorizer = Vectorizer(renderer : r, width : frame_width, height : frame_height)
  }

  public func setPlotDimensions(width w: Float, height h: Float){
    frame_width  = w
    frame_height = h

    vectorizer = Vectorizer(renderer : renderer, width : frame_width, height : frame_height)

    topLeft       = Point(frame_width*0.1, frame_height*0.9)
    topRight      = Point(frame_width*0.9, frame_height*0.9)
    bottomLeft    = Point(frame_width*0.1, frame_height*0.1)
    bottomRight   = Point(frame_width*0.9, frame_height*0.1)
    legendTopLeft = Point(topLeft.x + 20, topLeft.y - 20)

    graph_width  = 0.8*frame_width
    graph_height = 0.8*frame_height
  }

  public func setPlotTitle(_ t: String){
    plotTitle = t
  }

  public func setXLabel(_ l: String){
    x_label = l
  }

  public func setYLabel(_ l: String){
    y_label = l
  }

  // functions to add series
  public func addSeries(subPlot s: Series){
    series.append(s)
  }
  public func addSeries(points p: [Point], label l: String, color c : Color = lightBlue){
    let s = Series(points: p,label: "Plot", color: c)
    series.append(s)
  }
  public func addSeries(_ x : [Float], _ y : [Float], label l: String, color c : Color = lightBlue){
    var pts = [Point]()
    for i in 0..<x.count {
        pts.append(Point(x[i], y[i]))
    }
    let s = Series(points: pts, label: l, color: c)
    series.append(s)
  }

  // utility functions for implementing logic
  func getNumberOfDigits(_ n : Float) -> Int{

    var x : Int = Int(n)
    var count : Int = 0
    while (x != 0){
      x /= 10;
      count += 1
    }
    return count

  }

  func getMaxX(points p : [Point]) -> Float {
    var max = p[0].x
    for index in 1..<p.count {
      if (p[index].x > max) {
          max = p[index].x
      }
    }
    return max
  }

  func getMaxY(points p : [Point]) -> Float {
    var max = p[0].y
    for index in 1..<p.count {
      if (p[index].y > max) {
          max = p[index].y
      }
    }
    return max
  }

  // function implementing plotting logic
  func calcLabelLocations( ){

    let x_width     : Float = vectorizer!.getTextWidth(x_label, label_size)
    let y_width     : Float = vectorizer!.getTextWidth(y_label, label_size)
    let title_width : Float = vectorizer!.getTextWidth(plotTitle, title_size)

    x_label_loc = Point(((bottomRight.x + bottomLeft.x)/2.0) - x_width/2.0, bottomLeft.y - title_size - 0.05*graph_height)
    y_label_loc = Point((bottomLeft.x - title_size - 0.05*graph_width), ((bottomLeft.y + topLeft.y)/2.0 - y_width))
    title_loc   = Point(((topRight.x + topLeft.x)/2.0) - title_width/2.0, topLeft.y + title_size/2.0)

  }

  func calcMarkerLocAndScalePts(){

    var maximumX : Float = getMaxX(points: series[0].points)
    var maximumY : Float = getMaxY(points: series[0].points)

    for index in 1..<series.count {

        let s : Series = series[index]
        let pts = s.points
        let x : Float = getMaxX(points: pts)
        let y : Float = getMaxY(points: pts)
        if (x > maximumX) {
          maximumX = x
        }
        if (y > maximumY) {
          maximumY = y
        }
      }

      let rightScaleMargin : Float = (frame_width - graph_width)/2.0 - 10.0;
      let topScaleMargin : Float = (frame_height - graph_height)/2.0 - 10.0;
      scaleX = maximumX / (graph_width - rightScaleMargin);
      scaleY = maximumY / (graph_height - topScaleMargin);

      let nD1 : Int = getNumberOfDigits(maximumY)
      var v1 : Float
      if (nD1 > 1 && maximumY <= pow(Float(10), Float(nD1 - 1))) {
          v1 = Float(pow(Float(10), Float(nD1 - 2)))
      } else if (nD1 > 1) {
          v1 = Float(pow(Float(10), Float(nD1 - 1)))
      } else {
          v1 = Float(pow(Float(10), Float(0)))
      }

      let nY : Float = v1/scaleY
      var inc1 : Float = nY
      if(graph_height/nY > MAX_DIV){
          inc1 = (graph_height/nY)*inc1/MAX_DIV
      }

      let nD2 : Int = getNumberOfDigits(maximumX)
      var v2 : Float
      if (nD2 > 1 && maximumX <= pow(Float(10), Float(nD2 - 1))) {
          v2 = Float(pow(Float(10), Float(nD2 - 2)))
      } else if (nD2 > 1) {
          v2 = Float(pow(Float(10), Float(nD2 - 1)))
      } else {
          v2 = Float(pow(Float(10), Float(0)))
      }

      let nX : Float = v2/scaleX
      var inc2 : Float = nX
      var noXD : Float = graph_width/nX
      if(noXD > MAX_DIV){
          inc2 = (graph_width/nX)*inc2/MAX_DIV
          noXD = MAX_DIV
      }

      // calculate axes marker co-ordinates
      for i in stride(from: v1/scaleY, through: graph_height, by: inc1) {
          let p : Point = Point(0, i)
          y_markers.append(p)
          let text_p : Point = Point(-(vectorizer!.getTextWidth("\(ceil(scaleY*i))", marker_text_size)+5), i - 4)
          y_markers_text_loc.append(text_p)
          y_markers_text.append("\(ceil(scaleY*i))")
      }
      for i in stride(from: v2/scaleX, through: graph_width, by: inc2) {
          let p : Point = Point(i, 0)
          x_markers.append(p)
          let text_p : Point = Point(i - (vectorizer!.getTextWidth("\(ceil(scaleX*i))", marker_text_size)/2.0), -15)
          x_markers_text_loc.append(text_p)
          x_markers_text.append("\(ceil(scaleX*i))")
      }
      // scale points to be plotted according to plot size
      let scaleXInv : Float = 1.0/scaleX;
      let scaleYInv : Float = 1.0/scaleY;

      for i in 0..<series.count {
          let pts = series[i].points
          for j in 0..<pts.count {
              let pt : Point = Point(pts[j].x*scaleXInv, pts[j].y*scaleYInv)
              series[i].scaledPoints.append(pt)
          }
      }
  }

  // functions to draw the graph
    public func drawGraph(fileName name : String = "swift_plot_test"){
      calcLabelLocations()
      calcMarkerLocAndScalePts()
      drawBorder()
      drawMarkers()
      drawPlots()
      drawTitle()
      drawLabels()
      drawLegends()
      saveImage(name)
    }



  func drawBorder(){
    vectorizer!.drawRect(topLeft, topRight, bottomRight, bottomLeft, border_thickness)
  }

  func drawMarkers() {

    for index in 0..<x_markers.count {
        let p1 : Point = Point(x_markers[index].x, -3)
        let p2 : Point = Point(x_markers[index].x, 0)
        vectorizer!.drawTransformedLine(p1, p2, border_thickness)
        vectorizer!.drawTransformedText(x_markers_text[index], x_markers_text_loc[index], marker_text_size, 0.7)
    }
    for index in 0..<y_markers.count {
        let p1 : Point = Point(-3, y_markers[index].y)
        let p2 : Point = Point(0, y_markers[index].y)
        vectorizer!.drawTransformedLine(p1, p2, border_thickness)
        vectorizer!.drawTransformedText(y_markers_text[index], y_markers_text_loc[index], marker_text_size, 0.7)
    }

  }

  func drawPlots() {
      for s in series {
          vectorizer!.drawPlotLines(s.scaledPoints, plot_line_thickness, s.color)
      }
  }

  func drawTitle() {
      vectorizer!.drawText(plotTitle, title_loc, title_size, 1.2)
  }

  func drawLabels() {
      vectorizer!.drawText(x_label, x_label_loc, label_size, 1.2)
      vectorizer!.drawRotatedText(y_label, y_label_loc, label_size, 1.2, 90)
  }

  func drawLegends() {
      var maxWidth : Float = 0
      for s in series {
          let w = vectorizer!.getTextWidth(s.label, legend_text_size)
          if (w > maxWidth) {
              maxWidth = w
          }
      }

      let legendWidth  : Float = maxWidth + 3.5*legend_text_size
      let legendHeight : Float = (Float(series.count)*2.0 + 1.0)*legend_text_size

      let p1 : Point = Point(legendTopLeft.x, legendTopLeft.y)
      let p2 : Point = Point(legendTopLeft.x + legendWidth, legendTopLeft.y)
      let p3 : Point = Point(legendTopLeft.x + legendWidth, legendTopLeft.y - legendHeight)
      let p4 : Point = Point(legendTopLeft.x, legendTopLeft.y - legendHeight)

      vectorizer!.drawSolidRectWithBorder(p1, p2, p3, p4, border_thickness, transluscentWhite)

      for i in 0..<series.count {
          let tL : Point = Point(legendTopLeft.x + legend_text_size, legendTopLeft.y - (2.0*Float(i) + 1.0)*legend_text_size)
          let bR : Point = Point(tL.x + legend_text_size, tL.y - legend_text_size)
          let tR : Point = Point(bR.x, tL.y)
          let bL : Point = Point(tL.x, bR.y)
          vectorizer!.drawSolidRect(tL, tR, bR, bL, series[i].color)
          let p : Point = Point(bR.x + legend_text_size, bR.y)
          vectorizer!.drawText(series[i].label, p, legend_text_size, 1.2)
      }

  }

  func saveImage(_ name : String) {
      vectorizer!.savePlotImage(name)
  }

}
