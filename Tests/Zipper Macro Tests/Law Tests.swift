import Zipper_Macro
import Testing
@Zipper private indirect enum Tree<A> {
    case leaf(A)
    case branch(label: String, left: Tree<A>, right: Tree<A>)
}
extension Tree: Equatable where A: Equatable {}
@Test func zipperNavigationAndReplacementPreserveTheComplement() throws {
    let tree = Tree.branch(label: "root", left: .leaf(1), right: .branch(label: "right", left: .leaf(2), right: .leaf(3)))
    let root = tree.zipper
    #expect(root.up() == nil)
    #expect(root.down(-1) == nil)
    #expect(root.down(2) == nil)
    let left = try #require(root.down(0))
    #expect(left.depth == 1)
    #expect(left.root() == tree)
    #expect(left.up()?.focus == tree)
    #expect(left.replacing(left.focus).root() == tree)
    #expect(left.focus.zipper.down(0) == nil)
    let deep = try #require(root.down(1)?.down(0))
    #expect(deep.depth == 2)
    let changed = deep.replacing(.leaf(42)).root()
    #expect(changed == .branch(label: "root", left: .leaf(1), right: .branch(label: "right", left: .leaf(42), right: .leaf(3))))
    #expect(root.root() == tree)
}
