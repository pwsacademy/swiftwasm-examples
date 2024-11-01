// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Import",
    targets: [
        .executableTarget(
            name: "Import",
            swiftSettings: [
                .enableExperimentalFeature("Extern")
            ]
        )
    ]
)
