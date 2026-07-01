// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "sheet-the-agent",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "SheetCore", targets: ["SheetCore"])
    ],
    targets: [
        .target(name: "SheetCore"),
        .testTarget(name: "SheetCoreTests", dependencies: ["SheetCore"])
    ]
)
