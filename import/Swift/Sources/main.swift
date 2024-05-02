@_extern(wasm, module: "graph", name: "currentPoint")
@_extern(c)
func currentPoint() -> Int

@_extern(wasm, module: "graph", name: "plot")
@_extern(c)
func plot(_ point: Int)

@_expose(wasm, "plotNextDataPoint")
@_cdecl("plotNextDataPoint")
func plotNextDataPoint() {
    let next = currentPoint() + Int.random(in: -10...10)
    let clamped = min(max(next, 0), 100)
    plot(clamped)
}
