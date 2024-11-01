// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Reactor",
    dependencies: [
        .package(url: "https://github.com/swiftwasm/JavaScriptKit", from: "0.21.0")
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
