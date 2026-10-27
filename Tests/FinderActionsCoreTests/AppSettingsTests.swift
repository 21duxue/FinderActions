import Testing
@testable import FinderActionsCore

@Suite
struct AppSettingsTests {
    @Test
    func defaults() {
        let settings = AppSettings()
        #expect(settings.language == .chinese)
        #expect(settings.defaultFileName == "Untitled.txt")
        #expect(settings.menu.mode == .submenu)
    }
}
