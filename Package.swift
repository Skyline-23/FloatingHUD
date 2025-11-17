// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "FloatingHUD",
    platforms: [
        .iOS(.v17), .macOS(.v14)
    ],
    products: [
        .library(name: "FloatingHUD", targets: ["FloatingHUD"])
    ],
    targets: [
        .target(name: "FloatingHUD", dependencies: [])
    ]
)
