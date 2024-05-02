// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Basics",
    dependencies: [
        .package(url: "https://github.com/swiftwasm/carton", from: "1.0.0"),
        .package(url: "https://github.com/swiftwasm/JavaScriptKit", from: "0.19.0")
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
