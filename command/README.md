# A WebAssembly Command

This example shows how you can write a WebAssembly [**command**](https://github.com/WebAssembly/WASI/blob/main/legacy/application-abi.md) in Swift.

WebAssembly commands are similar to executables: they read input from **stdin**, write output to **stdout**, and shut down upon completion. They aren't what you'd use in most cases, but they provide an easy way to get started with WebAssembly.

The goal for this example is to explain a bit more about how WebAssembly works. That's why this example doesn't rely on Carton, but shows how you can manually compile a Swift package to WebAssembly, and run it from JavaScript.

## Prerequisites

Other than a SwiftWasm toolchain (which Carton should have installed for you during the previous example), this example requires the following software:

- [**wasmer**](https://wasmer.io)
- [**npm**](https://www.npmjs.com)

On macOS, you can install these using [Homebrew](https://brew.sh):

```
brew install wasmer node
```

## Swift

The code in **main.swift** implements a simple command that prints its arguments and environment values:

```swift
print("The command was executed with the following arguments:")
print(ProcessInfo.processInfo.arguments.joined(separator: " "))

if ProcessInfo.processInfo.environment.count > 0 {
    print("and environment variables:")
    for (key, value) in ProcessInfo.processInfo.environment {
        print("\(key): \(value)")
    }
} else {
    print("and no environment variables.")
}
```

There is nothing specific to WebAssembly about this code.

To compile it, run the following command in the **Swift** directory:

```
swift build --triple wasm32-unknown-wasi -Xswiftc -static-stdlib
```

The **swift** executable in this command must come from a SwiftWasm toolchain. Carton should have installed one in **~/Library/Developer/Toolchains** during the previous example.

On my machine, the full version of the previous command is:

```
~/Library/Developer/Toolchains/swift-wasm-6.0-SNAPSHOT-2024-04-19-a.xctoolchain/usr/bin/swift build --triple wasm32-unknown-wasi -Xswiftc -static-stdlib
```

The output of this command is a WebAssembly module named **Command.wasm** in the **.build/wasm32-unknown-wasi/debug** directory.

## WebAssembly

To run a WebAssembly module, you need a runtime. This doesn't have to be a web browser. WebAssembly can run anywhere a runtime is available: in a browser, on the command line, on the server, or even embedded within other apps.

Earlier, you installed the **wasmer** runtime. Navigate to the directory that contains **Command.wasm** and run it as follows:

```
wasmer Command.wasm
```

This should print:

```
The command was executed with the following arguments:
Command.wasm
and no environment variables.
```

Next, use **wasmer** to peek inside the module:

```
wasmer inspect Command.wasm
```

Notice the following sections in the output:

```
Imports:
  Functions:
    "wasi_snapshot_preview1"."args_get": [I32, I32] -> [I32]
    "wasi_snapshot_preview1"."args_sizes_get": [I32, I32] -> [I32]
    ...
Exports:
  Functions:
    "_start": [] -> []
```

Modules interact with their environment by importing and exporting functions. Modules can even interact with other modules by connecting one module's exports to another module's imports.

In this case, **Command.wasm** declares a number of imported functions with the `wasi_snapshot_preview1` prefix. These functions are part of the [WebAssembly System Interface](https://wasi.dev) (**WASI**) and must be provided by the runtime.

The module also declares a single exported `_start` function, which contains the top-level code from **main.swift**. The `_start` function  is the entry point for WebAssembly commands. You call this function from JavaScript to run the command.

## JavaScript

The **Web** directory contains an NPM package that shows how you can run **Command.wasm** from JavaScript. As always, this requires a runtime. This example uses [**µWASI**](https://github.com/swiftwasm/uwasi), a small WASI runtime developed by SwiftWasm.

µWASI is declared as a dependency in **package.json**. Before you can build the package, you need to install its dependencies by running the following command in the **Web** directory:

```
npm install
```

The source code for the package is in **index.js**. This code creates a runtime, instantiates the module, and runs it.

You create a runtime as follows:

```js
const runtime = new WASI({
    args: ["firstArgument", "secondArgument"],
    env: {
        "SOME_KEY": "some_value"
    },
    features: [useAll()]
});
```

The `args` and `env` properties configure the arguments and environment variables that the runtime will pass to the module.

The `features` property specifies which WASI features the runtime should support. µWASI is a modular runtime, so you can be specific about which features you want to support. In this case, we just support them all.

The next step is to instantiate the module:

```js
const { instance } = await WebAssembly.instantiateStreaming(
    fetch("Command.wasm"),
    {
        wasi_snapshot_preview1: runtime.wasiImport
    }
);
```

The second parameter of `instantiateStreaming` is an **import object**. This object provides the functions that the module declares as imports. In this case, the import object has a `wasi_snapshot_preview1` property that contains all of the WASI functions provided by the runtime.

Now that we have a runtime and an instance, we can run it as follows:

```js
const exitCode = runtime.start(instance);
```

The runtime's `start` function checks for and calls the module's exported `_start` function.

To try this out, first build the package as follows:

```
npm run build
```

This uses [**webpack**](https://webpack.js.org) to bundle the code in **index.js** with the µWASI runtime, and outputs the result to **main.js** in the **dist** directory. JavaScript will look for **Command.wasm** in the same directory, so you need to copy it over.

Next, run the package as follows:

```
npm run start
```

This starts a web server and deploys the example to it. Your browser should open automatically.

To improve your development experience, webpack will watch the files in **public** and **dist** for changes and redeploy them as needed.

## Build and run

**buildAndRun.sh** contains a Bash script that gathers all of the commands required to build and run this example. Edit the value of the `TOOLCHAIN` variable, then run the script as follows:

```
./buildAndRun.sh
```
