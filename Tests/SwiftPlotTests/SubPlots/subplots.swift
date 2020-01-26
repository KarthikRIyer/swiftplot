import Foundation
import SwiftPlot
import SVGRenderer
#if canImport(AGGRenderer)
import AGGRenderer
#endif
#if canImport(QuartzRenderer)
import QuartzRenderer
#endif

@available(tvOS 13.0, watchOS 6.0, *)
extension SubPlotTests {
    
    func testNestedSubplots() throws {
        
        let fileName = "_29_nested_subplots"
        
        // ScatterPlot.
        let xValues = Array(-50...50).map { Float($0) }
        let yValues = xValues.map { $0 + (5 * sin($0)) }
        var scatterPlot = ScatterPlot<Float,Float>(enableGrid: true)
        scatterPlot.addSeries(xValues, yValues, label: "Plot 1",
                              startColor: .gold, endColor: .blue, scatterPattern: .circle)
        scatterPlot.addSeries(xValues, yValues.map { 2 * $0 + (5 * sin($0)) }, label: "Plot 2",
                              color: .darkRed, scatterPattern: .triangle)
        scatterPlot.plotTitle.title = "SCATTER PLOT"
        scatterPlot.plotLabel.xLabel = "X-AXIS"
        scatterPlot.plotLabel.yLabel = "Y-AXIS"
        
        // LineGraph (function).
        func someFunction(_ x: Float) -> Float { x * x * x }
        var lineGraph_func = LineGraph<Float,Float>(enablePrimaryAxisGrid: true)
        lineGraph_func.addFunction(someFunction,
                              minX: -4.0,
                              maxX: 4.0,
                              numberOfSamples: 400,
                              label: "Function",
                              color: .orange)
        lineGraph_func.plotTitle.title = "FUNCTION"
        lineGraph_func.plotLabel.xLabel = "X-AXIS"
        lineGraph_func.plotLabel.yLabel = "Y-AXIS"
        
        // LineGraph (data).
        let x:[Float] = [0,100,263,489]
        let y:[Float] = [0,320,310,170]
        var lineGraph_data = LineGraph<Float,Float>(enablePrimaryAxisGrid: true)
        lineGraph_data.addSeries(x, y, label: "Plot 1", color: .lightBlue)
        lineGraph_data.plotTitle.title = "PLOT 1"
        lineGraph_data.plotLabel.xLabel = "X-AXIS"
        lineGraph_data.plotLabel.yLabel = "Y-AXIS"
        lineGraph_data.plotLabel.size = 12
        lineGraph_data.markerTextSize = 10
        
        // Make an inner-subplot containing the 3 graphs (and, indeed, repeating one of the graphs).
        let innerSubplot = SubPlot(layout: .grid(rows: 2, columns: 2),
                                   plots: [scatterPlot, lineGraph_func, lineGraph_data, lineGraph_data])
        // The plots thicken. Make an outer subplot of the same graphs, plus the inner subplot.
        let subplot = SubPlot(layout: .grid(rows: 2, columns: 2),
                              plots: [scatterPlot, lineGraph_func, lineGraph_data, innerSubplot])
        
        let imageSize = Size(width: 1000, height: 1000)
        try renderAndVerify(subplot, size: imageSize, fileName: fileName)
    }
}
