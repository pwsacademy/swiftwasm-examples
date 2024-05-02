# The Basics

This example shows how you can use [**Carton**](https://github.com/swiftwasm/carton) and [**JavaScriptKit**](https://github.com/swiftwasm/JavaScriptKit) to build a web app with Swift. This covers most of the basic use cases of Swift for WebAssembly ([**SwiftWasm**](https://swiftwasm.org)), while requiring very little knowledge of how WebAssembly works.

## Running the example

To run this example, simply execute the following command in the same directory as **Package.swift**:

```
swift run carton dev --custom-index-page Web/index.html
```

This should open your browser with a page that says "Hello from SwiftWasm!".

## About Carton

A lot of complexity is hidden behind the previous command. Here's what Carton does for you:

- It checks **.swift-version** and installs the required toolchain.
- It uses this toolchain to compile your code to a WebAssembly module.
- It generates the required JavaScript to load this module.
- It deploys the **index.html** page to a web server, along with the WebAssembly module and generated JavaScript.
- It watches your codes for changes and recompiles and redeploys it as needed.

Carton is a SwiftPM plugin. It doesn't require installation, you simply add it as a dependency to your package:

```swift
dependencies: [
    .package(url: "https://github.com/swiftwasm/carton", from: "1.0.0")
],
```

## About JavaScriptKit

JavaScriptKit is a library that lets your Swift code interact with JavaScript. This library provides types that can represent any JavaScript value, including objects and functions. The [global object](https://developer.mozilla.org/en-US/docs/Glossary/Global_object) is available as `JSObject.global`.

You can access this object's `document` property to interact with the DOM:

```swift
let document = JSObject.global.document
```

Here, JavaScriptKit relies on [dynamic member lookup](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/attributes/#dynamicMemberLookup) to expose the `document` property. This use of dynamic member lookup means that you can access any JavaScript property or method from Swift. Unfortunately, it also means that you don't get static typing or autocompletion, as every value is returned as a `JSValue`.

> **Note**: [WebAPIKit](https://github.com/swiftwasm/WebAPIKit) is an experimental library that provides type-safe access to the DOM and other Web APIs.

The remainder of the code in **main.swift** creates a new `<p>` element and appends it to the `<body>` element:

```swift
var p = document.createElement("p")
p.innerText = "Hello from SwiftWasm!"
_ = document.body.appendChild(p)
```

In this code, `createElement`, `innerText`, `body`, and `appendChild` are all accessed using dynamic member lookup.

## Deploying the example

To prepare a SwiftWasm project for release, use `carton bundle` instead of `carton dev`:

```
swift run carton bundle --custom-index-page Web/index.html
```

This will compile the project with a release configuration, run optimizations, and output the results to the **Bundle** directory. You can upload the files in this directory to any web server to deploy the project.
