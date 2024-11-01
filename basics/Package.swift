// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Basics",
    dependencies: [
        .package(url: "https://github.com/swiftwasm/carton", from: "1.1.0"),
        .package(url: "https://github.com/swiftwasm/JavaScriptKit", from: "0.21.0")
    ],
    targets: [
        .executableTarget(
            name: "HelloSwiftWasm",
            dependencies: [
                .product(name: "JavaScriptKit", package: "JavaScriptKit")
            ]
        )
    ]
)
