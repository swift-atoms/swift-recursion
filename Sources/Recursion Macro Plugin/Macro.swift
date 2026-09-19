import Type_Algebra_Syntax
import Recursion_Macro_Core
import SwiftSyntax
import SwiftSyntaxMacros

public struct Macro: MemberAttributeMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingAttributesFor member: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AttributeSyntax] {
        try RecursiveShape.validateNamespace(declaration)
        if declaration.memberBlock.members.contains(where: { $0.decl.is(EnumCaseDeclSyntax.self) }) {
            throw MacroExpansionErrorMessage("@Recursion attaches prerequisites to nested enums; apply it to their namespace, not to the recursive enum itself.")
        }
        guard let enumeration = member.as(EnumDeclSyntax.self) else { return [] }
        let requested: [String]
        if case let .argumentList(arguments) = node.arguments, !arguments.isEmpty {
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
        let existing = Set(enumeration.attributes.compactMap { $0.as(AttributeSyntax.self)?.attributeName.trimmedDescription })
        return Derivation.attributes(requested: requested, existing: existing)
    }
}
