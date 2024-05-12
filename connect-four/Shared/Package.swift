// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ConnectFourShared",
    platforms: [
       .macOS(.v13)
    ],
    products: [
        .library(name: "ConnectFour", targets: ["ConnectFour"]),
        .library(name: "ConnectFourMultiplayer", targets: ["ConnectFourMultiplayer"])
    ],
    dependencies: [],
    targets: [
        .target(name: "ConnectFour"),
        .target(
            name: "ConnectFourMultiplayer",
            dependencies: ["ConnectFour"]
        )
    ]
)
