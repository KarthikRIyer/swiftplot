// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swiftplot",
    products: [
       // Products define the executables and libraries produced by a package, and make them visible to other packages.
       .library(
       name: "swiftplot",
       targets: ["AGG","lodepng","CPPAGGRenderer","CAGGRenderer","Util","Renderers","SubPlot","LinePlot"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
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
    	    path: "framework/CPPAGGRenderer"),
	.target(
            name: "CAGGRenderer",
            dependencies: ["CPPAGGRenderer"],
    	    path: "framework/CAGGRenderer"),
	.target(
            name: "Util",
            dependencies: [],
       	    path: "framework/Util"),
	.target(
            name: "Renderers",
            dependencies: ["Util","CAGGRenderer"],
       	    path: "framework/Renderers"),
  .target(
            name: "SubPlot",
            dependencies: ["Util","Renderers"],
       	    path: "framework/SubPlot"),
  .target(
            name: "LinePlot",
            dependencies: ["Util", "Renderers", "SubPlot"],
  	        path: "framework/LinePlot"),
	.target(
            name: "LineChartSingleSeriesExample",
            dependencies: ["Util", "Renderers", "LinePlot"],
  	        path: "examples/LineChartSingleSeries"),
  .target(
            name: "LineChartMultipleSeriesExample",
            dependencies: ["Util", "Renderers", "LinePlot"],
        	  path: "examples/LineChartMultipleSeries"),
  .target(
            name: "LineChartSubPlotHorizontallyStackedExample",
            dependencies: ["Util", "Renderers", "LinePlot", "SubPlot"],
            path: "examples/LineChartSubPlotHorizontallyStacked"),
  .target(
            name: "LineChartSubPlotVerticallyStackedExample",
            dependencies: ["Util", "Renderers", "LinePlot", "SubPlot"],
            path: "examples/LineChartSubPlotVerticallyStacked"),
  .target(
            name: "LineChartSubPlotGridStackedExample",
            dependencies: ["Util", "Renderers", "LinePlot", "SubPlot"],
            path: "examples/LineChartSubPlotGridStacked"),
  .target(
            name: "LineChartFunctionPlotExample",
            dependencies: ["Util", "Renderers", "LinePlot"],
            path: "examples/LineChartFunctionPlot"),
        //.testTarget(
        //  name: "swiftplotTests",
        //  dependencies: ["swiftplot"]),
    ]
)
