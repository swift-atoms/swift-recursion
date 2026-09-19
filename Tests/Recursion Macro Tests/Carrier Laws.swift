import Recursion_Macro
import Testing
@Recursion
private enum Laws {
    indirect enum Tree: Equatable { case leaf(Int); case node(Tree, Tree) }
}
private typealias T = Laws.Tree
private func render(_ free: T.Free<Int>) -> String {
    free.fold(pure: { "p\($0)" }, suspend: { layer in
        switch layer { case .leaf(let n): "l\(n)"; case .node(let l, let r): "(\(l),\(r))" }
    })
}
private func render(_ cofree: T.Cofree<Int>) -> String {
    switch cofree {
    case .cofree(let label, let layer):
        switch layer {
        case .leaf(let n): return "\(label):l\(n)"
        case .node(let l, let r): return "\(label):(\(render(l)),\(render(r)))"
        }
    }
}
@Test func freeMonadUnitAssociativityAndInterpreterEquations() {
    let values: [T.Free<Int>] = [.pure(1), .suspend(.leaf(2)), .suspend(.node(.pure(3), .pure(4)))]
    let f: (Int) -> T.Free<Int> = { .suspend(.node(.pure($0), .pure(1))) }
    let g: (Int) -> T.Free<Int> = { .pure($0 * 2) }
    for value in values {
        #expect(render(value.flatMap { .pure($0) }) == render(value))
        #expect(render(value.flatMap(f).flatMap(g)) == render(value.flatMap { f($0).flatMap(g) }))
        #expect(render(value.map { $0 }) == render(value))
        #expect(render(value.map { $0 + 1 }.map { $0 * 2 }) == render(value.map { ($0 + 1) * 2 }))
        #expect(render(T.Free<T.Free<Int>>.pure(value).joined()) == render(value))
    }
    for n in [-1, 0, 2] { #expect(render(T.Free<Int>.pure(n).flatMap(f)) == render(f(n))) }
}
@Test func finiteCofreeCounitAndCoassociativity() {
    let value: T.Cofree<Int> = .cofree(3, .node(.cofree(1, .leaf(1)), .cofree(2, .leaf(2))))
    let f: (T.Cofree<Int>) -> Int = { $0.extract * 2 }
    let g: (T.Cofree<Int>) -> Int = { $0.extract + 1 }
    #expect(render(value.extend { $0.extract }) == render(value))
    #expect(value.extend(f).extract == f(value))
    #expect(render(value.extend(f).extend(g)) == render(value.extend { g($0.extend(f)) }))
    #expect(render(value.duplicate().extract) == render(value))
    #expect(render(value.map { $0 }) == render(value))
}
@Test func recursiveEquationsAndFusedChronoAgreeOnFiniteTrees() {
    let samples: [T] = [.leaf(1), .node(.leaf(2), .leaf(3)), .node(.node(.leaf(1), .leaf(2)), .leaf(3))]
    let algebra: (T.Base<Int>) -> Int = { layer in
        switch layer { case .leaf(let n): n; case .node(let l, let r): l + r }
    }
    for sample in samples {
        #expect(T.embed(sample.project()) == sample)
        #expect(sample.catamorphism(algebra) == algebra(sample.project().map { $0.catamorphism(algebra) }))
        #expect(T.embed(T.embed(sample.project()).project()) == sample)
    }
    let future: (Int) -> T.Base<T.Free<Int>> = { n in n == 0 ? .leaf(1) : .node(.pure(n - 1), .suspend(.leaf(2))) }
    let history: (T.Base<T.Cofree<Int>>) -> Int = { layer in
        switch layer { case .leaf(let n): n; case .node(let l, let r): l.extract + r.extract }
    }
    for seed in 0...4 {
        #expect(T.chronomorphism(seed, coalgebra: future, algebra: history) == T.futumorphism(seed, future).histomorphism(history))
        let coalgebra: (Int) -> T.Base<Int> = { $0 == 0 ? .leaf(1) : .node($0 - 1, 0) }
        #expect(T.hylomorphism(seed, coalgebra: coalgebra, algebra: algebra) == T.anamorphism(seed, coalgebra).catamorphism(algebra))
    }
}
