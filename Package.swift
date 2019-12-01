// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

#if os(Linux)

let platformTargets: [Target] = [
    .target(name: "SwiftPlot"),
    
    // AGG renderer and dependencies.
    .systemLibrary(
        name: "CFreeType",
        pkgConfig: "freetype2",
        providers: [.brew(["freetype2"]), .apt(["libfreetype6-dev"])]),
    .target(
        name: "AGG",
        dependencies: ["CFreeType"]),
    .target(name: "lodepng"),
    .target(
        name: "CPPAGGRenderer",
        dependencies: ["AGG","lodepng"],
        path: "Sources/AGGRenderer/CPPAGGRenderer"),
    .target(
        name: "CAGGRenderer",
        dependencies: ["CPPAGGRenderer"],
        path: "Sources/AGGRenderer/CAGGRenderer"),
    .target(
        name: "AGGRenderer",
        dependencies: ["CAGGRenderer","SwiftPlot"],
        path: "Sources/AGGRenderer/AGGRenderer"),

    // Other renderers.
    .target(
        name: "SVGRenderer",
        dependencies: ["SwiftPlot"]),
    
    .testTarget(
      name: "SwiftPlotTests",
      dependencies: ["AGGRenderer", "SVGRenderer", "SwiftPlot"])
]
let platformProducts: [Product] =  [
  .library(name: "SwiftPlot", targets: ["SwiftPlot"]),
  .library(name: "SVGRenderer", targets: ["SVGRenderer"]),
  .library(name: "AGGRenderer", targets: ["AGGRenderer"]),
]

// Building for iOS/tvOS/watchOS:
// Change the condition below to "!os(macOS)".
#elseif os(macOS)

let platformTargets: [Target] = [
    .target(name: "SwiftPlot"),
    
    // AGG renderer and dependencies.
    .systemLibrary(
        name: "CFreeType",
        pkgConfig: "freetype2",
        providers: [.brew(["freetype2"]), .apt(["libfreetype6-dev"])]),
    .target(
        name: "AGG",
        dependencies: ["CFreeType"]),
    .target(name: "lodepng"),
    .target(
        name: "CPPAGGRenderer",
        dependencies: ["AGG","lodepng"],
        path: "Sources/AGGRenderer/CPPAGGRenderer"),
    .target(
        name: "CAGGRenderer",
        dependencies: ["CPPAGGRenderer"],
        path: "Sources/AGGRenderer/CAGGRenderer"),
    .target(
        name: "AGGRenderer",
        dependencies: ["CAGGRenderer","SwiftPlot"],
        path: "Sources/AGGRenderer/AGGRenderer"),

    // Other renderers.
    .target(
        name: "SVGRenderer",
        dependencies: ["SwiftPlot"]),
    .target(
        name: "QuartzRenderer",
        dependencies: ["SwiftPlot"]),
    
    .testTarget(
      name: "SwiftPlotTests",
      dependencies: [
        "AGGRenderer",
        "SVGRenderer", "QuartzRenderer", "SwiftPlot"])
]
let platformProducts: [Product] =  [
  .library(name: "SwiftPlot", targets: ["SwiftPlot"]),
  .library(name: "SVGRenderer", targets: ["SVGRenderer"]),
  .library(name: "AGGRenderer", targets: ["AGGRenderer"]),
  .library(name: "QuartzRenderer", targets: ["QuartzRenderer"])
]

#elseif os(iOS) || os(tvOS) || os(watchOS) || os(macOS)

let platformTargets: [Target] = [
    .target(name: "SwiftPlot"),
    
    .target(
        name: "SVGRenderer",
        dependencies: ["SwiftPlot"]),
    .target(
        name: "QuartzRenderer",
        dependencies: ["SwiftPlot"]),
    
    .testTarget(
      name: "SwiftPlotTests",
      dependencies: ["SVGRenderer", "QuartzRenderer", "SwiftPlot"])
]
let platformProducts: [Product] =  [
  .library(name: "SwiftPlot", targets: ["SwiftPlot"]),
  .library(name: "SVGRenderer", targets: ["SVGRenderer"]),
  .library(name: "QuartzRenderer", targets: ["QuartzRenderer"])
]

#endif

let package = Package(
    name: "SwiftPlot",
    products: platformProducts,
    targets: platformTargets,
    cxxLanguageStandard: .cxx11
)
