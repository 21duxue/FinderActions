import Foundation

public struct SettingsStore {
    public static let sharedSuiteName = "dev.finderactions.shared"

    private let defaults: UserDefaults
    private let key = "appSettings"

    public init(suiteName: String = SettingsStore.sharedSuiteName) {
        self.defaults = UserDefaults(suiteName: suiteName) ?? .standard
    }

    public func load() -> AppSettings {
        guard let data = defaults.data(forKey: key),
              let settings = try? JSONDecoder().decode(AppSettings.self, from: data) else {
            return AppSettings()
        }
        return settings
    }

    public func save(_ settings: AppSettings) {
        if let data = try? JSONEncoder().encode(settings) {
            defaults.set(data, forKey: key)
        }
    }
}
