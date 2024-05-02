# Importing Functions

This example shows how you can import a JavaScript function and call it from Swift.

This example is functionally identical to the [previous one](../export/README.md), but implemented slightly different. Recall that the example runs a timer that, when fired, gets a new data point and plots it on a graph. 

## Swift

In **main.swift**, two JavaScript functions are imported into Swift. The first import gives access to the current data point:

```swift
@_extern(wasm, module: "graph", name: "currentPoint")
@_extern(c)
func currentPoint() -> Int
```

The annotation `@_extern(wasm, module: "graph", name: "currentPoint")` declares the function as an import and specifies its name, in this case `graph.currentPoint`. Meanwhile, `@_extern(c)` specifies that the C calling convention should be used.

Similar annotations are used to import the `plot` function:

```swift
@_extern(wasm, module: "graph", name: "plot")
@_extern(c)
func plot(_ point: Int)
```

With these imports in place, `getNextDataPoint(after:)` can be rewritten as follows:

```swift
@_expose(wasm, "plotNextDataPoint")
@_cdecl("plotNextDataPoint")
func plotNextDataPoint() {
    let next = currentPoint() + Int.random(in: -10...10)
    let clamped = min(max(next, 0), 100)
    plot(clamped)
}
```

Note that `@_extern` is an experimental feature, new to Swift 6.0, and requires an additional setting in **Package.swift**:

```swift
.executableTarget(
    name: "Import",
    swiftSettings: [
        .enableExperimentalFeature("Extern")
    ]
)
```

> **Note**: For more information about `@_extern`, see this [reference guide](https://github.com/apple/swift/blob/main/docs/ReferenceGuides/UnderscoredAttributes.md).

## WebAssembly

Inspect the module with **wasmer** to verify its imports:

```
Imports:
  Functions:
    "graph"."currentPoint": [] -> [I32]
    "graph"."plot": [I32] -> []
    "wasi_snapshot_preview1"."args_get": [I32, I32] -> [I32]
    "wasi_snapshot_preview1"."args_sizes_get": [I32, I32] -> [I32]
    ...
```

In addition to the WASI functions, this now also lists the two `graph` functions.

## JavaScript

These imported functions must be provided by the import object. Their module name (as specified by `@_extern`) should correspond with a property of the import object:

```js
{
    wasi_snapshot_preview1: runtime.wasiImport,
    graph: {
        currentPoint: () => graph.currentPoint,
        plot: (dataPoint) => graph.plot(dataPoint)
    }
}
```

The exported `plotNextDataPoint` function will call these imports to get the current data point and plot the next one:

```js
setInterval(() => {
    instance.exports.plotNextDataPoint();
}, 250);
```
