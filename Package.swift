// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Apic",
    products: [
        .library(
            name: "Apic",
            targets: ["Apic"]),
        ],
    dependencies: [
        .package(url: "https://github.com/JuanjoArreola/AsyncRequest.git", from: "2.1.0")
    ],
    targets: [
        .target(
            name: "Apic",
            dependencies: ["AsyncRequest"],
            path: "Sources"
        ),
        .testTarget(
            name: "ApicTests",
            dependencies: ["Apic"],
            path: "Tests"
        )
    ]
)
