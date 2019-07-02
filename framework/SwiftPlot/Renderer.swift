public protocol Renderer: AnyObject{

    /*property: xOffset
    *description: Specifies the offset in the x-direction for everything in the
    *             particular SubPlot being renderer currently.
    */
    var xOffset: Float { get set }

    /*property: yOffset
    *description: Specifies the offset in the y-direction for everything in the
    *             particular SubPlot being renderer currently.
    */
    var yOffset: Float { get set }

    /*property: plotDimensions
    *description: Specifies the dimensions of the particular Image and SubPlot
                  being renderered currently.
    *             It holds the Frame, Graph and SubPlot Dimensions.
    */
    var plotDimensions: PlotDimensions { get set }

    /*drawRect()
    *params: topLeftPoint p1: Pair<FloatConvertible,FloatConvertible>,
             topRightPoint p2: Pair<FloatConvertible,FloatConvertible>,
             bottomRightPoint p3: Pair<FloatConvertible,FloatConvertible>,
             bottomLeftPoint p4: Pair<FloatConvertible,FloatConvertible>,
             strokeWidth thickness: Float,
             strokeColor: Color,
             isOriginShifted: Bool
    *description: Draws a rectangle with white fill and border of the specified
    *             color and thickness.
    *             This function can operate in both coordinate systems with and
    *             without shifted origin. This is decided by the boolean
    *             parameter 'isOriginShifted'.
    */
    func drawRect(topLeftPoint p1: Pair<FloatConvertible,FloatConvertible>,
                  topRightPoint p2: Pair<FloatConvertible,FloatConvertible>,
                  bottomRightPoint p3: Pair<FloatConvertible,FloatConvertible>,
                  bottomLeftPoint p4: Pair<FloatConvertible,FloatConvertible>,
                  strokeWidth thickness: Float,
                  strokeColor: Color,
                  isOriginShifted: Bool)

    /*drawSolidRect()
    *params: topLeftPoint p1: Pair<FloatConvertible,FloatConvertible>,
    *        topRightPoint p2: Pair<FloatConvertible,FloatConvertible>,
    *        bottomRightPoint p3: Pair<FloatConvertible,FloatConvertible>,
    *        bottomLeftPoint p4: Pair<FloatConvertible,FloatConvertible>,
    *        fillColor: Color,
    *        hatchPattern: BarGraphSeriesOptions.Hatching,
    *        isOriginShifted: Bool
    *description: Draws a rectangle with a fill of specified color and no border.
    *             This function can operate in both coordinate systems with and
    *             without shifted origin.
    *             This is decided by the boolean parameter 'isOriginShifted'.
    */
    func drawSolidRect(topLeftPoint p1: Pair<FloatConvertible,FloatConvertible>,
                       topRightPoint p2: Pair<FloatConvertible,FloatConvertible>,
                       bottomRightPoint p3: Pair<FloatConvertible,FloatConvertible>,
                       bottomLeftPoint p4: Pair<FloatConvertible,FloatConvertible>,
                       fillColor: Color,
                       hatchPattern: BarGraphSeriesOptions.Hatching,
                       isOriginShifted: Bool)

    /*drawLine()
    *params: startPoint p1: Pair<FloatConvertible,FloatConvertible>,
    *        endPoint p2: Pair<FloatConvertible,FloatConvertible>,
    *        strokeWidth thickness: Float,
    *        strokeColor: Color,
    *        isDashed: Bool,
    *        isOriginShifted: Bool
    *description: Draws a line between two points of specified thickness, color.
    *             You can decide if the line is dashed or solid with the boolean
    *             parameter isDashed.
    *             This function can operate in both coordinate systems with and
    *             without shifted origin.
    *             This is decided by the boolean parameter 'isOriginShifted'.
    */
    func drawLine(startPoint p1: Pair<FloatConvertible,FloatConvertible>,
                  endPoint p2: Pair<FloatConvertible,FloatConvertible>,
                  strokeWidth thickness: Float,
                  strokeColor: Color, isDashed: Bool,
                  isOriginShifted: Bool)

    /*drawPlotLines()
    *params: points p: [Pair<FloatConvertible,FloatConvertible>],
    *        strokeWidth thickness: Float,
    *        strokeColor: Color,
    *        isDashed: Bool
    *description: Draws all the line segments in a single data series for a Line Graph.
    *             This function always operates in the coordinate system with the shifted origin.
    */
    func drawPlotLines(points p: [Pair<FloatConvertible,FloatConvertible>],
                       strokeWidth thickness: Float,
                       strokeColor: Color, isDashed: Bool)

    /*drawText()
    *params: text s: String,
    *        location p: Pair<FloatConvertible,FloatConvertible>,
    *        textSize size: Float,
    *        strokeWidth thickness: Float,
    *        angle: Float,
    *        isOriginShifted: Bool
    *description: Draws specified text with specified size,
    *             rotated at the specified angle. The color is always black.
    *             This function can operate in both coordinate systems with and
    *             without shifted origin. This is decided by the boolean parameter isOriginShifted.
    */
    func drawText(text s: String,
                  location p: Pair<FloatConvertible,FloatConvertible>,
                  textSize size: Float,
                  strokeWidth thickness: Float,
                  angle: Float,
                  isOriginShifted: Bool)

    /*drawSolidRectWithBorder()
    *params: topLeftPoint p1: Pair<FloatConvertible,FloatConvertible>,
    *        topRightPoint p2: Pair<FloatConvertible,FloatConvertible>,
    *        bottomRightPoint p3: Pair<FloatConvertible,FloatConvertible>,
    *        bottomLeftPoint p4: Pair<FloatConvertible,FloatConvertible>,
    *        strokeWidth thickness: Float, fillColor: Color,
    *        borderColor: Color,
    *        isOriginShifted: Bool
    *description: Draws a rectangle with specified fill color, border color and border thickness
    *             This function can operate in both coordinate systems with and without shifted origin.
    *             This is decided by the boolean parameter isOriginShifted.
    */
    func drawSolidRectWithBorder(topLeftPoint p1: Pair<FloatConvertible,FloatConvertible>,
                                 topRightPoint p2: Pair<FloatConvertible,FloatConvertible>,
                                 bottomRightPoint p3: Pair<FloatConvertible,FloatConvertible>,
                                 bottomLeftPoint p4: Pair<FloatConvertible,FloatConvertible>,
                                 strokeWidth thickness: Float, fillColor: Color,
                                 borderColor: Color,
                                 isOriginShifted: Bool)

    /*drawSolidCircle()
    *params: center c: Pair<FloatConvertible,FloatConvertible>,
    *        radius r: Float,
    *        fillColor: Color,
    *        isOriginShifted: Bool
    *description: Draws a circle with specified fill color, center and radius
    *             This function can operate in both coordinate systems with and
    *             without shifted origin.
    *             This is decided by the boolean parameter isOriginShifted.
    */
    func drawSolidCircle(center c: Pair<FloatConvertible,FloatConvertible>,
                         radius r: Float,
                         fillColor: Color,
                         isOriginShifted: Bool)

    /*drawSolidTriangle()
    *params: point1: Pair<FloatConvertible,FloatConvertible>,
    *        point2: Pair<FloatConvertible,FloatConvertible>,
    *        point3: Pair<FloatConvertible,FloatConvertible>,
    *        fillColor: Color,
    *        isOriginShifted: Bool
    *description: Draws a triangle with specified fill color from three specified points
    *             This function can operate in both coordinate systems with
    *             and without shifted origin.
    *             This is decided by the boolean parameter isOriginShifted.
    */
    func drawSolidTriangle(point1: Pair<FloatConvertible,FloatConvertible>,
                           point2: Pair<FloatConvertible,FloatConvertible>,
                           point3: Pair<FloatConvertible,FloatConvertible>,
                           fillColor: Color,
                           isOriginShifted: Bool)

    /*drawSolidPolygon()
    *params: points: [Pair<FloatConvertible,FloatConvertible>],
    *                 fillColor: Color,
    *                 isOriginShifted: Bool
    *description: Draws a polygon with specified fill color from an array of Points
    *             This function can operate in both coordinate systems with and
    *             without shifted origin.
    *             This is decided by the boolean parameter isOriginShifted.
    */
    func drawSolidPolygon(points: [Pair<FloatConvertible,FloatConvertible>],
                          fillColor: Color,
                          isOriginShifted: Bool)

    /*getTextWidth()
    *params: text: String, textSize size: Float
    *description: Returns the width of text that will be drawn in the final
    *             image by the respective renderer
    */
    func getTextWidth(text: String, textSize size: Float) -> Float

    /*drawOutput()
    *params: fileName name: String
    *description: Saves the drawn image to disk
    */
    func drawOutput(fileName name: String)

}
