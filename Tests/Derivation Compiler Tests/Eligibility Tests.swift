import Foundation
import Testing

@Test(arguments: [
        ("Mixed Variance", "wrong variance position"),
        ("Unknown Fold", "unsupported type constructor"),
        ("Function Traversal", "finite polynomial positions"),
        ("Sum Monoid", "product monoids"),
        ("Metadata Representation", "homogeneous product"),
        ("Infinite Enumeration", "recursive types"),
        ("No Hole", "recursive position"),
        ("Nonuniform Recursion", "direct regular payloads"),
        ("Effectful Mapping", "unsupported type constructor")
])
func unsupportedDerivationsFailAtTheAlgebraBoundary(_ fixture: String, _ expected: String) throws {
    var products = Bundle.module.bundleURL
    while !FileManager.default.fileExists(atPath: products.appendingPathComponent("Functor_Macro.swiftmodule").path) {
        let parent = products.deletingLastPathComponent()
        products = try #require(parent != products ? parent : nil)
    }
    let source = Bundle.module.resourceURL!.appendingPathComponent("Fixtures/\(fixture).swift")
    let process = Process(), pipe = Pipe()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
    #if arch(arm64)
    let triple = "arm64-apple-macos27.0"
    #else
    let triple = "x86_64-apple-macos27.0"
    #endif
    process.arguments = ["swiftc", "-typecheck", "-swift-version", "6", "-target", triple,
        "-enable-upcoming-feature", "MemberImportVisibility", "-enable-upcoming-feature", "InternalImportsByDefault",
        "-warnings-as-errors", "-I", products.path, "-F", products.appendingPathComponent("PackageFrameworks").path]
    for name in ["Functor", "Functor Base", "Invariant", "Traversable", "Representable", "Foldable", "Contravariant", "Monoid", "Finite", "Zipper"] {
        let executable = products.appendingPathComponent("\(name) Macro Plugin").path
        let module = name.replacingOccurrences(of: " ", with: "_") + "_Macro_Plugin"
        process.arguments! += ["-Xfrontend", "-load-plugin-executable", "-Xfrontend", "\(executable)#\(module)"]
    }
    process.arguments!.append(source.path)
    process.standardError = pipe
    try process.run()
    let diagnostic = String(decoding: pipe.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
    process.waitUntilExit()
    #expect(process.terminationStatus != 0)
    #expect(!diagnostic.contains("no such module"), "Fixture could not load its workspace modules: \(diagnostic)")
    #expect(diagnostic.contains(expected), "Expected \(expected), got: \(diagnostic)")
}
