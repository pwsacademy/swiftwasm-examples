# Exporting Functions

This example shows how you can export a Swift function and call it from JavaScript.

The example runs a timer that, when fired, calls into a WebAssembly module to fetch a new data point. It then plots this data point on a scrolling graph. Use **buildAndRun.sh** to see this in action.

The structure of this example is similar to the previous ones, so only new aspects are highlighted below.

## Swift

The [previous example](../reactor/README.md) showed how to export a `main` function. Exporting other functions is straightforward, but requires a few new annotations:

```swift
@_expose(wasm, "getNextDataPoint")
@_cdecl("getNextDataPoint")
func getNextDataPoint(after previous: Int) -> Int {
    let next = previous + Int.random(in: -10...10)
    return min(max(next, 0), 100)
}
```

Here, `@_expose` adds this function as an export to the WebAssembly module. Meanwhile, `@_cdecl` specifies that the C calling convention should be used, which is different from Swift's calling convention.

As an added benefit, no additional compiler options are needed when using `@_expose`. This makes **buildAndRun.sh** less complex than in the previous example, which required options ` -Xlinker --export=__main_argc_argv` to export the code in **main.swift**.

> **Note**: For more information about `@_expose` and `@_cdecl`, see this [reference guide](https://github.com/apple/swift/blob/main/docs/ReferenceGuides/UnderscoredAttributes.md).

## WebAssembly

Inspect the module with **wasmer** to verify its exports:

```
Exports:
  Functions:
    "_initialize": [] -> []
    "getNextDataPoint": [I32] -> [I32]
```

This lists `getNextDataPoint`, along with the reactor's `_initialize` function.

## JavaScript

Exporting a function makes it available in JavaScript through the instance's `exports` property:

```js
instance.exports.getNextDataPoint(previousDataPoint)
```

In the example, this is used in the timer's callback function, which gets a new data point and updates the graph:

```js
setInterval(() => {
    const nextPoint = instance.exports.getNextDataPoint(graph.currentPoint);
    graph.plot(nextPoint);
}, 250);
```
