// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NoiosoAI",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .executable(
            name: "NoiosoAI",
            targets: ["NoiosoAI"]
        ),
    ],
    dependencies: [
        // Add your dependencies here if any
    ],
    targets: [
        .executableTarget(
            name: "NoiosoAI",
            dependencies: []
        ),
    ]
)