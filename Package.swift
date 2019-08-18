// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftPlot",
    products: [
       // Products define the executables and libraries produced by a package, and make them visible to other packages.
       .library(
       name: "SwiftPlot",
       targets: ["AGG", "lodepng", "CPPAGGRenderer", "CAGGRenderer", "SwiftPlot", "SVGRenderer", "AGGRenderer"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url:"https://github.com/KarthikRIyer/CFreeType.git", .branch("master")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
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
            name: "QuartzRenderer",
            dependencies: [],
            path: "framework/QuartzRenderer"),
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
            dependencies: ["AGGRenderer", "SVGRenderer","QuartzRenderer", "SwiftPlot"],
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
            path: "examples/HistogramStackedStep"),
        //.testTarget(
        //  name: "swiftplotTests",
        //  dependencies: ["swiftplot"]),
    ],
    cxxLanguageStandard: .cxx11
)
