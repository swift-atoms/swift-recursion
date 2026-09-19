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
        .library(name: "Zipper Macro", targets: ["Zipper Macro"]),
        .library(name: "Recursion Macro", targets: ["Recursion Macro"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-atoms/swift-finite.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-contravariant.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-foldable.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-algebra.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-futumorphism.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-histomorphism.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-cofree.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-free.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-corecursive.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-recursive.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-functor.git", branch: "main"),
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
        .testTarget(name: "Derivation Compiler Tests", dependencies: [
            "Zipper Macro",
            .product(name: "Functor Macro", package: "swift-functor"),
            .product(name: "Functor Base Macro", package: "swift-functor"),
            .product(name: "Invariant Macro", package: "swift-functor"),
            .product(name: "Traversable Macro", package: "swift-functor"),
            .product(name: "Representable Macro", package: "swift-functor"),
            .product(name: "Foldable Macro", package: "swift-foldable"),
            .product(name: "Contravariant Macro", package: "swift-contravariant"),
            .product(name: "Monoid Macro", package: "swift-algebra"),
            .product(name: "Finite Macro", package: "swift-finite"),
        ], resources: [.copy("Fixtures")]),
        .testTarget(name: "Zipper Macro Tests", dependencies: [
            "Zipper Macro",
        ]),
        .target(name: "Zipper Macro", dependencies: [
            "Zipper Macro Plugin",
        ]),
        .macro(name: "Zipper Macro Plugin", dependencies: [
            "Zipper Macro Core",
            .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            .product(name: "SwiftSyntax", package: "swift-syntax"),
        ]),
        .target(name: "Zipper Macro Core", dependencies: [
            .product(name: "SwiftSyntax", package: "swift-syntax"),
            .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
            .product(name: "Type Algebra Syntax", package: "swift-algebra"),
        ]),
        .target(name: "Recursion Macro Core", dependencies: [
            .product(name: "SwiftSyntax", package: "swift-syntax"),
        ]),
        .macro(name: "Recursion Macro Plugin", dependencies: [
            .product(name: "Type Algebra Syntax", package: "swift-algebra"),
            "Recursion Macro Core",
            .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            .product(name: "SwiftSyntax", package: "swift-syntax"),
            .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
        ]),
        .target(name: "Recursion Macro", dependencies: [
                .product(name: "Chronomorphism Macro", package: "swift-chronomorphism"),
                .product(name: "Zygomorphism Macro", package: "swift-zygomorphism"),
                .product(name: "Hylomorphism Macro", package: "swift-hylomorphism"),
                .product(name: "Futumorphism Macro", package: "swift-futumorphism"),
                .product(name: "Histomorphism Macro", package: "swift-histomorphism"),
                .product(name: "Apomorphism Macro", package: "swift-apomorphism"),
                .product(name: "Paramorphism Macro", package: "swift-paramorphism"),
                .product(name: "Anamorphism Macro", package: "swift-anamorphism"),
                .product(name: "Catamorphism Macro", package: "swift-catamorphism"),
                .product(name: "Cofree Macro", package: "swift-cofree"),
                .product(name: "Free Macro", package: "swift-free"),
                .product(name: "Corecursive Macro", package: "swift-corecursive"),
                .product(name: "Recursive Macro", package: "swift-recursive"),
                .product(name: "Functor Base Macro", package: "swift-functor"),
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

// Consumer compilation must reject visibility regressions, even when other packages suppress warnings.
for target in package.targets where target.type == .test || target.name.hasSuffix("Consumer Fixtures") {
    target.swiftSettings = (target.swiftSettings ?? []) + [.treatAllWarnings(as: .error)]
}
