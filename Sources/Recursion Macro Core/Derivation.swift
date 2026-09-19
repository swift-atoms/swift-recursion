public import SwiftSyntax

public enum Derivation {
    private static let prerequisites: [String: [String]] = [
        "FunctorBase": [],
        "Recursive": ["FunctorBase"],
        "Corecursive": ["FunctorBase"],
        "Free": ["FunctorBase"],
        "Cofree": ["FunctorBase"],
        "Catamorphism": ["Recursive"],
        "Anamorphism": ["Corecursive"],
        "Paramorphism": ["Recursive"],
        "Apomorphism": ["Corecursive"],
        "Histomorphism": ["Recursive", "Cofree"],
        "Futumorphism": ["Corecursive", "Free"],
        "Hylomorphism": ["FunctorBase"],
        "Zygomorphism": ["Recursive"],
        "Chronomorphism": ["Free", "Cofree"],
    ]

    public static func attributes(requested: [String], existing: Set<String>) -> [AttributeSyntax] {
        var selected: Set<String> = []
        func include(_ name: String) {
            guard selected.insert(name).inserted else { return }
            for prerequisite in prerequisites[name, default: []] { include(prerequisite) }
        }
        for name in requested { include(name) }
        return selected.subtracting(existing).sorted().map {
            AttributeSyntax(attributeName: IdentifierTypeSyntax(name: .identifier($0)))
        }
    }
}
