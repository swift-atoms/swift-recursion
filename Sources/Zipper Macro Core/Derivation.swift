import Type_Algebra_Syntax
public import SwiftSyntax
import SwiftSyntaxBuilder

public enum Derivation {
    public static func members(of declaration: some DeclGroupSyntax) throws -> [DeclSyntax] {
        guard let enumeration = declaration.as(EnumDeclSyntax.self) else { throw Type.Failure("@Zipper requires a regular recursive enum") }
        try Type.Syntax.Recursion.validate(enumeration)
        guard enumeration.inheritanceClause?.inheritedTypes.contains(where: { $0.type.trimmedDescription == "~Copyable" || $0.type.trimmedDescription == "~Escapable" }) != true else {
            throw Type.Failure("@Zipper's persistent navigation requires Copyable, Escapable values; an owned zipper needs an explicit ownership design")
        }
        let type = enumeration.name.text
        let access = Type.Syntax.Recursion.access(of: enumeration)
        var contexts: [String] = []
        var descending: [String] = []
        var ascending: [String] = []
        let variable = Type.Variable("Recursion")
        let polynomial = try Type.Syntax.Recursion.polynomial(of: enumeration, variable: variable)
        let holes = try polynomial.contexts(for: variable)
        for (alternative, item) in Type.Syntax.Recursion.elements(of: enumeration).enumerated() {
            let parameters = Type.Syntax.Recursion.parameters(of: item)
            let recursive = holes.filter { $0.alternative == alternative }.map(\.position)
            if recursive.isEmpty { descending.append("case .\(item.name.text): return nil"); continue }
            let bindings = parameters.indices.map { "value\($0)" }
            let cases = recursive.enumerated().map { ordinal, hole -> String in
                let name = "\(item.name.text)_\(hole)"
                let others = parameters.indices.filter { $0 != hole }
                let payload = others.map { parameters[$0].type.trimmedDescription == "Self" ? type : parameters[$0].type.trimmedDescription }.joined(separator: ", ")
                contexts.append("case \(name)" + (others.isEmpty ? "" : "(\(payload))"))
                let pattern = others.isEmpty ? ".\(name)" : "let .\(name)(\(others.map { bindings[$0] }.joined(separator: ", ")))"
                let arguments = parameters.indices.map { index in
                    (Type.Syntax.Recursion.label(of: parameters[index]).map { "\($0): " } ?? "") + (index == hole ? "focus" : bindings[index])
                }.joined(separator: ", ")
                ascending.append("case \(pattern): parent.focus = .\(item.name.text)(\(arguments))")
                let context = ".\(name)" + (others.isEmpty ? "" : "(\(others.map { bindings[$0] }.joined(separator: ", ")))")
                return "case \(ordinal): child.contexts.append(\(context)); child.focus = \(bindings[hole])"
            }
            descending.append("""
                case let .\(item.name.text)(\(bindings.joined(separator: ", "))):
                    var child = self
                    switch index { \(cases.joined(separator: "\n"))
                    default: return nil
                    }
                    return child
                """)
        }
        guard !contexts.isEmpty else { throw Type.Failure("@Zipper requires at least one direct recursive position") }
        return [DeclSyntax(stringLiteral: """
            \(access)struct Zipper {
                \(access)private(set) var focus: \(type)
                private var contexts: [Context] = []
                private enum Context { \(contexts.joined(separator: "\n")) }
                \(access)init(_ focus: \(type)) { self.focus = focus }
                \(access)var depth: Int { contexts.count }
                /// Zero-based index among this constructor's recursive children.
                \(access)func down(_ index: Int) -> Self? {
                    switch focus { \(descending.joined(separator: "\n")) }
                }
                \(access)func replacing(_ value: \(type)) -> Self {
                    var result = self; result.focus = value; return result
                }
                \(access)func up() -> Self? {
                    var parent = self
                    guard let context = parent.contexts.popLast() else { return nil }
                    switch context { \(ascending.joined(separator: "\n")) }
                    return parent
                }
                \(access)func root() -> \(type) {
                    var cursor = self
                    while let parent = cursor.up() { cursor = parent }
                    return cursor.focus
                }
            }
            """), DeclSyntax(stringLiteral: "\(access)var zipper: Zipper { Zipper(self) }")]
    }
}
