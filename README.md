# Examples of Swift for WebAssembly

This repository contains a set of examples that show how you can use [SwiftWasm](https://swiftwasm.org) to compile Swift code to WebAssembly and run it in a browser.

## Essentials

These examples must be read in order, and before any others:

1. [The Basics](basics/README.md)
2. [A WebAssembly Command](command/README.md)
3. [A WebAssembly Reactor](reactor/README.md)
4. [Exporting Functions](export/README.md)
5. [Importing Functions](import/README.md)

## Extra

- [Connect Four](connect-four/README.md)

## Setting up your development environment

SwiftWasm can be tricky to work with as it involves using a different toolchain to compile for a different architecture. Therefore, it's important that you have a clear understanding of what you're doing, and that you properly configure your IDE. The following instructions focus on Visual Studio Code, but you can apply them to any IDE.

First, keep in mind that you may be using multiple toolchains:

1. You use a SwiftWasm toolchain to compile your code to WebAssembly. You'll install this toolchain during the [first example](basics/README.md).
2. Visual Studio Code uses your default Swift toolchain to resolve dependencies, build your code, highlight errors, suggest completions, and so on.

Second, understand that you are compiling for multiple architectures:

1. SwiftWasm compiles to the **wasm32** architecture.
2. Visual Studio Code compiles to your system's architecture.

To make your life easier, I suggest that you configure Visual Studio Code to use the SwiftWasm toolchain instead of the default Swift toolchain. This avoids any incompatibilities that may occur when mixing toolchains.

Open Visual Studio Code settings and navigate to **Extensions** ▸ **Swift** ▸ **Path**. Here, enter the path where Carton installed a SwiftWasm toolchain, followed by **/usr/bin**. If you followed along with the examples, this should be **~/Library/Developer/Toolchains/swift-wasm-6.0-SNAPSHOT-2024-04-19-a.xctoolchain/usr/bin**:

![Screenshot of the Swift:Path setting](path-setting.png)

You can now use the **Run Build Task...** command (**Command+Shift+B** on macOS) to run a build for your system's architecture.

## Useful links

- Swift:
    - [**SwiftWasm**](https://swiftwasm.org)
    - [**Carton**](https://github.com/swiftwasm/carton)
    - [**JavaScriptKit**](https://github.com/swiftwasm/JavaScriptKit)
- WebAssembly:
    - [**WebAssembly**](https://webassembly.org)
    - [**WASI**](https://wasi.dev)
    - [**Command vs. Reactor**](https://github.com/WebAssembly/WASI/blob/main/legacy/application-abi.md)
