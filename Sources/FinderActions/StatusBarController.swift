import AppKit
import FinderActionsCore

@MainActor
final class StatusBarController: NSObject, NSMenuDelegate {
    private let statusItem: NSStatusItem
    private let menu = NSMenu()
    private let loginItem: LoginItemController
    private let openSettings: () -> Void

    init(loginItem: LoginItemController, openSettings: @escaping () -> Void) {
        self.loginItem = loginItem
        self.openSettings = openSettings
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        super.init()

        if let button = statusItem.button {
            let image = NSImage(systemSymbolName: "folder.badge.plus", accessibilityDescription: "FinderActions")
            image?.isTemplate = true
            button.image = image
            button.toolTip = "FinderActions"
        }

        menu.delegate = self
        statusItem.menu = menu
        rebuildMenu()
    }

    func menuNeedsUpdate(_ menu: NSMenu) {
        rebuildMenu()
    }

    private func rebuildMenu() {
        menu.removeAllItems()

        let language = SettingsStore().load().language
        let openSettingsTitle = language == .chinese ? "打开设置" : "Open Settings"
        let loginTitle = language == .chinese ? "登录时启动" : "Launch at Login"
        let quitTitle = language == .chinese ? "退出 FinderActions" : "Quit FinderActions"

        let settingsItem = NSMenuItem(title: openSettingsTitle, action: #selector(openSettingsItem), keyEquivalent: "")
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(.separator())

        let loginItem = NSMenuItem(title: loginTitle, action: #selector(toggleLoginItem), keyEquivalent: "")
        loginItem.target = self
        loginItem.state = self.loginItem.isEnabled ? .on : .off
        menu.addItem(loginItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: quitTitle, action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
    }

    @objc private func openSettingsItem() {
        openSettings()
    }

    @objc private func toggleLoginItem() {
        loginItem.setEnabled(!loginItem.isEnabled)
        rebuildMenu()
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}
