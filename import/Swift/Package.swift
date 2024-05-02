// swift-tools-version: 5.9
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
