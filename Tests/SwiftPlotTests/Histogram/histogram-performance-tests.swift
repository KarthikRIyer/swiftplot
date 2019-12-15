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
    func testPerformanceHistogramMethodRecalculateBinsSorted() throws {
        
        let histogram = Histogram<Float>(isNormalized: false, enableGrid: false)
        
        
        histogram.addSeries(data: histogram_step_values, bins: 50, label: "HISTOGRAM PERFORMANCE `recalculateBins` SORTED DATA")
        
        histogram.histogramSeries.binFrequency = []
        measure {
            histogram.recalculateBins(series: histogram.histogramSeries, binStart: 40, binEnd: 160, binInterval: (160-40)/Float(histogram.histogramSeries.bins))
        }
    }
    
    func testPerformanceHistogramMethodRecalculateBins() throws {
        let histogram = Histogram<Float>(isNormalized: false, enableGrid: false)
        
        
        histogram.addSeries(data: histogram_step_values, bins: 50, label: "HISTOGRAM PERFORMANCE `recalculateBins`")
        
        histogram.histogramSeries.data = histogram_step_values
        histogram.histogramSeries.binFrequency = []
        measure {
            histogram.recalculateBins(series: histogram.histogramSeries, binStart: 40, binEnd: 160, binInterval: (160-40)/Float(histogram.histogramSeries.bins))
        }
    }
}
