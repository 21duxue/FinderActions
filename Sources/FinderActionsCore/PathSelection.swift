import Foundation

public struct PathSelection: Equatable, Sendable {
    public var target: URL?
    public var selectedItems: [URL]

    public init(target: URL? = nil, selectedItems: [URL] = []) {
        self.target = target
        self.selectedItems = selectedItems
    }

    public var effectiveItems: [URL] {
        if !selectedItems.isEmpty {
            return selectedItems
        }
        return target.map { [$0] } ?? []
    }

    public var effectiveDirectory: URL? {
        if let first = selectedItems.first {
            var isDirectory: ObjCBool = false
            if FileManager.default.fileExists(atPath: first.path, isDirectory: &isDirectory), isDirectory.boolValue {
                return first
            }
            return first.deletingLastPathComponent()
        }
        return target
    }
}
