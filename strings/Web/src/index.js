import { WASI, useAll } from "uwasi";
import Heap from "./heap.js";

const wasi = new WASI({
    features: [useAll()]
});

let heap = new Heap();

const { instance } = await WebAssembly.instantiateStreaming(
    fetch("Strings.wasm"),
    {
        runtime: {
            storeStringData: (pointer, count) => {
                const memory = new Uint8Array(instance.exports.memory.buffer);
                const data = memory.slice(pointer, pointer + count);
                return heap.store(data);
            },
            loadStringData: (reference, target) => {
                const memory = new Uint8Array(instance.exports.memory.buffer);
                const data = heap.get(reference);
                memory.set(data, target);
            },
        },
        wasi_snapshot_preview1: wasi.wasiImport
    }
)
wasi.initialize(instance);

const reference = instance.exports.getCurrentUser();
const data = heap.get(reference);
const string = new TextDecoder().decode(data);
const user = JSON.parse(string);
console.log(`Current user is ${user.name} with ID ${user.id}`);

const newUser = {
    id: 2,
    name: "Jennefer"
};
const newString = JSON.stringify(newUser);
const newData = new TextEncoder().encode(newString);
const newReference = heap.store(newData);
instance.exports.addNewUser(newReference, newData.length);
