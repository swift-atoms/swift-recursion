import Monoid_Macro
@Monoid enum Invalid { case a; case b }
let _ = Invalid.monoid
