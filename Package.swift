import PackageDescription

let package = Package(
    name: "Apic",
    dependencies: [
        .Package(url: "https://github.com/JuanjoArreola/AsyncRequest.git", majorVersion: 1)
    ]
)
