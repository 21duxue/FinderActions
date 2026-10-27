import Foundation

public struct MenuPresentation: Equatable, Sendable {
    public var parentTitle: String?
    public var items: [MenuItemID]

    public init(parentTitle: String?, items: [MenuItemID]) {
        self.parentTitle = parentTitle
        self.items = items
    }
}

public enum MenuPresenter {
    public static func presentation(for settings: AppSettings) -> MenuPresentation? {
        let items = settings.menu.sortedItems
        guard !items.isEmpty else { return nil }

        switch settings.menu.mode {
        case .submenu:
            return MenuPresentation(parentTitle: "FinderActions", items: items)
        case .flat:
            return MenuPresentation(parentTitle: nil, items: items)
        }
    }
}
