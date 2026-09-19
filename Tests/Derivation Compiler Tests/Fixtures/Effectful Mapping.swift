import Functor_Macro
@Functor struct Invalid<A> { let run: () async -> A }
