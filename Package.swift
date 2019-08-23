// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

#if os(Linux)
let platformDependencies: [Package.Dependency] = [
    .package(url:"https://github.com/KarthikRIyer/CFreeType.git", .branch("master"))]
let platformTargets: [Target] = [
    .target(
        name: "AGG",
        dependencies: [],
        path: "framework/AGG"),
    .target(
        name: "lodepng",
        dependencies: [],
        path: "framework/lodepng"),
    .target(
        name: "CPPAGGRenderer",
        dependencies: ["AGG","lodepng"],
        path: "framework/AGGRenderer/CPPAGGRenderer"),
    .target(
        name: "CAGGRenderer",
        dependencies: ["CPPAGGRenderer"],
        path: "framework/AGGRenderer/CAGGRenderer"),
    .target(
        name: "SwiftPlot",
        dependencies: [],
        path: "framework/SwiftPlot"),
    .target(
        name: "AGGRenderer",
        dependencies: ["CAGGRenderer","SwiftPlot"],
        path: "framework/AGGRenderer/AGGRenderer"),
    .target(
        name: "SVGRenderer",
        dependencies: ["SwiftPlot"],
        path: "framework/SVGRenderer"),
    .target(
        name: "LineChartSingleSeriesExample",
        dependencies: ["AGGRenderer", "SVGRenderer", "SwiftPlot"],
        path: "examples/LineChartSingleSeries"),
    .target(
        name: "LineChartMultipleSeriesExample",
        dependencies: ["AGGRenderer", "SVGRenderer", "SwiftPlot"],
        path: "examples/LineChartMultipleSeries"),
    .target(
        name: "LineChartSubPlotHorizontallyStackedExample",
        dependencies: ["AGGRenderer", "SVGRenderer", "SwiftPlot"],
        path: "examples/LineChartSubPlotHorizontallyStacked"),
    .target(
        name: "LineChartSubPlotVerticallyStackedExample",
        dependencies: ["AGGRenderer", "SVGRenderer", "SwiftPlot"],
        path: "examples/LineChartSubPlotVerticallyStacked"),
    .target(
        name: "LineChartSubPlotGridStackedExample",
        dependencies: ["AGGRenderer", "SVGRenderer", "SwiftPlot"],
        path: "examples/LineChartSubPlotGridStacked"),
    .target(
        name: "LineChartFunctionPlotExample",
        dependencies: ["AGGRenderer", "SVGRenderer", "SwiftPlot"],
        path: "examples/LineChartFunctionPlot"),
    .target(
        name: "LineChartSecondaryAxisExample",
        dependencies: ["AGGRenderer", "SVGRenderer", "SwiftPlot"],
        path: "examples/LineChartSecondaryAxis"),
    .target(
        name: "BarChartExample",
        dependencies: ["AGGRenderer", "SVGRenderer", "SwiftPlot"],
        path: "examples/BarChart"),
    .target(
        name: "BarChartForwardSlashHatchedExample",
        dependencies: ["AGGRenderer", "SVGRenderer", "SwiftPlot"],
        path: "examples/BarChartForwardSlashHatched"),
    .target(
        name: "BarChartBackwardSlashHatchedExample",
        dependencies: ["AGGRenderer", "SVGRenderer", "SwiftPlot"],
        path: "examples/BarChartBackwardSlashHatched"),
    .target(
        name: "BarChartVerticalHatchedExample",
        dependencies: ["AGGRenderer", "SVGRenderer", "SwiftPlot"],
        path: "examples/BarChartVerticalHatched"),
    .target(
        name: "BarChartHorizontalHatchedExample",
        dependencies: ["AGGRenderer", "SVGRenderer", "SwiftPlot"],
        path: "examples/BarChartHorizontalHatched"),
    .target(
        name: "BarChartGridHatchedExample",
        dependencies: ["AGGRenderer", "SVGRenderer", "SwiftPlot"],
        path: "examples/BarChartGridHatched"),
    .target(
        name: "BarChartCrossHatchedExample",
        dependencies: ["AGGRenderer", "SVGRenderer", "SwiftPlot"],
        path: "examples/BarChartCrossHatched"),
    .target(
        name: "BarChartHollowCircleHatchedExample",
        dependencies: ["AGGRenderer", "SVGRenderer", "SwiftPlot"],
        path: "examples/BarChartHollowCircleHatched"),
    .target(
        name: "BarChartFilledCircleHatchedExample",
        dependencies: ["AGGRenderer", "SVGRenderer", "SwiftPlot"],
        path: "examples/BarChartFilledCircleHatched"),
    .target(
        name: "BarChartOrientationHorizontalExample",
        dependencies: ["AGGRenderer", "SVGRenderer", "SwiftPlot"],
        path: "examples/BarChartOrientationHorizontal"),
    .target(
        name: "BarChartVerticalStackedExample",
        dependencies: ["AGGRenderer", "SVGRenderer", "SwiftPlot"],
        path: "examples/BarChartVerticalStacked"),
    .target(
        name: "BarChartHorizontalStackedExample",
        dependencies: ["AGGRenderer", "SVGRenderer", "SwiftPlot"],
        path: "examples/BarChartHorizontalStacked"),
    .target(
        name: "ScatterPlotExample",
        dependencies: ["AGGRenderer", "SVGRenderer", "SwiftPlot"],
        path: "examples/ScatterPlot"),
    .target(
        name: "HistogramExample",
        dependencies: ["AGGRenderer", "SVGRenderer", "SwiftPlot"],
        path: "examples/Histogram"),
    .target(
        name: "HistogramStepExample",
        dependencies: ["AGGRenderer", "SVGRenderer", "SwiftPlot"],
        path: "examples/HistogramStep"),
    .target(
        name: "HistogramStackedExample",
        dependencies: ["AGGRenderer", "SVGRenderer", "SwiftPlot"],
        path: "examples/HistogramStacked"),
    .target(
        name: "HistogramStackedStepExample",
        dependencies: ["AGGRenderer", "SVGRenderer", "SwiftPlot"],
        path: "examples/HistogramStackedStep")]
let platformProducts: [Product] =  [
    .library(
        name: "SwiftPlot",
        targets: ["AGG", "lodepng", "CPPAGGRenderer", "CAGGRenderer", "SwiftPlot", "SVGRenderer", "AGGRenderer"]),
]

#elseif os(iOS) || os(macOS)
let platformDependencies: [Package.Dependency] = [
    .package(url:"https://github.com/KarthikRIyer/CFreeType.git", .branch("master"))]
let platformTargets: [Target] = [
    .target(
        name: "AGG",
        dependencies: [],
        path: "framework/AGG"),
    .target(
        name: "lodepng",
        dependencies: [],
        path: "framework/lodepng"),
    .target(
        name: "CPPAGGRenderer",
        dependencies: ["AGG","lodepng"],
        path: "framework/AGGRenderer/CPPAGGRenderer"),
    .target(
        name: "CAGGRenderer",
        dependencies: ["CPPAGGRenderer"],
        path: "framework/AGGRenderer/CAGGRenderer"),
    .target(
        name: "SwiftPlot",
        dependencies: [],
        path: "framework/SwiftPlot"),
    .target(
        name: "QuartzRenderer",
        dependencies: ["SwiftPlot"],
        path: "framework/QuartzRenderer"),
    .target(
        name: "AGGRenderer",
        dependencies: ["CAGGRenderer","SwiftPlot"],
        path: "framework/AGGRenderer/AGGRenderer"),
    .target(
        name: "SVGRenderer",
        dependencies: ["SwiftPlot"],
        path: "framework/SVGRenderer"),
    .target(
        name: "LineChartSingleSeriesExample",
        dependencies: ["AGGRenderer", "SVGRenderer", "QuartzRenderer", "SwiftPlot"],
        path: "examples/LineChartSingleSeries"),
    .target(
        name: "LineChartMultipleSeriesExample",
        dependencies: ["AGGRenderer", "SVGRenderer", "QuartzRenderer", "SwiftPlot"],
        path: "examples/LineChartMultipleSeries"),
    .target(
        name: "LineChartSubPlotHorizontallyStackedExample",
        dependencies: ["AGGRenderer", "SVGRenderer", "QuartzRenderer", "SwiftPlot"],
        path: "examples/LineChartSubPlotHorizontallyStacked"),
    .target(
        name: "LineChartSubPlotVerticallyStackedExample",
        dependencies: ["AGGRenderer", "SVGRenderer", "QuartzRenderer", "SwiftPlot"],
        path: "examples/LineChartSubPlotVerticallyStacked"),
    .target(
        name: "LineChartSubPlotGridStackedExample",
        dependencies: ["AGGRenderer", "SVGRenderer", "QuartzRenderer", "SwiftPlot"],
        path: "examples/LineChartSubPlotGridStacked"),
    .target(
        name: "LineChartFunctionPlotExample",
        dependencies: ["AGGRenderer", "SVGRenderer", "QuartzRenderer", "SwiftPlot"],
        path: "examples/LineChartFunctionPlot"),
    .target(
        name: "LineChartSecondaryAxisExample",
        dependencies: ["AGGRenderer", "SVGRenderer", "QuartzRenderer", "SwiftPlot"],
        path: "examples/LineChartSecondaryAxis"),
    .target(
        name: "BarChartExample",
        dependencies: ["AGGRenderer", "SVGRenderer", "QuartzRenderer", "SwiftPlot"],
        path: "examples/BarChart"),
    .target(
        name: "BarChartForwardSlashHatchedExample",
        dependencies: ["AGGRenderer", "SVGRenderer", "QuartzRenderer", "SwiftPlot"],
        path: "examples/BarChartForwardSlashHatched"),
    .target(
        name: "BarChartBackwardSlashHatchedExample",
        dependencies: ["AGGRenderer", "SVGRenderer", "QuartzRenderer", "SwiftPlot"],
        path: "examples/BarChartBackwardSlashHatched"),
    .target(
        name: "BarChartVerticalHatchedExample",
        dependencies: ["AGGRenderer", "SVGRenderer", "QuartzRenderer", "SwiftPlot"],
        path: "examples/BarChartVerticalHatched"),
    .target(
        name: "BarChartHorizontalHatchedExample",
        dependencies: ["AGGRenderer", "SVGRenderer", "QuartzRenderer", "SwiftPlot"],
        path: "examples/BarChartHorizontalHatched"),
    .target(
        name: "BarChartGridHatchedExample",
        dependencies: ["AGGRenderer", "SVGRenderer", "QuartzRenderer", "SwiftPlot"],
        path: "examples/BarChartGridHatched"),
    .target(
        name: "BarChartCrossHatchedExample",
        dependencies: ["AGGRenderer", "SVGRenderer", "QuartzRenderer", "SwiftPlot"],
        path: "examples/BarChartCrossHatched"),
    .target(
        name: "BarChartHollowCircleHatchedExample",
        dependencies: ["AGGRenderer", "SVGRenderer", "QuartzRenderer", "SwiftPlot"],
        path: "examples/BarChartHollowCircleHatched"),
    .target(
        name: "BarChartFilledCircleHatchedExample",
        dependencies: ["AGGRenderer", "SVGRenderer", "QuartzRenderer", "SwiftPlot"],
        path: "examples/BarChartFilledCircleHatched"),
    .target(
        name: "BarChartOrientationHorizontalExample",
        dependencies: ["AGGRenderer", "SVGRenderer", "QuartzRenderer", "SwiftPlot"],
        path: "examples/BarChartOrientationHorizontal"),
    .target(
        name: "BarChartVerticalStackedExample",
        dependencies: ["AGGRenderer", "SVGRenderer", "QuartzRenderer", "SwiftPlot"],
        path: "examples/BarChartVerticalStacked"),
    .target(
        name: "BarChartHorizontalStackedExample",
        dependencies: ["AGGRenderer", "SVGRenderer", "QuartzRenderer", "SwiftPlot"],
        path: "examples/BarChartHorizontalStacked"),
    .target(
        name: "ScatterPlotExample",
        dependencies: ["AGGRenderer", "SVGRenderer", "QuartzRenderer", "SwiftPlot"],
        path: "examples/ScatterPlot"),
    .target(
        name: "HistogramExample",
        dependencies: ["AGGRenderer", "SVGRenderer", "QuartzRenderer", "SwiftPlot"],
        path: "examples/Histogram"),
    .target(
        name: "HistogramStepExample",
        dependencies: ["AGGRenderer", "SVGRenderer", "QuartzRenderer", "SwiftPlot"],
        path: "examples/HistogramStep"),
    .target(
        name: "HistogramStackedExample",
        dependencies: ["AGGRenderer", "SVGRenderer", "QuartzRenderer", "SwiftPlot"],
        path: "examples/HistogramStacked"),
    .target(
        name: "HistogramStackedStepExample",
        dependencies: ["AGGRenderer", "SVGRenderer", "QuartzRenderer", "SwiftPlot"],
        path: "examples/HistogramStackedStep")]
let platformProducts: [Product] =  [
    .library(
        name: "SwiftPlot",
        targets: ["AGG", "lodepng", "CPPAGGRenderer", "CAGGRenderer", "SwiftPlot", "SVGRenderer", "AGGRenderer", "QuartzRenderer"]),
]
#endif

let package = Package(
    name: "SwiftPlot",
    products: platformProducts,
    dependencies: platformDependencies,
    targets: platformTargets,
    cxxLanguageStandard: .cxx11
)
