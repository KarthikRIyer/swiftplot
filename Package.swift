// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftPlot",
    //products: [
    //    // Products define the executables and libraries produced by a package, and make them visible to other packages.
    //    .library(
    //    name: "SwiftPlot",
    //    targets: []),
    //],
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
            name: "LinePlot",
            dependencies: ["Util", "Renderers"],
  	    path: "framework/LinePlot"),
        //.testTarget(
        //  name: "swiftplotTests",
        //  dependencies: ["swiftplot"]),
    ]
)
