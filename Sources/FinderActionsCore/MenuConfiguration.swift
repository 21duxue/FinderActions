import Foundation

public struct MenuConfiguration: Codable, Equatable, Sendable {
    public var enabledItems: Set<MenuItemID>
    public var mode: MenuMode

    public init(
        enabledItems: Set<MenuItemID> = Set(MenuItemID.allCases),
        mode: MenuMode = .submenu
    ) {
        self.enabledItems = enabledItems
        self.mode = mode
    }

    public func isEnabled(_ item: MenuItemID) -> Bool {
        enabledItems.contains(item)
    }

    public mutating func set(_ item: MenuItemID, enabled: Bool) {
        if enabled {
            enabledItems.insert(item)
        } else {
            enabledItems.remove(item)
        }
    }

    public var sortedItems: [MenuItemID] {
        MenuItemID.allCases.filter(isEnabled)
    }
}
