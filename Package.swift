// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

#if os(Linux)
let platformTargets: [Target] = [
    .systemLibrary(
        name: "CFreeType",
        path: "framework/CFreeType",
        pkgConfig: "freetype2",
        providers: [.brew(["freetype2"]), .apt(["libfreetype6-dev"])]),
    .target(
        name: "AGG",
        dependencies: ["CFreeType"],
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
    
    .testTarget(
        name: "SwiftPlotTests",
        dependencies: ["AGGRenderer", "SVGRenderer", "SwiftPlot"])
]
let platformProducts: [Product] =  [
    .library(
        name: "SwiftPlot",
        targets: ["AGG", "lodepng", "CPPAGGRenderer", "CAGGRenderer", "SwiftPlot", "SVGRenderer", "AGGRenderer"]
  ),
]

#elseif os(iOS) || os(macOS)
let platformTargets: [Target] = [
    .systemLibrary(
        name: "CFreeType",
        path: "framework/CFreeType",
        pkgConfig: "freetype2",
        providers: [.brew(["freetype2"]), .apt(["libfreetype6-dev"])]),
    .target(
        name: "AGG",
        dependencies: ["CFreeType"],
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
    
    .testTarget(
      name: "SwiftPlotTests",
      dependencies: ["AGGRenderer", "SVGRenderer", "QuartzRenderer", "SwiftPlot"])
]
let platformProducts: [Product] =  [
      .library(
          name: "SwiftPlot",
          targets: ["AGG", "lodepng", "CPPAGGRenderer", "CAGGRenderer", "SwiftPlot", "SVGRenderer", "AGGRenderer", "QuartzRenderer"]
    ),
]
#endif

let package = Package(
    name: "SwiftPlot",
    products: platformProducts,
    targets: platformTargets,
    cxxLanguageStandard: .cxx11
)
