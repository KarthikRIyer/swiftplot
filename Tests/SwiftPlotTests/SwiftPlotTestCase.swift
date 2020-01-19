import XCTest
@testable import SwiftPlot

class SwiftPlotTestCase: XCTestCase {
  
  override func setUp() {
    super.setUp()
    do {
      for outputDir in allOutputDirectories {
        try FileManager.default.createDirectory(
          atPath: outputDir, withIntermediateDirectories: true, attributes: nil
        )
      }
    } catch {
      fatalError("Failed to create output directory. \(error)")
    }
  }
}

enum KnownRenderer {
  case agg
  case coreGraphics
  case svg
  
  var subdirectory: String {
    switch self {
    case .agg: return "agg"
    case .coreGraphics: return "quartz"
    case .svg: return "svg"
    }
  }
  
  var fileExtension: String {
    switch self {
    case .svg: return "svg"
    default:   return "png"
    }
  }
}

// TODO: Possibly allow setting this via a command-line flag?
fileprivate let outputDirectoryRoot: String = { () -> String? in
  ProcessInfo.processInfo.environment["SWIFTPLOT_TEST_OUTPUT"]
}() ?? "./output/"

fileprivate let referenceDirectoryRoot: URL = {
  // #file = SwiftPlotTests/swiftPlotTestCase.swift
  var referenceDirectory = URL(fileURLWithPath: #file)
  referenceDirectory.deleteLastPathComponent() // swiftPlotTestCase.swift
  referenceDirectory.appendPathComponent("Reference")
  precondition(FileManager.default.fileExists(atPath: referenceDirectory.path),
               "Could not find reference images at \(referenceDirectory.path)")
  return referenceDirectory
}()

func outputDirectory(for renderer: KnownRenderer) -> URL {
  return URL(fileURLWithPath: outputDirectoryRoot)
    .appendingPathComponent(renderer.subdirectory, isDirectory: true)
}

func referenceDirectory(for renderer: KnownRenderer) -> URL {
  return referenceDirectoryRoot
    .appendingPathComponent(renderer.subdirectory, isDirectory: true)
}

fileprivate let allOutputDirectories: [String] = {
  var allOutputDirectories: [String] = []
  allOutputDirectories.append(outputDirectory(for: .svg).path)
  #if canImport(AGGRenderer)
  allOutputDirectories.append(outputDirectory(for: .agg).path)
  #endif
  #if canImport(QuartzRenderer)
  allOutputDirectories.append(outputDirectory(for: .coreGraphics).path)
  #endif
  return allOutputDirectories
}()

// Helpers for test cases.

var svgOutputDirectory: String {
  outputDirectory(for: .svg).path + "/"
}
#if canImport(AGGRenderer)
var aggOutputDirectory: String {
  outputDirectory(for: .agg).path + "/"
}
#endif
#if canImport(QuartzRenderer)
var coreGraphicsOutputDirectory: String {
  outputDirectory(for: .coreGraphics).path + "/"
}
#endif

/// Verifies that the image rendered by a test is equal to the reference image,
/// otherwise, generates a test failure.
///
func verifyImage(name: String, renderer: KnownRenderer) {
  let outputFile = outputDirectory(for: renderer)
    .appendingPathComponent(name).appendingPathExtension(renderer.fileExtension)
  XCTAssertTrue(FileManager.default.fileExists(atPath: outputFile.path),
                "🤷‍♂️ Could not find output file: \(outputFile.path)")
  
  let referenceFile = referenceDirectory(for: renderer)
    .appendingPathComponent(name).appendingPathExtension(renderer.fileExtension)
  XCTAssertTrue(FileManager.default.fileExists(atPath: referenceFile.path),
                "🤷‍♂️ Could not find reference file: \(referenceFile.path)")
  
  XCTAssertTrue(
    FileManager.default.contentsEqual(atPath: outputFile.path, andPath: referenceFile.path),
    "🔥 Image mismatch: \(name) (\(renderer.subdirectory))"
  )
  // TODO: If the test fails, take a visual diff.
  // In the mean time, https://www.diffchecker.com/image-diff seems pretty good.
}

// Render-and-verify helper for non-example testcases.

import SVGRenderer
#if canImport(AGGRenderer)
import AGGRenderer
#endif
#if canImport(QuartzRenderer)
import QuartzRenderer
#endif

extension SwiftPlotTestCase {
  
  func renderAndVerify(_ plot: Plot, size: Size = Size(width: 1000, height: 660),
                       fileName: String = #function) throws {
    var fileName = fileName
    if fileName.hasSuffix("()") { fileName.removeLast(2) }
    let svg_renderer = SVGRenderer()
    try plot.drawGraphAndOutput(size: size,
                                fileName: svgOutputDirectory+fileName,
                                renderer: svg_renderer)
    verifyImage(name: fileName, renderer: .svg)
    #if canImport(AGGRenderer)
    let agg_renderer = AGGRenderer()
    try plot.drawGraphAndOutput(size: size,
                                fileName: aggOutputDirectory+fileName,
                                renderer: agg_renderer)
    verifyImage(name: fileName, renderer: .agg)
    #endif
    #if canImport(QuartzRenderer)
    let quartz_renderer = QuartzRenderer()
    try plot.drawGraphAndOutput(size: size,
                                fileName: coreGraphicsOutputDirectory+fileName,
                                renderer: quartz_renderer)
    verifyImage(name: fileName, renderer: .coreGraphics)
    #endif
  }
}
