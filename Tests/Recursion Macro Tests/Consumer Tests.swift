import Either
import Product
import Recursion_Macro
import Testing

@Recursion
private enum Domain {
indirect enum Natural {
    case zero
    case successor(Natural)
}
}
private typealias Natural = Domain.Natural

@Test
func `recursion derives the complete scheme family coherently`() {
    let three = Natural.anamorphism(3) { seed -> Natural.Base<Int> in
        seed == 0 ? .zero : .successor(seed - 1)
    }
    let folded = three.catamorphism { (layer: Natural.Base<Int>) -> Int in
        switch layer {
        case .zero: 0
        case let .successor(child): child + 1
        }
    }
    let fused = Natural.hylomorphism(
        3,
        coalgebra: { seed -> Natural.Base<Int> in
            seed == 0 ? .zero : .successor(seed - 1)
        },
        algebra: { (layer: Natural.Base<Int>) -> Int in
            switch layer {
            case .zero: 0
            case let .successor(child): child + 1
            }
        }
    )

    #expect(folded == 3)
    #expect(fused == folded)
}

@Recursion(.catamorphism, .anamorphism, .histomorphism, .catamorphism)
private enum Selected {
    indirect enum Natural {
        case zero
        case successor(Natural)
    }
}
@Test func selectedSchemesShareOneBaseAndProjection() {
    let number = Selected.Natural.anamorphism(3) { $0 == 0 ? .zero : .successor($0 - 1) }
    #expect(number.catamorphism { layer in
        switch layer { case .zero: 0; case let .successor(n): n + 1 }
    } == 3)
    let _: Selected.Natural.Base<Int> = number.project().map { _ in 0 }
}
