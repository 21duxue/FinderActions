import Testing
@testable import FinderActionsCore

@Suite
struct MenuPresentationTests {
    @Test
    func submenuModeUsesParentTitle() {
        let settings = AppSettings()
        let presentation = MenuPresenter.presentation(for: settings)

        #expect(presentation?.parentTitle == "FinderActions")
        #expect(presentation?.items == [.newFile, .openTerminal, .copyPath, .copyName])
    }

    @Test
    func flatModeUsesNoParentTitle() {
        var settings = AppSettings()
        settings.menu.mode = .flat
        let presentation = MenuPresenter.presentation(for: settings)

        #expect(presentation?.parentTitle == nil)
        #expect(presentation?.items == [.newFile, .openTerminal, .copyPath, .copyName])
    }

    @Test
    func disabledActionsAreRemoved() {
        var settings = AppSettings()
        settings.menu.set(.copyName, enabled: false)
        let presentation = MenuPresenter.presentation(for: settings)

        #expect(presentation?.items == [.newFile, .openTerminal, .copyPath])
    }

    @Test
    func allActionsDisabledReturnsNil() {
        var settings = AppSettings()
        settings.menu.enabledItems = []
        #expect(MenuPresenter.presentation(for: settings) == nil)
    }
}
