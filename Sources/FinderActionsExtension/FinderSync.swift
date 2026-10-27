import Cocoa
import FinderActionsCore
import FinderSync

@objc(FinderActionsSync)
final class FinderActionsSync: FIFinderSync {
    private let store = SettingsStore()

    override init() {
        super.init()
        FIFinderSyncController.default().directoryURLs = [URL(fileURLWithPath: "/")]
    }

    override func menu(for menuKind: FIMenuKind) -> NSMenu? {
        guard menuKind == .contextualMenuForContainer || menuKind == .contextualMenuForItems else {
            return nil
        }

        let settings = store.load()
        guard let presentation = MenuPresenter.presentation(for: settings) else { return nil }
        let menu = NSMenu(title: "FinderActions")

        if let parentTitle = presentation.parentTitle {
            let parent = NSMenuItem(title: parentTitle, action: nil, keyEquivalent: "")
            let submenu = NSMenu(title: parentTitle)

            for item in presentation.items {
                submenu.addItem(menuItem(for: item, settings: settings))
            }

            parent.submenu = submenu
            menu.addItem(parent)
        } else {
            for item in presentation.items {
                menu.addItem(menuItem(for: item, settings: settings))
            }
        }

        return menu
    }

    private func menuItem(for item: MenuItemID, settings: AppSettings) -> NSMenuItem {
        let title = item.title(for: settings.language)

        switch item {
        case .newFile:
            return NSMenuItem(title: title, action: #selector(newFile(_:)), keyEquivalent: "")
        case .openTerminal:
            return NSMenuItem(title: title, action: #selector(openTerminal(_:)), keyEquivalent: "")
        case .copyPath:
            return NSMenuItem(title: title, action: #selector(copyPath(_:)), keyEquivalent: "")
        case .copyName:
            return NSMenuItem(title: title, action: #selector(copyName(_:)), keyEquivalent: "")
        }
    }

    private var pathSelection: PathSelection {
        let controller = FIFinderSyncController.default()
        return PathSelection(
            target: controller.targetedURL(),
            selectedItems: controller.selectedItemURLs() ?? []
        )
    }

    @objc private func newFile(_ sender: Any?) {
        let settings = store.load()
        let selection = pathSelection

        guard let directory = selection.effectiveDirectory else { return }
        let url = ActionLink.newFile(directory: directory, fileName: settings.defaultFileName)
        NSWorkspace.shared.open(url)
    }

    @objc private func openTerminal(_ sender: Any?) {
        let selection = pathSelection

        guard let directory = selection.effectiveDirectory else { return }
        let url = ActionLink.openTerminal(directory: directory)
        NSWorkspace.shared.open(url)
    }

    @objc private func copyPath(_ sender: Any?) {
        let selection = pathSelection
        let url = ActionLink.copyPaths(selection.effectiveItems)
        NSWorkspace.shared.open(url)
    }

    @objc private func copyName(_ sender: Any?) {
        let selection = pathSelection
        let url = ActionLink.copyNames(selection.effectiveItems)
        NSWorkspace.shared.open(url)
    }
}
