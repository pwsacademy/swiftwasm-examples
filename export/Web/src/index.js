import { WASI, useAll } from "uwasi";
import Graph from "./Graph.js";

const runtime = new WASI({
    features: [useAll()]
});
const { instance } = await WebAssembly.instantiateStreaming(
    fetch("Export.wasm"),
    {
        wasi_snapshot_preview1: runtime.wasiImport
    }
);
runtime.initialize(instance);

const canvas = document.querySelector("canvas");
const graph = new Graph(100, 50, canvas);

setInterval(() => {
    const nextPoint = instance.exports.getNextDataPoint(graph.currentPoint);
    graph.plot(nextPoint);
}, 250);
