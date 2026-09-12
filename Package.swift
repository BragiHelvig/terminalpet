// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "TerminalPet",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "TerminalPet", targets: ["TerminalPet"])
    ],
    targets: [
        .executableTarget(
            name: "TerminalPet",
            path: "Sources/TerminalPet"
        )
    ]
)
