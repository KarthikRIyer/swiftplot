public class Axis{
  public var scaleX: Float = 1
	public var scaleY: Float = 1
  public var plotMarkers: PlotMarkers = PlotMarkers()
  public var series = [Series]()
  public init(){}

  public static let PRIMARY_AXIS: Int = 0
  public static let SECONDARY_AXIS: Int = 1
}
