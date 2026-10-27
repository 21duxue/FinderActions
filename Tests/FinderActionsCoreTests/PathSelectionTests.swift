import Testing
import Foundation
@testable import FinderActionsCore

@Suite
struct PathSelectionTests {
    @Test
    func selectedItemsTakePrecedenceOverTarget() {
        let target = URL(fileURLWithPath: "/Users/example/Project")
        let selected = [
            URL(fileURLWithPath: "/Users/example/Project/README.md"),
            URL(fileURLWithPath: "/Users/example/Project/Sources")
        ]
        let selection = PathSelection(target: target, selectedItems: selected)

        #expect(selection.effectiveItems == selected)
        #expect(selection.effectiveDirectory == URL(fileURLWithPath: "/Users/example/Project"))
    }

    @Test
    func targetIsUsedWhenNothingIsSelected() {
        let target = URL(fileURLWithPath: "/Users/example/Project")
        let selection = PathSelection(target: target, selectedItems: [])

        #expect(selection.effectiveItems == [target])
        #expect(selection.effectiveDirectory == target)
    }

    @Test
    func copiedTextUsesNewlinesForMultipleItems() {
        let selection = PathSelection(
            target: nil,
            selectedItems: [
                URL(fileURLWithPath: "/Users/example/One.md"),
                URL(fileURLWithPath: "/Users/example/Two.md")
            ]
        )

        #expect(CopiedText.paths(from: selection) == "/Users/example/One.md\n/Users/example/Two.md")
        #expect(CopiedText.names(from: selection) == "One.md\nTwo.md")
    }
}
