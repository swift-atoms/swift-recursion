// swift-tools-version: 6.4
import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "swift-recursion",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(name: "Recursion Macro", targets: ["Recursion Macro"]),
        .library(name: "Recursion Macro Core", targets: ["Recursion Macro Core"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-atoms/swift-either.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-product.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-anamorphism.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-apomorphism.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-catamorphism.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-chronomorphism.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-hylomorphism.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-paramorphism.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-zygomorphism.git", branch: "main"),
        .package(url: "https://github.com/swiftlang/swift-syntax.git", "603.0.2"..<"604.0.0"),
    ],
    targets: [
        .target(name: "Recursion Macro Core", dependencies: [
            .product(name: "Anamorphism Macro Core", package: "swift-anamorphism"),
            .product(name: "Apomorphism Macro Core", package: "swift-apomorphism"),
            .product(name: "Catamorphism Macro Core", package: "swift-catamorphism"),
            .product(name: "Chronomorphism Macro Core", package: "swift-chronomorphism"),
            .product(name: "Hylomorphism Macro Core", package: "swift-hylomorphism"),
            .product(name: "Paramorphism Macro Core", package: "swift-paramorphism"),
            .product(name: "Zygomorphism Macro Core", package: "swift-zygomorphism"),
            .product(name: "SwiftSyntax", package: "swift-syntax"),
        ]),
        .macro(name: "Recursion Macro Plugin", dependencies: [
            "Recursion Macro Core",
            .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            .product(name: "SwiftSyntax", package: "swift-syntax"),
            .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
        ]),
        .target(name: "Recursion Macro", dependencies: [
            "Recursion Macro Plugin",
            .product(name: "Either", package: "swift-either"),
            .product(name: "Product", package: "swift-product"),
        ]),
        .testTarget(name: "Recursion Macro Tests", dependencies: [
            "Recursion Macro",
            .product(name: "Either", package: "swift-either"),
            .product(name: "Product", package: "swift-product"),
        ]),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]
    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
