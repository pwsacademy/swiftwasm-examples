import { WASI, useAll } from "uwasi";

const runtime = new WASI({
    args: ["firstArgument", "secondArgument"],
    env: {
        "SOME_KEY": "some_value"
    },
    features: [useAll()]
});

const { instance } = await WebAssembly.instantiateStreaming(
    fetch("Command.wasm"),
    {
        wasi_snapshot_preview1: runtime.wasiImport
    }
);
const exitCode = runtime.start(instance);
console.log(`Command exited with an exit code of ${exitCode}`);
