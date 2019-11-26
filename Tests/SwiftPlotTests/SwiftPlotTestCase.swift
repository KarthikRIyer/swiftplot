import XCTest
@testable import SwiftPlot

class SwiftPlotTestCase: XCTestCase {
  // TODO: Possibly allow setting this via a command-line flag?
  let outputDirectory: String = "./output/"
  
  var aggOutputDirectory: String {
    outputDirectory + "agg/"
  }
  var svgOutputDirectory: String {
    outputDirectory + "svg/"
  }
  #if canImport(QuartzRenderer)
  var coreGraphicsOutputDirectory: String {
    outputDirectory + "coregraphics/"
  }
  #endif
  
  override func setUp() {
    super.setUp()
    
    var allOutputDirectories: [String] = []
    allOutputDirectories.append(aggOutputDirectory)
    allOutputDirectories.append(svgOutputDirectory)
    #if canImport(QuartzRenderer)
    allOutputDirectories.append(coreGraphicsOutputDirectory)
    #endif
    
    do {
      for outputDir in allOutputDirectories {
        try FileManager().createDirectory(atPath: outputDir,
                                          withIntermediateDirectories: true,
                                          attributes: nil)
      }
    } catch {
      fatalError("Failed to create output directory. \(error)")
    }
  }
}
