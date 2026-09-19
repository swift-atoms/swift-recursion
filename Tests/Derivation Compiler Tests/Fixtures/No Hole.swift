import Zipper_Macro
@Zipper enum Invalid { case value(Int) }
let _ = Invalid.value(1).zipper
