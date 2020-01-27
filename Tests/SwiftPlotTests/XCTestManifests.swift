#if !canImport(ObjectiveC)
import XCTest

extension AGGRendererTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__AGGRendererTests = [
        ("testBase64Encoding", testBase64Encoding),
    ]
}

extension AnnotationTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__AnnotationTests = [
        ("testAnnotationArrow", testAnnotationArrow),
        ("testAnnotationArrowDart", testAnnotationArrowDart),
        ("testAnnotationArrowDoubleHeaded", testAnnotationArrowDoubleHeaded),
        ("testAnnotationArrowWedge", testAnnotationArrowWedge),
        ("testAnnotationText", testAnnotationText),
        ("testAnnotationTextBoundingBox", testAnnotationTextBoundingBox),
    ]
}

extension BarchartTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__BarchartTests = [
        ("testBarchart", testBarchart),
        ("testBarchartHatchedBackslash", testBarchartHatchedBackslash),
        ("testBarchartHatchedCross", testBarchartHatchedCross),
        ("testBarchartHatchedFilledCircle", testBarchartHatchedFilledCircle),
        ("testBarchartHatchedForwardSlash", testBarchartHatchedForwardSlash),
        ("testBarchartHatchedGrid", testBarchartHatchedGrid),
        ("testBarchartHatchedHollowCircle", testBarchartHatchedHollowCircle),
        ("testBarchartHatchedHorizontal", testBarchartHatchedHorizontal),
        ("testBarchartHatchedVertical", testBarchartHatchedVertical),
        ("testBarchartOrientationHorizontal", testBarchartOrientationHorizontal),
        ("testBarchartStackedHorizontal", testBarchartStackedHorizontal),
        ("testBarchartStackedVertical", testBarchartStackedVertical),
    ]
}

extension HistogramTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__HistogramTests = [
        ("testHistogram", testHistogram),
        ("testHistogramMultiStacked", testHistogramMultiStacked),
        ("testHistogramMultiStackedColorBleed", testHistogramMultiStackedColorBleed),
        ("testHistogramMultiStackedStep", testHistogramMultiStackedStep),
        ("testHistogramStacked", testHistogramStacked),
        ("testHistogramStackedStep", testHistogramStackedStep),
        ("testHistogramStackedStepLineJoins", testHistogramStackedStepLineJoins),
        ("testHistogramStackedStepOffset", testHistogramStackedStepOffset),
        ("testHistogramStep", testHistogramStep),
        ("testPerformanceHistogramMethodRecalculateBins", testPerformanceHistogramMethodRecalculateBins),
        ("testPerformanceHistogramMethodRecalculateBinsSorted", testPerformanceHistogramMethodRecalculateBinsSorted),
    ]
}

extension LineChartTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__LineChartTests = [
        ("testLineChart_crossBothAxes", testLineChart_crossBothAxes),
        ("testLineChart_crossX", testLineChart_crossX),
        ("testLineChart_crossY", testLineChart_crossY),
        ("testLineChart_negativeXOrigin_unsorted", testLineChart_negativeXOrigin_unsorted),
        ("testLineChart_negativeXOrigin", testLineChart_negativeXOrigin),
        ("testLineChart_negativeYOrigin", testLineChart_negativeYOrigin),
        ("testLineChart_positiveXOrigin_secondary", testLineChart_positiveXOrigin_secondary),
        ("testLineChart_positiveXOrigin", testLineChart_positiveXOrigin),
        ("testLineChart_positiveYOrigin_secondary", testLineChart_positiveYOrigin_secondary),
        ("testLineChart_positiveYOrigin", testLineChart_positiveYOrigin),
        ("testLineChartFunctionPlot", testLineChartFunctionPlot),
        ("testLineChartMultipleSeries", testLineChartMultipleSeries),
        ("testLineChartSecondaryAxis", testLineChartSecondaryAxis),
        ("testLineChartSingleSeries", testLineChartSingleSeries),
        ("testLineChartSubplotGridStacked", testLineChartSubplotGridStacked),
        ("testLineChartSubplotHorizontallyStacked", testLineChartSubplotHorizontallyStacked),
        ("testLineChartSubplotVerticallyStacked", testLineChartSubplotVerticallyStacked),
    ]
}

extension ScatterPlotTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__ScatterPlotTests = [
        ("testScatterPlot", testScatterPlot),
    ]
}

extension SubPlotTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__SubPlotTests = [
        ("testNestedSubplots", testNestedSubplots),
    ]
}

public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(AGGRendererTests.__allTests__AGGRendererTests),
        testCase(AnnotationTests.__allTests__AnnotationTests),
        testCase(BarchartTests.__allTests__BarchartTests),
        testCase(HistogramTests.__allTests__HistogramTests),
        testCase(LineChartTests.__allTests__LineChartTests),
        testCase(ScatterPlotTests.__allTests__ScatterPlotTests),
        testCase(SubPlotTests.__allTests__SubPlotTests),
    ]
}
#endif
