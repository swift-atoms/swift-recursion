import Either
import Product
import Recursion_Macro
import Testing

@Recursion
private indirect enum Natural {
    case zero
    case successor(Natural)
}

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
