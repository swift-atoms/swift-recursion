import Recursion_Macro_Core
import SwiftSyntax
import SwiftSyntaxMacros
import Type_Algebra_Syntax

public struct Macro: MemberAttributeMacro, MemberMacro {}

extension Macro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingAttributesFor member: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AttributeSyntax] {
        try Type.Syntax.Recursion.validateNamespace(declaration)
        if declaration.memberBlock.members.contains(where: { $0.decl.is(EnumCaseDeclSyntax.self) }) {
            throw MacroExpansionErrorMessage("@Recursion attaches prerequisites to nested enums; apply it to their namespace, not to the recursive enum itself.")
        }
        guard let enumeration = member.as(EnumDeclSyntax.self) else { return [] }
        let requested: [String]
        if case .argumentList(let arguments) = node.arguments, !arguments.isEmpty {
            requested = try arguments.map { argument in
                guard let selection = argument.expression.as(MemberAccessExprSyntax.self) else {
                    throw MacroExpansionErrorMessage("@Recursion expects scheme selections such as .catamorphism.")
                }
                let name = selection.declName.baseName.text
                return name.prefix(1).uppercased() + name.dropFirst()
            }
        } else {
            requested = ["Catamorphism", "Anamorphism", "Paramorphism", "Apomorphism", "Histomorphism", "Futumorphism", "Hylomorphism", "Zygomorphism", "Chronomorphism"]
        }
        let arguments = requested.map { String(reflecting: $0) }.joined(separator: ", ")
        return [AttributeSyntax(stringLiteral: "@_Recursion(\(arguments))")]
    }

    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let enumeration = declaration.as(EnumDeclSyntax.self) else {
            throw MacroExpansionErrorMessage("@_Recursion only applies to an enum.")
        }
        let requested: [String]
        if case .argumentList(let arguments) = node.arguments {
            requested = try arguments.map { argument in
                guard
                    let literal = argument.expression.as(StringLiteralExprSyntax.self),
                    literal.segments.count == 1,
                    let segment = literal.segments.first?.as(StringSegmentSyntax.self)
                else {
                    throw MacroExpansionErrorMessage("@_Recursion requires derivation names.")
                }
                return segment.content.text
            }
        } else {
            requested = []
        }
        let existing = Set(
            enumeration.attributes.compactMap {
                $0.as(AttributeSyntax.self)?.attributeName.trimmedDescription
            }
        )
        return try Derivation.members(
            requested: requested,
            existing: existing,
            of: enumeration
        )
    }
}
