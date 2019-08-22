<div><img src="swiftplot.png" width="600"></div>
<br>

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
<br>

# Table of contents

  * [Overview](#overview)
  * [License](#license)
  * [How to include the library in your package](#how-to-include-the-library-in-your-package)
  * [How to include the library in your Jupyter Notebook](#how-to-include-the-library-in-your-jupyter-notebook)
  * [Examples](#examples)
    * [Simple Line Graph](#simple-line-graph)
    * [Line Graph with multiple series of data](#line-graph-with-multiple-series-of-data)
    * [Line Graph with Sub Plots stacked horizontally](#line-graph-with-sub-plots-stacked-horizontally)
    * [Plot functions using LineGraph](#plot-functions-using-linegraph)
    * [Using a secondary axis in LineGraph](#using-a-secondary-axis-in-linegraph)
    * [Displaying plots in Jupyter Notebook](#displaying-plots-in-jupyter-notebook)
  * [How does this work ?](#how-does-this-work)
  * [Documentation](#documentation)
  * [Limitations](#limitations)
  * [Credits](#credits)

## Overview
The SwiftPlot framework is a cross-platform library that lets you plot graphs natively in Swift.
The existing Swift plotting frameworks (such as CorePlot) run only on iOS or Mac.
The idea behind SwiftPlot is to create a cross-platform library that runs on iOS, Mac, Linux and Windows.
</br>
</br>
SwiftPlot currently uses two rendering backends to generate plots:
- Anti-Grain Geometry(AGG) C++ rendering library
- A simple SVG Renderer

To encode the plots as PNG images it uses the [lodepng](https://github.com/lvandeve/lodepng) library.
</br>
SwiftPlot can also be used in Jupyter Notebooks.
</br>

Examples, demonstrating all the features, have been included with the repository under the `examples` directory.
To run the examples, clone the repository, and run the run_examples.sh script as shown below.

```console
run_examples.sh
```
Jupyter Notebook examples are under the `Notebooks` directory.

The resultant images are stored in the `examples/Reference` directory. The images rendered by each of the backends are stored their respective directories: [agg](https://github.com/KarthikRIyer/swiftplot/tree/master/examples/Reference/agg), [svg](https://github.com/KarthikRIyer/swiftplot/tree/master/examples/Reference/svg) and [quartz](https://github.com/KarthikRIyer/swiftplot/tree/master/examples/Reference/svg)


## License

<b>SwiftPlot</b> is licensed under `Apache 2.0`. View [license](https://github.com/KarthikRIyer/swiftplot/blob/master/LICENSE)

## How to include the library in your package
Add the library to your projects dependencies in the Package.swift file as shown below.
```swift
dependencies: [
        .package(url: "https://github.com/KarthikRIyer/swiftplot.git", .exact("0.0.1")),
    ],
```

In case you get an error saying that a file <b>ft2build.h</b> is not found, you need to install the freetype development package.

<b>Linux</b></br>
```console
sudo apt-get install libfreetype6-dev
```

<b>macOS</b></br>
```console
brew install freetype
```

If the above method doesn't work you can also build and install freetype on your own. You can find the source code and build instructions [here](https://www.freetype.org/download.html).

## How to include the library in your Jupyter Notebook
<b>Currently this is broken for the latest release. It will be fixed in the future.</b></br>
Add this line to the first cell:
```swift
%install '.package(url: "https://github.com/KarthikRIyer/swiftplot", from: "0.0.1")' SwiftPlot
```
In order to display the generated plot in the notebook, add this line:
```swift
%include "EnableJupyterDisplay.swift"
```

## Examples
Here are some examples to provide you with a headstart to using this library. Here we will be looking at plots using only the AGGRenderer, but the procedure will remain the same for SVGRenderer and QuartzRenderer too. QuartzRenderer is available only on macOS and iOS.
To use the library in your package, include it as a dependency to your target, in the Package.swift file.

#### Simple Line Graph

```swift
import SwiftPlot
import AGGRenderer

let x:[Float] = [10,100,263,489]
let y:[Float] = [10,120,500,800]

var agg_renderer: AGGRenderer = AGGRenderer()
var lineGraph = LineGraph<Float,Float>(enablePrimaryAxisGrid: true)
lineGraph.addSeries(x, y, label: "Plot 1", color: .lightBlue)
lineGraph.plotTitle = PlotTitle("SINGLE SERIES")
lineGraph.plotLabel = PlotLabel(xLabel: "X-AXIS", yLabel: "Y-AXIS")
lineGraph.plotLineThickness = 3.0
lineGraph.drawGraphAndOutput(fileName: filePath+"agg/"+fileName, renderer: agg_renderer)
```
<img src="examples/Reference/agg/_01_single_series_line_chart.png" width="500">

#### Line Graph with multiple series of data

```swift
import SwiftPlot
import AGGRenderer
import SVGRenderer

let x1:[Float] = [0,100,263,489]
let y1:[Float] = [0,320,310,170]
let x2:[Float] = [0,50,113,250]
let y2:[Float] = [0,20,100,170]

var agg_renderer: AGGRenderer = AGGRenderer()
var lineGraph = LineGraph<Float,Float>(enablePrimaryAxisGrid: true)
lineGraph.addSeries(x1, y1, label: "Plot 1", color: .lightBlue)
lineGraph.addSeries(x2, y2, label: "Plot 2", color: .orange)
lineGraph.plotTitle = PlotTitle("MULTIPLE SERIES")
lineGraph.plotLabel = PlotLabel(xLabel: "X-AXIS", yLabel: "Y-AXIS")
lineGraph.plotLineThickness = 3.0
lineGraph.drawGraphAndOutput(fileName: filePath+"agg/"+fileName, renderer: agg_renderer)
```

<img src="examples/Reference/agg/_02_multiple_series_line_chart.png" width="500">

#### Line Graph with Sub Plots stacked horizontally

```swift
import SwiftPlot
import AGGRenderer

let x:[Float] = [10,100,263,489]
let y:[Float] = [10,120,500,800]

var agg_renderer: AGGRenderer = AGGRenderer()
var plots = [Plot]()

var lineGraph1 = LineGraph<Float,Float>(enablePrimaryAxisGrid: true)
lineGraph1.addSeries(x, y, label: "Plot 1", color: .lightBlue)
lineGraph1.plotTitle = PlotTitle("PLOT 1")
lineGraph1.plotLabel = PlotLabel(xLabel: "X-AXIS", yLabel: "Y-AXIS")
lineGraph1.plotLineThickness = 3.0

var lineGraph2 = LineGraph<Float,Float>(enablePrimaryAxisGrid: true)
lineGraph2.addSeries(x, y, label: "Plot 2", color: .orange)
lineGraph2.plotTitle = PlotTitle("PLOT 2")
lineGraph2.plotLabel = PlotLabel(xLabel: "X-AXIS", yLabel: "Y-AXIS")
lineGraph2.plotLineThickness = 3.0

plots.append(lineGraph1)
plots.append(lineGraph2)

var subPlot: SubPlot = SubPlot(numberOfPlots: 2, stackPattern: .horizontallyStacked)
subPlot.draw(plots: plots, renderer: agg_renderer, fileName: "subPlotsHorizontallyStacked")
```

<img src="examples/Reference/agg/_03_sub_plot_horizontally_stacked_line_chart.png" width="500">

#### Plot functions using LineGraph

```swift
import Foundation
import SwiftPlot
import AGGRenderer

func function(_ x: Float)->Float {
    return 1.0/x
}

var agg_renderer: AGGRenderer = AGGRenderer()
var lineGraph = LineGraph<Float,Float>(enablePrimaryAxisGrid: true)
lineGraph.addFunction(function, minX: -5.0, maxX: 5.0, numberOfSamples: 400, label: "Function", color: .orange)
lineGraph.plotTitle = PlotTitle("FUNCTION")
lineGraph.plotLabel = PlotLabel(xLabel: "X-AXIS", yLabel: "Y-AXIS")
lineGraph.drawGraphAndOutput(fileName: "functionPlotLineGraph", renderer: agg_renderer)
```

<img src="examples/Reference/agg/_06_function_plot_line_chart.png" width="500">

#### Using a secondary axis in LineGraph

```swift
import SwiftPlot
import AGGRenderer

let x:[Float] = [10,100,263,489]
let y:[Float] = [10,120,500,800]
let x1:[Float] = [100,200,361,672]
let y1:[Float] = [150,250,628,800]

var lineGraph = LineGraph<Float,Float>()
lineGraph.addSeries(x1, y1, label: "Plot 1", color: .lightBlue, axisType: .primaryAxis)
lineGraph.addSeries(x, y, label: "Plot 2", color: .orange, axisType: .secondaryAxis)
lineGraph.plotTitle = PlotTitle("SECONDARY AXIS")
lineGraph.plotLabel = PlotLabel(xLabel: "X-AXIS", yLabel: "Y-AXIS")
lineGraph.plotLineThickness = 3.0
lineGraph.drawGraphAndOutput(fileName: filePath+"agg/"+fileName, renderer: agg_renderer)
```
The series plotted on the secondary axis are drawn dashed.

<img src="examples/Reference/agg/_07_secondary_axis_line_chart.png" width="500">

#### Displaying plots in Jupyter Notebook

You can display plots in Jupyter Notebook using only the AGGRenderer.
To do so, create the plots as shown in the above examples and instead of using the `drawGraphAndOutput` function from LineGraph, use the `drawGraph` function, then get a base64 encoded image from the AGGRenderer and pass it to the display function as showm below:
```swift
lineGraph.drawGraph(renderer: agg_renderer)
display(base64EncodedPNG: agg_renderer.base64Png())
```

## How does this work

All the plotting code, utility functions, and necessary types are included in the SwiftPlot module. Each Renderer is implemented as a separate module. Each Renderer must have SwiftPlot as its dependency and must conform to the Renderer protocol defined in Renderer.swift in the SwiftPlot module. Each plot type is a generic that accepts data conforming to a protocol, FloatConvertible. At the moment FloatConvertible supports both Float and Double.
The Renderer protocol defines all the necessary functions that a Renderer needs to implement. 
Each Plot must conform to the Plot protocol. At the moment this protocol defines the necessary variablse and functions that each Plot must implement in order to support SubPlots.
</br></br>
You can add series to the plots using their respective functions(`addSeries` for LineGraph). This is stored in as an array of Series objects. You can set other properties such as plotTitle, plotLabel, plotDimensions, etc. To actually generate the plot you need to call either the `drawGraph` or `drawGraphAndOutput` function. This calculates all the parameters necessary to generate the plots such as the coordinates of the border, scaled points to plot, etc. Then it sends over this information to the renderer which has functions to draw primitives like lines, rectangles and text.
</br></br>
In case the Renderer is in C++(here in the case of AGG), a C wrapper is written which is in turn wrapped in Swift.
</br></br>
In order to display the plots in Jupyter notebook, we encode the image(which is in the form of an RGB buffer) to a PNG image in memory and return the encoded image to the Swift code where it is stored as NSData. Then it is encoded to base64 and passed to the display function in swift-jupyter which finally displays the image.

## Documentation

### LineGraph<T: FloatConvertible, U: FloatConvertible>

|Function                                                                            |Description                                 |
|------------------------------------------------------------------------------------|--------------------------------------------|
|init(points: [Point], width: Float = 1000, height: Float = 660, enablePrimaryAxisGrid: Bool = false,
                                                                 enableSecondaryAxisGrid: Bool = false)                     |Initialize a LineGraph with a set of points |
|init(width: Float = 1000, height: Float = 660, enablePrimaryAxisGrid: Bool = false,
                                                enableSecondaryAxisGrid: Bool = false)                                      |Initialize a LineGraph                      |
|addSeries(_ s: Series, axisType: Axis.Location = Axis.Location.primaryAxis)         |Add a series to the plot                    |
|addSeries(points p: [Point], label: String, color: Color = Color.lightBlue, axisType: Axis<T,U>.Location = Axis<T,U>.Location.primaryAxis)         |Add a series to the plot with a set of points, a label and a color for the series |
|addSeries(_ x: [Float], _ y: [Float], label: String, color: Color = Color.lightBlue, axisType: Axis<T,U>.Location = Axis<T,U>.Location.primaryAxis)|Add a series to the plot with a set of x and y coordinates, a label and a color for the series|
|addSeries(_ y: [Float], label: String, color: Color = Color.lightBlue, axisType: Axis<T,U>.Location = Axis<T,U>.Location.primaryAxis)|Add a series to the plot with only the y-coordinates. The x-coordinates are automatically enumerated [1, 2, 3, ...]|
|addFunction(_ function: (Float)->Float, minX: Float, maxX: Float, numberOfSamples: Int = 400, label: String, color: Color = Color.lightBlue, axisType: Axis.Location = Axis.Location.primaryAxis)|Add a function to plot along with the range of x-coordinates over which to plot, number of samples of the function to take for plotting, a label, and color for the plot|
|drawGraphAndOutput(fileName name: String = "swift_plot_line_graph", renderer: Renderer)|Generate the plot and save the resultant image|
|drawGraph(renderer: Renderer)|Generate the plot in memory|
|drawGraphOutput(fileName name: String = "swift_plot_line_graph", renderer: Renderer)|Save the generated plot to disk|

### BarChart<T: LosslessStringConvertible, U: FloatConvertible>

|Function                                                                            |Description                                 |
|------------------------------------------------------------------------------------|--------------------------------------------|
|init(width: Float = 1000, height: Float = 660, enableGrid: Bool = true)                                      |Initialize a BarChart                      |
|addSeries(_ s: Series<T,U>)         |Add a series to the plot .                               |
|addStackSeries(_ s: Series<T,U>)         |Add a stacked series to the plot                    |
|addStackSeries(_ x: [U],   
                label: String,
                color: Color = .lightBlue,
                hatchPattern: BarGraphSeriesOptions.Hatching = .none)         |Add a stacked series to the plot|
|addSeries(values: [Pair<T,U>],
           label: String,
           color: Color = Color.lightBlue,
           hatchPattern: BarGraphSeriesOptions.Hatching = .none,
           graphOrientation: BarGraph.GraphOrientation = .vertical)         |Add a series to the plot using a Pair array|
|addSeries(_ x: [T],
           _ y: [U],
           label: String,
           color: Color = Color.lightBlue,
           hatchPattern: BarGraphSeriesOptions.Hatching = .none,
           graphOrientation: BarGraph.GraphOrientation = .vertical)         |Add a series to the plot using a Pair array|                          
|drawGraphAndOutput(fileName name: String = "swift_plot_bar_graph", renderer: Renderer)|Generate the plot and save the resultant image|
|drawGraph(renderer: Renderer)|Generate the plot in memory|
|drawGraphOutput(fileName name: String = "swift_plot_bar_graph", renderer: Renderer)|Save the generated plot to disk|

### SubPlot

|enum stackPattern (to be passed in place of stackPattern in the initializer)|
|----------------------------------------------------------------------------|
|verticallyStacked                                                           |
|horizontallyStacked                                                         |
|gridStacked                                                                 |

|Function                                                                            |Description                                 |
|------------------------------------------------------------------------------------|--------------------------------------------|
|init(width: Float = 1000, height: Float = 660, numberOfPlots n: Int = 1, numberOfRows nR: Int = 1, numberOfColumns nC: Int = 1, stackPattern: Int = 0)|Initialize a SubPlot |
|draw(plots: [Plot], renderer: Renderer, fileName: String = "subPlot_output")|Generate plot with the plots passed in as Sub Plots and save the image to disk|

### PlotDimensions

|Function                                                  |Description                                                    |
|----------------------------------------------------------|---------------------------------------------------------------|
|init(frameWidth : Float = 1000, frameHeight : Float = 660)|Create a PlotDimensions variable with a frame width and height |

### Pair<T,U>

|Property |
|---------|
|x: T     |
|y: U     |

|Function                    |Description                              |
|----------------------------|-----------------------------------------|
|init(_ x: T, _ y: T)        |Create a Pair using x and y              |


|typealias                   |
|----------------------------|
|Point = Pair<Float, Float>  |

|Property                          |
|----------------------------------|
|zeroPoint = Point(0.0, 0.0)       |

### PlotLabel

|Property                          |
|----------------------------------|
|xLabel: String = "X-Axis"         |
|yLabel: String = "Y-Axis"         |
|labelSize: Float = 15             |
|xLabelLocation = zeroPoint        |
|yLabelLocation = zeroPoint        |

### PlotTitle

|Property                 |
|-------------------------|
|title : String = "TITLE" |
|titleSize : Float = 15   |
|titleLocation = zeroPoint|

### Color

|Function                                            |Description                                                                |
|----------------------------------------------------|--------------------------------------------------------------------------|
|init(_ r: Float, _ g: Float, _ b: Float, _ a: Float)|Create a Color with r, g, b and a values. Each of them being between 0.0 and 1.0|

|Property(only on macOS and iOS)                    |
|---------------------------------------------------|
|cgColor: CGColor (return the corresponding CGColor)|


### PlotLabel

|Property                          |
|----------------------------------|
|xLabel: String = "X-Axis"         |
|yLabel: String = "Y-Axis"         |
|labelSize: Float = 15             |
|xLabelLocation = zeroPoint        |
|yLabelLocation = zeroPoint        |

### Axis<T,U>

|enum Location (to be passed into addSeries function in LineGraph)|
|-----------------------------------------------------------------|
|primaryAxis                                                      |
|secondaryAxis                                                    |

## Limitations
- FloatConvertible supports only Float and Double. We plan to extend this to Int in the future.
- The latest release doesn't work with Jupyter. This is because we use FreeType to draw text and the system isn't able to find the FreeType install when building in Jupyter.

## Credits
1. Maxim Shemanarev : The AGG library is directly used to render plots.
2. [Lode Vandevenne](https://github.com/lvandeve) : The lodepng library is directly used to encode PNG images.
3. [The FreeType Project](https://www.freetype.org) : AGG uses FreeType to draw text.
4. [Brad Larson](https://github.com/BradLarson) and [Marc Rasi](https://github.com/marcrasi) for their invaluable guidance
