import Testing
@testable import FinderActionsCore

@Suite
struct MenuConfigurationTests {
    @Test
    func defaultsEnableAllActions() {
        let configuration = MenuConfiguration()
        #expect(configuration.enabledItems == Set(MenuItemID.allCases))
        #expect(configuration.mode == .submenu)
    }

    @Test
    func togglingActions() {
        var configuration = MenuConfiguration()
        configuration.set(.copyName, enabled: false)
        #expect(!configuration.isEnabled(.copyName))
        configuration.set(.copyName, enabled: true)
        #expect(configuration.isEnabled(.copyName))
    }

    @Test
    func sortedItemsFollowDeclarationOrder() {
        var configuration = MenuConfiguration()
        configuration.set(.openTerminal, enabled: false)
        #expect(configuration.sortedItems == [.newFile, .copyPath, .copyName])
    }
}
