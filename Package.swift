// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "FinderActions",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "FinderActionsCore", targets: ["FinderActionsCore"]),
        .executable(name: "FinderActions", targets: ["FinderActions"]),
        .executable(name: "FinderActionsSmokeTests", targets: ["FinderActionsSmokeTests"]),
        .executable(name: "FinderActionsExtension", targets: ["FinderActionsExtension"])
    ],
    targets: [
        .target(name: "FinderActionsCore"),
        .executableTarget(name: "FinderActions", dependencies: ["FinderActionsCore"]),
        .executableTarget(
            name: "FinderActionsSmokeTests",
            dependencies: ["FinderActionsCore"]
        ),
        .executableTarget(
            name: "FinderActionsExtension",
            dependencies: ["FinderActionsCore"],
            swiftSettings: [
                .unsafeFlags(["-parse-as-library", "-application-extension"])
            ],
            linkerSettings: [
                .linkedFramework("FinderSync"),
                .unsafeFlags(["-Xlinker", "-e", "-Xlinker", "_NSExtensionMain"])
            ]
        ),
        .testTarget(name: "FinderActionsCoreTests", dependencies: ["FinderActionsCore"])
    ]
)
