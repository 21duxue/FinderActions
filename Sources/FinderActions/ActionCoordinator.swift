import AppKit
import FinderActionsCore

@MainActor
enum ActionCoordinator {
    static func handle(_ url: URL) {
        guard let parsed = ActionLink.parse(url) else { return }

        switch parsed {
        case .newFile(let directory, let fileName):
            createFile(in: directory, defaultName: fileName)
        case .openTerminal(let directory):
            openTerminal(at: directory)
        case .copyPaths(let paths):
            copy(paths.map(\.path))
        case .copyNames(let paths):
            copy(paths.map(\.lastPathComponent))
        }
    }

    private static func createFile(in directory: URL, defaultName: String) {
        let panel = NSSavePanel()
        panel.directoryURL = directory
        panel.nameFieldStringValue = defaultName
        panel.canCreateDirectories = true

        guard panel.runModal() == .OK, let url = panel.url else { return }

        do {
            let createdURL = try FileCreator.createFile(in: url.deletingLastPathComponent(), fileName: url.lastPathComponent)
            NSWorkspace.shared.activateFileViewerSelecting([createdURL])
        } catch {
            showAlert(message: "无法创建文件：\(error.localizedDescription)")
        }
    }

    private static func openTerminal(at directory: URL) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        process.arguments = ["-a", "Terminal", directory.path]

        do {
            try process.run()
        } catch {
            showAlert(message: "无法打开终端：\(error.localizedDescription)")
        }
    }

    private static func copy(_ values: [String]) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(values.joined(separator: "\n"), forType: .string)
    }

    private static func showAlert(message: String) {
        let alert = NSAlert()
        alert.messageText = message
        alert.runModal()
    }
}
