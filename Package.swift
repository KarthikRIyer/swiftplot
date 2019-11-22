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
        name: "Examples",
        dependencies: ["AGGRenderer", "SVGRenderer", "QuartzRenderer", "SwiftPlot"],
        path: "framework/Examples"),
]
let platformProducts: [Product] =  [
    .library(
        name: "SwiftPlot",
        targets: ["AGG", "lodepng", "CPPAGGRenderer", "CAGGRenderer", "SwiftPlot", "SVGRenderer", "AGGRenderer"]
  ),
    .executable(
        name: "Examples",
        targets: ["Examples"]
  )
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
    dependencies: platformDependencies,
    targets: platformTargets,
    cxxLanguageStandard: .cxx11
)
