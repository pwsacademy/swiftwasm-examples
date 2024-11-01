// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ConnectFourWeb",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(path: "../Shared"),
        .package(url: "https://github.com/swiftwasm/carton.git", from: "1.1.0"),
        .package(url: "https://github.com/swiftwasm/JavaScriptKit.git", from: "0.21.0"),
        .package(url: "https://github.com/swiftwasm/WebAPIKit.git", from: "0.1.0")
    ],
    targets: [
        .executableTarget(
            name: "ConnectFourWeb",
            dependencies: [
                .product(name: "ConnectFour", package: "Shared"),
                .product(name: "ConnectFourMultiplayer", package: "Shared"),
                .product(name: "JavaScriptKit", package: "JavaScriptKit"),
                .product(name: "WebSockets", package: "WebAPIKit"),
            ],
            exclude: [
                "play.html"
            ],
            resources: [
                .process("play.css")
            ]
        )
    ]
)
