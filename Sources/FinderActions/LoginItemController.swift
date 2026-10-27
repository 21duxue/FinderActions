import Foundation
import ServiceManagement

@MainActor
final class LoginItemController: ObservableObject {
    static let shared = LoginItemController()

    @Published var isEnabled: Bool
    @Published var lastError: String?

    init() {
        self.isEnabled = SMAppService.mainApp.status == .enabled
    }

    func setEnabled(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            isEnabled = SMAppService.mainApp.status == .enabled
            lastError = nil
        } catch {
            isEnabled = SMAppService.mainApp.status == .enabled
            lastError = error.localizedDescription
        }
    }
}
