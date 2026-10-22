public import SwiftSyntax
import SwiftSyntaxBuilder
import Type_Algebra_Syntax

public enum Derivation {}

extension Derivation {
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

    public static func members(
        requested: [String],
        existing: Set<String>,
        of declaration: EnumDeclSyntax
    ) throws -> [DeclSyntax] {
        try Type.Syntax.Recursion.validate(declaration)
        var selected: Set<String> = []
        func include(_ name: String) {
            guard selected.insert(name).inserted else { return }
            for prerequisite in prerequisites[name, default: []] { include(prerequisite) }
        }
        for name in requested { include(name) }
        return try selected.subtracting(existing).sorted().flatMap { name in
            switch name {
            case "Anamorphism": anamorphism(of: declaration)
            case "Apomorphism": apomorphism(of: declaration)
            case "Catamorphism": catamorphism(of: declaration)
            case "Chronomorphism": chronomorphism(of: declaration)
            case "Cofree": try cofree(of: declaration)
            case "Corecursive": corecursive(of: declaration)
            case "Free": try free(of: declaration)
            case "FunctorBase": functorBase(of: declaration)
            case "Futumorphism": futumorphism(of: declaration)
            case "Histomorphism": histomorphism(of: declaration)
            case "Hylomorphism": hylomorphism(of: declaration)
            case "Paramorphism": paramorphism(of: declaration)
            case "Recursive": recursive(of: declaration)
            case "Zygomorphism": zygomorphism(of: declaration)
            default: []
            }
        }
    }
}

extension Derivation {
    private static func access(of declaration: EnumDeclSyntax) -> String {
        Type.Syntax.Recursion.access(of: declaration)
    }

    private static func anamorphism(of declaration: EnumDeclSyntax) -> [DeclSyntax] {
        [
            """
            \(raw: access(of: declaration))static func anamorphism<Seed>(
                _ seed: Seed,
                _ coalgebra: (Seed) -> Base<Seed>
            ) -> Self {
                embed(coalgebra(seed).map { anamorphism($0, coalgebra) })
            }
            """
        ]
    }

    private static func apomorphism(of declaration: EnumDeclSyntax) -> [DeclSyntax] {
        [
            """
            \(raw: access(of: declaration))static func apomorphism<Seed>(
                _ seed: Seed,
                _ coalgebra: (Seed) -> Base<Either<Self, Seed>>
            ) -> Self {
                embed(coalgebra(seed).map { branch in
                    switch branch {
                    case let .left(recursive): return recursive
                    case let .right(seed): return apomorphism(seed, coalgebra)
                    }
                })
            }
            """
        ]
    }

    private static func catamorphism(of declaration: EnumDeclSyntax) -> [DeclSyntax] {
        [
            """
            \(raw: access(of: declaration))func catamorphism<Result>(
                _ algebra: (Base<Result>) -> Result
            ) -> Result {
                algebra(project().map { $0.catamorphism(algebra) })
            }
            """
        ]
    }

    private static func chronomorphism(of declaration: EnumDeclSyntax) -> [DeclSyntax] {
        [
            """
            \(raw: access(of: declaration))static func chronomorphism<Seed, Result>(
                _ seed: Seed,
                coalgebra: (Seed) -> Base<Free<Seed>>,
                algebra: (Base<Cofree<Result>>) -> Result
            ) -> Result {
                func history(_ future: Free<Seed>) -> Cofree<Result> {
                    future.fold(
                        pure: { history(.suspend(coalgebra($0))) },
                        suspend: { layer in .cofree(algebra(layer), layer) }
                    )
                }
                return history(.pure(seed)).extract
            }
            """
        ]
    }

    private static func cofree(of declaration: EnumDeclSyntax) throws -> [DeclSyntax] {
        let variable = Type.Variable("Recursion")
        let layer = try Type.Syntax.Recursion.polynomial(of: declaration, variable: variable)
        let carrier = try Type.Recursion.cofree(
            layer: layer.expression,
            variable: variable,
            observing: .atom(.init("Value"))
        )
        let representation = Type.Syntax.Interpretation(
            atoms: [.init("Value"): TypeSyntax(stringLiteral: "Value")],
            representations: [layer.expression: TypeSyntax(stringLiteral: "Base<Cofree<Value>>")]
        )
        return [
            """
            \(raw: access(of: declaration))indirect enum Cofree<Value> {
                case cofree\(try representation.type(carrier.body))

                \(raw: access(of: declaration))var extract: Value {
                    switch self { case .cofree(let value, _): return value }
                }
                \(raw: access(of: declaration))func map<Mapped>(_ transform: (Value) -> Mapped) -> Cofree<Mapped> {
                    switch self {
                    case .cofree(let value, let layer): return .cofree(transform(value), layer.map { $0.map(transform) })
                    }
                }
                /// Finite eager extension; this does not promise productive infinite corecursion.
                \(raw: access(of: declaration))func extend<Mapped>(_ transform: (Cofree<Value>) -> Mapped) -> Cofree<Mapped> {
                    switch self {
                    case .cofree(_, let layer): return .cofree(transform(self), layer.map { $0.extend(transform) })
                    }
                }
                \(raw: access(of: declaration))func duplicate() -> Cofree<Cofree<Value>> { extend { $0 } }
            }
            """
        ]
    }

    private static func corecursive(of declaration: EnumDeclSyntax) -> [DeclSyntax] {
        let branches = Type.Syntax.Recursion.elements(of: declaration).map { element in
            let parameters = Type.Syntax.Recursion.parameters(of: element)
            guard !parameters.isEmpty else {
                return "case .\(element.name.text): return .\(element.name.text)"
            }
            return "case let .\(element.name.text)(\(Type.Syntax.Recursion.pattern(of: parameters))): return .\(element.name.text)(\(Type.Syntax.Recursion.arguments(of: parameters)))"
        }.joined(separator: "\n")
        return [
            """
            \(raw: access(of: declaration))static func embed(_ base: Base<Self>) -> Self {
                switch base {
                \(raw: branches)
                }
            }
            """
        ]
    }

    private static func free(of declaration: EnumDeclSyntax) throws -> [DeclSyntax] {
        let variable = Type.Variable("Recursion")
        let layer = try Type.Syntax.Recursion.polynomial(of: declaration, variable: variable)
        let carrier = try Type.Recursion.free(
            layer: layer.expression,
            variable: variable,
            returning: .atom(.init("Value"))
        )
        let representation = Type.Syntax.Interpretation(
            atoms: [.init("Value"): TypeSyntax(stringLiteral: "Value")],
            representations: [layer.expression: TypeSyntax(stringLiteral: "Base<Free<Value>>")]
        )
        guard case .sum(let alternatives) = carrier.body else {
            throw Type.Failure("free carrier requires a sum")
        }
        let cases = try zip(["pure", "suspend"], alternatives).map {
            "case \($0)(\(try representation.type($1)))"
        }.joined(separator: "\n")
        return [
            """
            \(raw: access(of: declaration))indirect enum Free<Value> {
                \(raw: cases)

                /// Substitution, the canonical bind of the free carrier.
                \(raw: access(of: declaration))func flatMap<Mapped>(_ transform: (Value) -> Free<Mapped>) -> Free<Mapped> {
                    switch self {
                    case .pure(let value): return transform(value)
                    case .suspend(let layer): return .suspend(layer.map { $0.flatMap(transform) })
                    }
                }
                \(raw: access(of: declaration))func map<Mapped>(_ transform: (Value) -> Mapped) -> Free<Mapped> {
                    flatMap { .pure(transform($0)) }
                }
                /// The unique finite fold for the supplied generator and layer interpretations.
                \(raw: access(of: declaration))func fold<Result>(pure: (Value) -> Result, suspend: (Base<Result>) -> Result) -> Result {
                    switch self {
                    case .pure(let value): return pure(value)
                    case .suspend(let layer): return suspend(layer.map { $0.fold(pure: pure, suspend: suspend) })
                    }
                }
                \(raw: access(of: declaration))func joined<Inner>() -> Free<Inner> where Value == Free<Inner> {
                    flatMap { $0 }
                }
            }
            """
        ]
    }

    private static func functorBase(of declaration: EnumDeclSyntax) -> [DeclSyntax] {
        let cases = Type.Syntax.Recursion.elements(of: declaration).map { element in
            let parameters = Type.Syntax.Recursion.parameters(of: element).map { parameter in
                let type = Type.Syntax.Recursion.isRecursive(parameter.type, in: declaration)
                    ? "Recursive"
                    : parameter.type.trimmedDescription
                guard let label = Type.Syntax.Recursion.label(of: parameter) else { return type }
                return "\(label): \(type)"
            }.joined(separator: ", ")
            return parameters.isEmpty
                ? "case \(element.name.text)"
                : "case \(element.name.text)(\(parameters))"
        }.joined(separator: "\n")
        return [
            """
            @Functor
            \(raw: access(of: declaration))enum Base<Recursive> {
                \(raw: cases)

            }
            """
        ]
    }

    private static func futumorphism(of declaration: EnumDeclSyntax) -> [DeclSyntax] {
        [
            """
            \(raw: access(of: declaration))static func futumorphism<Seed>(
                _ seed: Seed,
                _ coalgebra: (Seed) -> Base<Free<Seed>>
            ) -> Self {
                func realize(_ future: Free<Seed>) -> Self {
                    switch future {
                    case let .pure(seed): return futumorphism(seed, coalgebra)
                    case let .suspend(layer): return embed(layer.map(realize))
                    }
                }
                return embed(coalgebra(seed).map(realize))
            }
            """
        ]
    }

    private static func histomorphism(of declaration: EnumDeclSyntax) -> [DeclSyntax] {
        [
            """
            \(raw: access(of: declaration))func histomorphism<Result>(
                _ algebra: (Base<Cofree<Result>>) -> Result
            ) -> Result {
                func history(_ recursive: Self) -> Cofree<Result> {
                    let layer = recursive.project().map(history)
                    return .cofree(algebra(layer), layer)
                }
                switch history(self) {
                case let .cofree(result, _): return result
                }
            }
            """
        ]
    }

    private static func hylomorphism(of declaration: EnumDeclSyntax) -> [DeclSyntax] {
        [
            """
            \(raw: access(of: declaration))static func hylomorphism<Seed, Result>(
                _ seed: Seed,
                coalgebra: (Seed) -> Base<Seed>,
                algebra: (Base<Result>) -> Result
            ) -> Result {
                algebra(coalgebra(seed).map {
                    hylomorphism($0, coalgebra: coalgebra, algebra: algebra)
                })
            }
            """
        ]
    }

    private static func paramorphism(of declaration: EnumDeclSyntax) -> [DeclSyntax] {
        [
            """
            \(raw: access(of: declaration))func paramorphism<Result>(
                _ algebra: (Base<Product<Self, Result>>) -> Result
            ) -> Result {
                algebra(project().map { child in
                    Product(child, child.paramorphism(algebra))
                })
            }
            """
        ]
    }

    private static func recursive(of declaration: EnumDeclSyntax) -> [DeclSyntax] {
        let branches = Type.Syntax.Recursion.elements(of: declaration).map { element in
            let parameters = Type.Syntax.Recursion.parameters(of: element)
            guard !parameters.isEmpty else {
                return "case .\(element.name.text): return .\(element.name.text)"
            }
            return "case let .\(element.name.text)(\(Type.Syntax.Recursion.pattern(of: parameters))): return .\(element.name.text)(\(Type.Syntax.Recursion.arguments(of: parameters)))"
        }.joined(separator: "\n")
        return [
            """
            \(raw: access(of: declaration))func project() -> Base<Self> {
                switch self {
                \(raw: branches)
                }
            }
            """
        ]
    }

    private static func zygomorphism(of declaration: EnumDeclSyntax) -> [DeclSyntax] {
        [
            """
            \(raw: access(of: declaration))func zygomorphism<Auxiliary, Result>(
                auxiliary: (Base<Auxiliary>) -> Auxiliary,
                algebra: (Base<Product<Auxiliary, Result>>) -> Result
            ) -> Result {
                func fold(_ recursive: Self) -> Product<Auxiliary, Result> {
                    let children = recursive.project().map(fold)
                    return Product(
                        auxiliary(children.map { $0.values.0 }),
                        algebra(children)
                    )
                }
                return fold(self).values.1
            }
            """
        ]
    }
}
