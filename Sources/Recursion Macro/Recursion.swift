import Either
import Product

@attached(member, names: arbitrary)
public macro Recursion() = #externalMacro(
    module: "Recursion_Macro_Plugin",
    type: "Macro"
)
