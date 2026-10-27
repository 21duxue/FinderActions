import Foundation

public enum AppLanguage: String, CaseIterable, Codable, Sendable {
    case chinese
    case english

    public var isDefault: Bool {
        self == .chinese
    }
}
