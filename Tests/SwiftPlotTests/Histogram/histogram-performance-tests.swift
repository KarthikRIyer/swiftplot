import XCTest
@testable import SwiftPlot
import SVGRenderer
#if canImport(AGGRenderer)
import AGGRenderer
#endif
#if canImport(QuartzRenderer)
import QuartzRenderer
#endif

extension HistogramTests {
    
    /// Performance tests for the `recalculateBins` method on `Histogram`.
    func testPerformanceHistogramCreateSeriesAndRecalculateBins_NonSorting() throws {
        let histogram = Histogram<Float>(isNormalized: false, enableGrid: false)
        
        let histogramSeries = HistogramSeries(data: histogram_step_values, bins: 50, label: "HISTOGRAM PERFORMANCE `recalculateBins`", color: .black, histogramType: .bar)
        measure {
            histogram.testRecalculateBins(series: histogramSeries, binStart: 40, binEnd: 160, binInterval: (160-40)/Float(histogram.histogramSeries.bins))
        }
    }
}
