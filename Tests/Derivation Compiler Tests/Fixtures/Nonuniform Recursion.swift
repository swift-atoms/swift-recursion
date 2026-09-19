import Functor_Base_Macro
@FunctorBase indirect enum Invalid<A> { case value(A); case successor(Invalid<Int>) }
