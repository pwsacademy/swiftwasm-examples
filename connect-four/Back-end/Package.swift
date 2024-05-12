// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ConnectFourServer",
    platforms: [
       .macOS(.v13)
    ],
    dependencies: [
        .package(path: "../Shared"),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.83.1"),
    ],
    targets: [
        .executableTarget(
            name: "ConnectFourServer",
            dependencies: [
                .product(name: "ConnectFour", package: "Shared"),
                .product(name: "ConnectFourMultiplayer", package: "Shared"),
                .product(name: "Vapor", package: "vapor"),
            ]
        )
    ]
)
