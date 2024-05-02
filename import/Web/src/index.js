import { WASI, useAll } from "uwasi";
import Graph from "./Graph.js";

const canvas = document.querySelector("canvas");
const graph = new Graph(100, 50, canvas);

const runtime = new WASI({
    features: [useAll()]
});
const { instance } = await WebAssembly.instantiateStreaming(
    fetch("Import.wasm"),
    {
        wasi_snapshot_preview1: runtime.wasiImport,
        graph: {
            currentPoint: () => graph.currentPoint,
            plot: (dataPoint) => graph.plot(dataPoint)
        }
    }
);
runtime.initialize(instance);

setInterval(() => {
    instance.exports.plotNextDataPoint();
}, 250);
