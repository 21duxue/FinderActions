import Foundation

public enum CopiedText {
    public static func paths(from selection: PathSelection) -> String {
        selection.effectiveItems.map(\.path).joined(separator: "\n")
    }

    public static func names(from selection: PathSelection) -> String {
        selection.effectiveItems.map(\.lastPathComponent).joined(separator: "\n")
    }
}
