// struct defining a data series
public struct Series {

	public var points = [Point]()
	public var scaledPoints = [Point]()
	public var label: String = "Plot"
	public var color : Color = Color.blue
	public init() {}
	public init(points p: [Point], label l: String, color c: Color = Color.lightBlue){
		points = p
		label = l
		color = c
	}
}
