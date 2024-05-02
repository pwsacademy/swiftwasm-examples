import { WASI, useAll } from "uwasi";
import { SwiftRuntime } from "javascript-kit-swift";

const runtime = new WASI({
    features: [useAll()]
});
const jsKit = new SwiftRuntime();

const { instance } = await WebAssembly.instantiateStreaming(
    fetch("Reactor.wasm"),
    {
        wasi_snapshot_preview1: runtime.wasiImport,
        javascript_kit: jsKit.wasmImports
    }
);
runtime.initialize(instance);
jsKit.setInstance(instance);

document.getElementById("roll").onclick = () => {
    instance.exports.__main_argc_argv(0, 0);
};
