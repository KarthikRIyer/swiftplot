import Vectorizer
// class defining a subPlot
public class Series {

  var points = [Point]()
  var scaledPoints = [Point]()
  var label: String = "Plot"
  var color : Color
  init(points p: [Point], label l: String, color c: Color = lightBlue){
    points = p
    label = l
    color = c
  }
}
