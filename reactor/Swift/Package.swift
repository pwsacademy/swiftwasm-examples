// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Reactor",
    dependencies: [
        .package(url: "https://github.com/swiftwasm/JavaScriptKit", from: "0.19.0")
    ],
    targets: [
        .executableTarget(
            name: "Reactor",
            dependencies: [
                .product(name: "JavaScriptKit", package: "JavaScriptKit")
            ]
        )
    ]
)
