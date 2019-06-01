// struct defining a data series
public struct Series {

	public enum hatching: Int, CaseIterable{
		case none = 0
		case forwardSlash = 1
		case backwardSlash = 2
	}
	public var hatchPattern: hatching = .none
	public var points = [Point]()
	public var scaledPoints = [Point]()
	public var label: String = "Plot"
	public var color : Color = Color.blue
	public init() {}
	public init(points p: [Point], label l: String, color c: Color = Color.lightBlue, hatchPattern: hatching = .none){
		points = p
		label = l
		color = c
		self.hatchPattern = hatchPattern
	}
}
