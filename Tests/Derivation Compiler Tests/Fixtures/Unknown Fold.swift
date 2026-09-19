import Foldable_Macro
struct Unknown<A> { let value: A }
@Foldable struct Invalid<A> { let value: Unknown<A> }
