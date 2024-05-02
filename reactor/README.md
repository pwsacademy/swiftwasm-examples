# A WebAssembly Reactor

This example shows how you can write a WebAssembly [**reactor**](https://github.com/WebAssembly/WASI/blob/main/legacy/application-abi.md) in Swift.

Unlike a command, a reactor doesn't shut down upon completion. You can call its exported functions as many times as needed. This makes it more akin to a library than to an executable.

This example uses a reactor to generate a random die roll and display the result on the page. The structure of this example is similar to the previous one, with the differences highlighted below.

## Swift

The code in **main.swift** first generates a random die roll:

```swift
let pips = Int.random(in: 1...6)
print("Rolled a \(pips)")
```

It then sets the `src` and `style` properties of the `<img>` element to display the result:

```swift
var img = JSObject.global.document.getElementById("die")
img.src = .string("\(pips).png")
img.style = "display: block"
```

Additional compiler options are required to compile this code as a reactor:

```
swift build \
  --triple wasm32-unknown-wasi \
  -Xswiftc -static-stdlib \
  -Xswiftc -Xclang-linker \
  -Xswiftc -mexec-model=reactor \
  -Xlinker --export=__main_argc_argv
```

`-Xclang-linker -mexec-model=reactor` tells the compiler to create a reactor (the default is a command). An explicit export is also required because reactors don't export a `main` function by default. WebAssembly uses [`__main_argc_argv`](https://github.com/WebAssembly/tool-conventions/blob/main/BasicCABI.md#user-entrypoint) as the symbol name for a `main` function — in this case, the top-level code in **main.swift** — so we export it using that name.

> **Note**: As in the previous example, the **swift** executable must come from a SwiftWasm toolchain. Either specify the path to this executable, or use **buildAndRun.sh** for convenience.

## WebAssembly

If you inspect **Reactor.wasm**, you'll notice a few new things:

```
wasmer inspect Reactor.wasm
```

Because this module depends on JavaScriptKit, it declares additional imports:

```
Imports:
  Functions:
    "javascript_kit"."swjs_i64_to_bigint_slow": [I32, I32, I32] -> [I32]
    "javascript_kit"."swjs_create_function": [I32, I32, I32] -> [I32]
    ...
```

JavaScriptKit combines a Swift library with a JavaScript runtime to provide interoperability between the two languages. The Swift library depends on functions provided by the JavaScript runtime, and it declares these functions as imports.

The JavaScript runtime also depends on functions provided by the Swift library. These are declared as exports:

```
Exports:
  Functions:
    ...
    "swjs_call_host_function": [I32, I32, I32, I32] -> [I32]
    "swjs_free_host_function": [I32] -> []
    ...
```

The two remaining exports are:

```
Exports:
  Functions:
    "_initialize": [] -> []
    "__main_argc_argv": [I32, I32] -> [I32]
    ...
```

The `_initialize` function is the entry point for reactors. Whereas the `_start` function of a command actually runs the command, `_initialize` only initializes a reactor. You must call this function first, before calling any other exports.

Finally, there's the explicitly exported `__main_argc_argv` function, which runs the top-level code in **main.swift**.

## JavaScript

A few extra steps are required to run this module from JavaScript.

In addition to the µWASI runtime, you also need a runtime for JavaScriptKit:

```js
const runtime = new WASI({
    features: [useAll()]
});
const jsKit = new SwiftRuntime();
```

When instantiating the module, the import object must also configure the imports required by JavaScriptKit:

```js
const { instance } = await WebAssembly.instantiateStreaming(
    fetch("Reactor.wasm"),
    {
        wasi_snapshot_preview1: runtime.wasiImport,
        javascript_kit: jsKit.wasmImports
    }
);
```

The µWASI runtime can now initialize the module:

```js
runtime.initialize(instance);
```

This checks for and calls the exported `_initialize` function.

The JavaScriptKit runtime also requires initialization:

```js
jsKit.setInstance(instance);
```

This must happen after calling the `_initialize` function, as it may call other exported functions.

The module is now fully initializated, so you can freely call its exports.

In this example, the button's `onclick` handler calls the exported `main` function to generate a die roll and update the page:

```js
document.getElementById("roll").onclick = () => {
    instance.exports.__main_argc_argv(0, 0);
};
```

You can run this example as before, either using `npm` or **buildAndRun.sh**.
