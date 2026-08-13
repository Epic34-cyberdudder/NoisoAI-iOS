// swift-tools-version: 5.9
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
    targets: [
        .executableTarget(
            name: "NoiosoAI",
            dependencies: [],
            swiftSettings: [
                .define("SYNCHRONOUS_UI"),
            ]
        ),
    ]
)