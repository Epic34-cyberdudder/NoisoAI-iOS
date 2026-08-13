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
        )
    ],
    targets: [
        .executableTarget(
            name: "NoiosoAI",
            path: "Sources",
            swiftSettings: [
                .unsafeFlags(["-parse-as-library"])
            ]
        )
    ]
)