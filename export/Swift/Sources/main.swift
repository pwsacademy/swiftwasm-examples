@_expose(wasm, "getNextDataPoint")
@_cdecl("getNextDataPoint")
func getNextDataPoint(after previous: Int) -> Int {
    let next = previous + Int.random(in: -10...10)
    return min(max(next, 0), 100)
}
