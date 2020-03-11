import SwiftPlot
import Foundation

extension LineChartTests {
  
  func testLineChart_positiveYOrigin() throws {
    let x:[Float] = [0, 1, 2, 3]
    let y:[Float] = [70, 80, 95, 100]

    var lineGraph = LineGraph<Float,Float>(enablePrimaryAxisGrid: true)
    lineGraph.addSeries(x, y, label: "Plot 1", color: .lightBlue)
    lineGraph.plotTitle.title = "SINGLE SERIES"
    lineGraph.plotLabel.xLabel = "X-AXIS"
    lineGraph.plotLabel.yLabel = "Y-AXIS"
    lineGraph.plotLineThickness = 3.0

    try renderAndVerify(lineGraph, size: Size(width: 300, height: 300))
  }
  
  func testLineChart_positiveYOrigin_secondary() throws {
    let x:[Float] = [0, 1, 2, 3]
    let y:[Float] = [70, 80, 95, 100]
    let y2: [Float] = [-800, -900, -800, -1000]

    var lineGraph = LineGraph<Float,Float>(enablePrimaryAxisGrid: true)
    lineGraph.addSeries(x, y, label: "Plot 1", color: .lightBlue)
    lineGraph.addSeries(x, y2, label: "Plot 2", color: .orange, axisType: .secondaryAxis)
    lineGraph.plotTitle.title = "SINGLE SERIES"
    lineGraph.plotLabel.xLabel = "X-AXIS"
    lineGraph.plotLabel.yLabel = "Y-AXIS"
    lineGraph.plotLabel.y2Label = "Y2-AXIS"
    lineGraph.plotLineThickness = 3.0
    lineGraph.enablePrimaryAxisGrid = true
    lineGraph.enableSecondaryAxisGrid = true
    
    try renderAndVerify(lineGraph, size: Size(width: 400, height: 400))
  }
  
  func testLineChart_negativeYOrigin() throws {
    let x:[Float] = [0, 1, 2, 3]
    let y:[Float] = [-70, -80, -95, -100]

    var lineGraph = LineGraph<Float,Float>(enablePrimaryAxisGrid: true)
    lineGraph.addSeries(x, y, label: "Plot 1", color: .lightBlue)
    lineGraph.plotTitle.title = "SINGLE SERIES"
    lineGraph.plotLabel.xLabel = "X-AXIS"
    lineGraph.plotLabel.yLabel = "Y-AXIS"
    lineGraph.plotLineThickness = 3.0

    try renderAndVerify(lineGraph, size: Size(width: 300, height: 300))
  }
  
  func testLineChart_positiveXOrigin() throws {
    let x:[Float] = [5, 6, 7, 8]
    let y:[Float] = [70, 80, 95, 100]

    var lineGraph = LineGraph<Float,Float>(enablePrimaryAxisGrid: true)
    lineGraph.addSeries(x, y, label: "Plot 1", color: .lightBlue)
    lineGraph.plotTitle.title = "SINGLE SERIES"
    lineGraph.plotLabel.xLabel = "X-AXIS"
    lineGraph.plotLabel.yLabel = "Y-AXIS"
    lineGraph.plotLineThickness = 3.0

    try renderAndVerify(lineGraph, size: Size(width: 300, height: 300))
  }
  
  func testLineChart_negativeXOrigin() throws {
    let x:[Float] = [-5, -6, -7, -8]
    let y:[Float] = [-70, -80, -95, -100]

    var lineGraph = LineGraph<Float,Float>(enablePrimaryAxisGrid: true)
    lineGraph.addSeries(x, y, label: "Plot 1", color: .lightBlue)
    lineGraph.plotTitle.title = "SINGLE SERIES"
    lineGraph.plotLabel.xLabel = "X-AXIS"
    lineGraph.plotLabel.yLabel = "Y-AXIS"
    lineGraph.plotLineThickness = 3.0

    try renderAndVerify(lineGraph, size: Size(width: 300, height: 300))
  }
  
  func testLineChart_positiveXOrigin_secondary() throws {
    let x:[Float] = [0, 1, 2, 3]
    let y:[Float] = [70, 80, 95, 100]
    let x2:[Float] = [-1, -2, -3, -4]
    let y2: [Float] = [80, 90, 80, 100]

    var lineGraph = LineGraph<Float,Float>(enablePrimaryAxisGrid: true)
    lineGraph.addSeries(x, y, label: "Plot 1", color: .lightBlue)
    lineGraph.addSeries(x2, y2, label: "Plot 2", color: .orange, axisType: .secondaryAxis)
    lineGraph.plotTitle.title = "SINGLE SERIES"
    lineGraph.plotLabel.xLabel = "X-AXIS"
    lineGraph.plotLabel.yLabel = "Y-AXIS"
    lineGraph.plotLabel.y2Label = "Y2-AXIS"
    lineGraph.plotLineThickness = 3.0
    lineGraph.enablePrimaryAxisGrid = true
    lineGraph.enableSecondaryAxisGrid = true
    
    try renderAndVerify(lineGraph, size: Size(width: 400, height: 400))
  }
  
  func testLineChart_negativeXOrigin_unsorted() throws {
    let x:[Float] = [-8, -7, -6, -5]
    let y:[Float] = [70, 80, 95, 100]

    var lineGraph = LineGraph<Float,Float>(enablePrimaryAxisGrid: true)
    lineGraph.addSeries(x, y, label: "Plot 1", color: .lightBlue)
    lineGraph.plotTitle.title = "SINGLE SERIES"
    lineGraph.plotLabel.xLabel = "X-AXIS"
    lineGraph.plotLabel.yLabel = "Y-AXIS"
    lineGraph.plotLineThickness = 3.0

    try renderAndVerify(lineGraph, size: Size(width: 300, height: 300))
  }
  
  func testLineChart_crossX() throws {
    func someFunction(_ x: Float) -> Float { (x * x) + 10 }
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
    try renderAndVerify(lineGraph_func, size: Size(width: 400, height: 400))
  }
  
  func testLineChart_crossY() throws {
    func someFunction(_ x: Float) -> Float { 5 * cos(2 * x * x) / x }
    var lineGraph_func = LineGraph<Float,Float>(enablePrimaryAxisGrid: true)
    lineGraph_func.addFunction(someFunction,
                          minX: 1,
                          maxX: 10.0,
                          numberOfSamples: 400,
                          label: "Function",
                          color: .orange)
    lineGraph_func.plotTitle.title = "FUNCTION"
    lineGraph_func.plotLabel.xLabel = "X-AXIS"
    lineGraph_func.plotLabel.yLabel = "Y-AXIS"
    try renderAndVerify(lineGraph_func, size: Size(width: 400, height: 400))
  }
  
  func testLineChart_crossBothAxes() throws {
    var lineGraph = LineGraph<Float,Float>(enablePrimaryAxisGrid: true,
                                           enableSecondaryAxisGrid: false)
    let clamp: ClosedRange<Float>? = -150...150
    lineGraph.addFunction({ pow($0, 2) }, minX: 0, maxX: 5, clampY: clamp, label: "2", color: .lightBlue)
    lineGraph.addFunction({ pow($0, 3) }, minX: 0, maxX: 5, clampY: clamp, label: "3", color: .orange)
    lineGraph.addFunction({ pow($0, 4) }, minX: 0, maxX: 5, clampY: clamp, label: "4", color: .red)
    lineGraph.addFunction({ pow($0, 5) }, minX: 0, maxX: 5, clampY: clamp, label: "5", color: .brown)
    lineGraph.addFunction({ pow($0 , 6) }, minX: 0, maxX: 5, clampY: clamp, label: "6", color: .purple)
    lineGraph.addFunction({ pow($0 , 7) }, minX: 0, maxX: 5, clampY: clamp, label: "7", color: .green)
    lineGraph.plotTitle.title = "y = x^n"
    lineGraph.plotLabel.xLabel = "x"
    lineGraph.plotLabel.yLabel = "y"
            lineGraph.backgroundColor = .transparent
    
    try renderAndVerify(lineGraph, size: Size(width: 800, height: 400))
  }
}
