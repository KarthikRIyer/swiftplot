public protocol Renderer: AnyObject{

    /*property: offset
    *description: Specifies the offset for everything in the
    *             particular SubPlot being rendered currently.
    */
    var offset: Point { get set }

    /*property: imageSize
    *description: Specifies the dimensions of the particular Image and SubPlot
                  being renderered currently.
    */
    var imageSize: Size { get set }

    /*drawRect()
    *params: topLeftPoint p1: Point,
             topRightPoint p2: Point,
             bottomRightPoint p3: Point,
             bottomLeftPoint p4: Point,
             strokeWidth thickness: Float,
             strokeColor: Color,
             isOriginShifted: Bool
    *description: Draws a rectangle with white fill and border of the specified
    *             color and thickness.
    *             This function can operate in both coordinate systems with and
    *             without shifted origin. This is decided by the boolean
    *             parameter 'isOriginShifted'.
    */
    func drawRect(_ rect: Rect,
                  strokeWidth thickness: Float,
                  strokeColor: Color)

    /*drawSolidRect()
    *params: topLeftPoint p1: Point,
    *        topRightPoint p2: Point,
    *        bottomRightPoint p3: Point,
    *        bottomLeftPoint p4: Point,
    *        fillColor: Color,
    *        hatchPattern: BarGraphSeriesOptions.Hatching,
    *        isOriginShifted: Bool
    *description: Draws a rectangle with a fill of specified color and no border.
    *             This function can operate in both coordinate systems with and
    *             without shifted origin.
    *             This is decided by the boolean parameter 'isOriginShifted'.
    */
    func drawSolidRect(_ rect: Rect,
                       fillColor: Color,
                       hatchPattern: BarGraphSeriesOptions.Hatching)

    /*drawLine()
    *params: startPoint p1: Point,
    *        endPoint p2: Point,
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
    func drawLine(startPoint p1: Point,
                  endPoint p2: Point,
                  strokeWidth thickness: Float,
                  strokeColor: Color, isDashed: Bool)

    /*drawPlotLines()
    *params: points p: [Point],
    *        strokeWidth thickness: Float,
    *        strokeColor: Color,
    *        isDashed: Bool
    *description: Draws all the line segments in a single data series for a Line Graph.
    *             This function always operates in the coordinate system with the shifted origin.
    */
    func drawPlotLines(points p: [Point],
                       strokeWidth thickness: Float,
                       strokeColor: Color, isDashed: Bool)

    /*drawText()
    *params: text s: String,
    *        location p: Point,
    *        textSize size: Float,
    *        color: Color,
    *        strokeWidth thickness: Float,
    *        angle: Float,
    *        isOriginShifted: Bool
    *description: Draws specified text with specified size,
    *             rotated at the specified angle.
    *             This function can operate in both coordinate systems with and
    *             without shifted origin. This is decided by the boolean parameter isOriginShifted.
    */
    func drawText(text s: String,
                  location p: Point,
                  textSize size: Float,
                  color: Color,
                  strokeWidth thickness: Float,
                  angle: Float)

    /*drawSolidRectWithBorder()
    *params: topLeftPoint p1: Point,
    *        topRightPoint p2: Point,
    *        bottomRightPoint p3: Point,
    *        bottomLeftPoint p4: Point,
    *        strokeWidth thickness: Float, fillColor: Color,
    *        borderColor: Color,
    *        isOriginShifted: Bool
    *description: Draws a rectangle with specified fill color, border color and border thickness
    *             This function can operate in both coordinate systems with and without shifted origin.
    *             This is decided by the boolean parameter isOriginShifted.
    */
    func drawSolidRectWithBorder(_ rect: Rect,
                                 strokeWidth thickness: Float,
                                 fillColor: Color,
                                 borderColor: Color)

    /*drawSolidCircle()
    *params: center c: Point,
    *        radius r: Float,
    *        fillColor: Color,
    *        isOriginShifted: Bool
    *description: Draws a circle with specified fill color, center and radius
    *             This function can operate in both coordinate systems with and
    *             without shifted origin.
    *             This is decided by the boolean parameter isOriginShifted.
    */
    func drawSolidCircle(center c: Point,
                         radius r: Float,
                         fillColor: Color)


    /*drawSolidEllipse()
    *params: center c: Point,
    *        radiusX rx: Float,
    *        radiusY rx: Float,
    *        fillColor: Color,
    *        isOriginShifted: Bool
    *description: Draws an ellipse with specified fill color, center and radii
    *             This function can operate in both coordinate systems with and
    *             without shifted origin.
    *             This is decided by the boolean parameter isOriginShifted.
    */
    func drawSolidEllipse(center c: Point,
                          radiusX rx: Float,
                          radiusY ry: Float,
                          fillColor: Color)

    /*drawSolidTriangle()
    *params: point1: Point,
    *        point2: Point,
    *        point3: Point,
    *        fillColor: Color,
    *        isOriginShifted: Bool
    *description: Draws a triangle with specified fill color from three specified points
    *             This function can operate in both coordinate systems with
    *             and without shifted origin.
    *             This is decided by the boolean parameter isOriginShifted.
    */
    func drawSolidTriangle(point1: Point,
                           point2: Point,
                           point3: Point,
                           fillColor: Color)

    /*drawSolidPolygon()
    *params: points: [Point],
    *                 fillColor: Color,
    *                 isOriginShifted: Bool
    *description: Draws a polygon with specified fill color from an array of Points
    *             This function can operate in both coordinate systems with and
    *             without shifted origin.
    *             This is decided by the boolean parameter isOriginShifted.
    */
    func drawSolidPolygon(points: [Point],
                          fillColor: Color)

    /*getTextWidth()
    *params: text: String, textSize size: Float
    *description: Returns the width of text that will be drawn in the final
    *             image by the respective renderer
    */
    func getTextLayoutSize(text: String, textSize size: Float) -> Size

    /*drawOutput()
    *params: fileName name: String
    *description: Saves the drawn image to disk
    */
    func drawOutput(fileName name: String) throws

}

extension Renderer {

    public var xOffset: Float {
        get { return offset.x }
        set { offset.x = newValue}
    }
    public var yOffset: Float {
        get { return offset.y }
        set { offset.y = newValue}
    }
    func getTextWidth(text: String, textSize size: Float) -> Float {
        return getTextLayoutSize(text: text, textSize: size).width
    }

    public func withAdditionalOffset(_ offset: Point, _ perform: (Self) throws -> Void) rethrows {
        let oldOffset = (self.xOffset, self.yOffset)
        self.xOffset += offset.x
        self.yOffset += offset.y
        try perform(self)
        (self.xOffset, self.yOffset) = oldOffset
    }
}
