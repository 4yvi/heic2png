// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "heic2png",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "heic2png", targets: ["heic2png"]),
        .executable(name: "HEIC2PNGApp", targets: ["HEIC2PNGApp"]),
    ],
    targets: [
        .target(name: "HEICConverterKit"),
        .executableTarget(name: "heic2png", dependencies: ["HEICConverterKit"]),
        .executableTarget(name: "HEIC2PNGApp", dependencies: ["HEICConverterKit"]),
        .testTarget(name: "HEICConverterKitTests", dependencies: ["HEICConverterKit"]),
    ]
)
