/// One-hole contexts for direct regular recursive enums. The original enum remains the only tree representation.
@attached(member, names: named(Zipper), named(zipper))
public macro Zipper() = #externalMacro(module: "Zipper_Macro_Plugin", type: "Derive")
