import AppKit
import FinderActionsCore

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var settingsWindow: SettingsWindowController?
    private var statusBarController: StatusBarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusBarController = StatusBarController(
            loginItem: LoginItemController.shared,
            openSettings: { [weak self] in
                self?.showSettings()
            }
        )

        let launchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        if !launchedBefore {
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            DispatchQueue.main.async { [weak self] in
                self?.showSettings()
            }
        }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        DispatchQueue.main.async { [weak self] in
            self?.showSettings()
        }
        return false
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        for url in urls {
            ActionCoordinator.handle(url)
        }
    }

    func showSettings() {
        if settingsWindow == nil {
            settingsWindow = SettingsWindowController()
        }
        settingsWindow?.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
