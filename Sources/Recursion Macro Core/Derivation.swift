import Anamorphism_Macro_Core
import Apomorphism_Macro_Core
import Catamorphism_Macro_Core
import Chronomorphism_Macro_Core
import Hylomorphism_Macro_Core
import Paramorphism_Macro_Core
public import SwiftSyntax
import Zygomorphism_Macro_Core

public enum Derivation {
    public static func expansion(of declaration: EnumDeclSyntax) -> [DeclSyntax] {
        var declarations = Chronomorphism_Macro_Core.Derivation.expansion(of: declaration)
        declarations += Catamorphism_Macro_Core.Derivation.operation(of: declaration)
        declarations += Anamorphism_Macro_Core.Derivation.operation(of: declaration)
        declarations += Paramorphism_Macro_Core.Derivation.operation(of: declaration)
        declarations += Apomorphism_Macro_Core.Derivation.operation(of: declaration)
        declarations += Zygomorphism_Macro_Core.Derivation.operation(of: declaration)
        declarations += Hylomorphism_Macro_Core.Derivation.operation(of: declaration)
        return declarations
    }
}
