import Foundation

public struct AppSettings: Codable, Equatable, Sendable {
    public var menu: MenuConfiguration
    public var language: AppLanguage
    public var defaultFileName: String

    public init(
        menu: MenuConfiguration = MenuConfiguration(),
        language: AppLanguage = .chinese,
        defaultFileName: String = "Untitled.txt"
    ) {
        self.menu = menu
        self.language = language
        self.defaultFileName = defaultFileName
    }
}
