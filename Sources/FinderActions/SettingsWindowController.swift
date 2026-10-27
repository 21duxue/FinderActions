import AppKit
import SwiftUI
import FinderActionsCore

final class SettingsWindowController: NSWindowController {
    private let model: SettingsViewModel

    init(store: SettingsStore = SettingsStore()) {
        self.model = SettingsViewModel(store: store)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 560, height: 540),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "FinderActions"
        window.isReleasedWhenClosed = false
        window.center()
        super.init(window: window)

        let hostingView = NSHostingView(rootView: SettingsView(model: model))
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        window.contentView = hostingView

        NSLayoutConstraint.activate([
            hostingView.leadingAnchor.constraint(equalTo: window.contentView!.leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: window.contentView!.trailingAnchor),
            hostingView.topAnchor.constraint(equalTo: window.contentView!.topAnchor),
            hostingView.bottomAnchor.constraint(equalTo: window.contentView!.bottomAnchor)
        ])

        window.delegate = self
    }

    required init?(coder: NSCoder) {
        nil
    }
}

extension SettingsWindowController: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        // Keep the app running so clicking the Dock icon can reopen Settings.
    }
}
