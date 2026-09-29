@_exported import Functor_Base_Macro
@_exported import Recursive_Macro
@_exported import Corecursive_Macro
@_exported import Free_Macro
@_exported import Cofree_Macro
@_exported import Catamorphism_Macro
@_exported import Anamorphism_Macro
@_exported import Paramorphism_Macro
@_exported import Apomorphism_Macro
@_exported import Histomorphism_Macro
@_exported import Futumorphism_Macro
@_exported import Hylomorphism_Macro
@_exported import Zygomorphism_Macro
@_exported import Chronomorphism_Macro
@_exported import Either
@_exported import Product

public enum RecursionScheme {
    case recursive, corecursive, free, cofree
    case catamorphism, anamorphism, paramorphism, apomorphism
    case histomorphism, futumorphism, hylomorphism, zygomorphism, chronomorphism
}

@attached(memberAttribute)
public macro Recursion(_ schemes: RecursionScheme...) = #externalMacro(
    module: "Recursion_Macro_Plugin", type: "Macro"
)
