import SwiftUI
import FinderActionsCore

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var settings: AppSettings {
        didSet { store.save(settings) }
    }

    private let store: SettingsStore

    init(store: SettingsStore = SettingsStore()) {
        self.store = store
        self.settings = store.load()
    }

    func reset() {
        settings = AppSettings()
    }
}

struct SettingsView: View {
    @ObservedObject var model: SettingsViewModel
    @ObservedObject private var loginItem = LoginItemController.shared

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            form
        }
        .frame(minWidth: 540, idealWidth: 580, minHeight: 560, idealHeight: 620)
        .tint(.teal)
    }

    private var header: some View {
        HStack(spacing: 12) {
            AppIconView()

            VStack(alignment: .leading, spacing: 2) {
                Text("FinderActions")
                    .font(.system(size: 20, weight: .semibold))
                Text(localized.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Picker("", selection: languageBinding) {
                Text("中文").tag(AppLanguage.chinese)
                Text("English").tag(AppLanguage.english)
            }
            .pickerStyle(.segmented)
            .frame(width: 150)
            .labelsHidden()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }

    private var form: some View {
        Form {
            Section {
                Picker(localized.menuMode, selection: menuModeBinding) {
                    Text(localized.submenuTitle).tag(MenuMode.submenu)
                    Text(localized.flatTitle).tag(MenuMode.flat)
                }
                .pickerStyle(.segmented)

                Text(localized.menuModeHelp)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            } header: {
                Text(localized.menuSection)
            }

            Section {
                ForEach(MenuItemID.allCases, id: \.self) { item in
                    Toggle(isOn: actionBinding(item)) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title(for: model.settings.language))
                            Text(localized.description(for: item))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .toggleStyle(.switch)
                }
            } header: {
                Text(localized.actionsSection)
            } footer: {
                Text(localized.actionsHelp)
                    .foregroundStyle(.secondary)
            }

            Section(localized.fileSection) {
                TextField(localized.defaultFileName, text: defaultNameBinding)
                Text(localized.fileHelp)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section {
                HStack(spacing: 8) {
                    Circle()
                        .fill(.green)
                        .frame(width: 8, height: 8)
                    Text(localized.extensionIncluded)
                        .foregroundStyle(.secondary)
                }

                Button(localized.openExtensionSettings) {
                    openExtensionSettings()
                }
            } header: {
                Text(localized.extensionSection)
            } footer: {
                Text(localized.extensionHelp)
                    .foregroundStyle(.secondary)
            }

            Section {
                Toggle(isOn: launchAtLoginBinding) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(localized.launchAtLogin)
                        Text(localized.launchAtLoginHelp)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .toggleStyle(.switch)

                if let error = loginItem.lastError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            } header: {
                Text(localized.startupSection)
            }

            Section {
                Button(localized.reset, role: .destructive) {
                    model.reset()
                }
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.visible)
    }

    private var localized: LocalizedStrings {
        LocalizedStrings(language: model.settings.language)
    }

    private var languageBinding: Binding<AppLanguage> {
        Binding(
            get: { model.settings.language },
            set: { model.settings.language = $0 }
        )
    }

    private var menuModeBinding: Binding<MenuMode> {
        Binding(
            get: { model.settings.menu.mode },
            set: { model.settings.menu.mode = $0 }
        )
    }

    private var launchAtLoginBinding: Binding<Bool> {
        Binding(
            get: { loginItem.isEnabled },
            set: { loginItem.setEnabled($0) }
        )
    }

    private var defaultNameBinding: Binding<String> {
        Binding(
            get: { model.settings.defaultFileName },
            set: { model.settings.defaultFileName = $0 }
        )
    }

    private func actionBinding(_ item: MenuItemID) -> Binding<Bool> {
        Binding(
            get: { model.settings.menu.isEnabled(item) },
            set: { model.settings.menu.set(item, enabled: $0) }
        )
    }

    private func openExtensionSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.ExtensionsPreferences") {
            NSWorkspace.shared.open(url)
        }
    }
}

private struct AppIconView: View {
    var body: some View {
        if let image = NSImage(named: "AppIcon") {
            Image(nsImage: image)
                .resizable()
                .interpolation(.high)
                .frame(width: 36, height: 36)
        } else {
            Image(systemName: "folder.fill")
                .font(.system(size: 30, weight: .regular))
                .foregroundStyle(.teal)
                .frame(width: 36, height: 36)
        }
    }
}

private struct LocalizedStrings {
    let language: AppLanguage

    var subtitle: String {
        language == .chinese ? "Finder 右键菜单工具" : "Finder context menu utility"
    }

    var menuSection: String {
        language == .chinese ? "Finder 菜单" : "Finder menu"
    }

    var menuMode: String {
        language == .chinese ? "显示方式" : "Display"
    }

    var submenuTitle: String {
        language == .chinese ? "折叠到 FinderActions" : "Group under FinderActions"
    }

    var flatTitle: String {
        language == .chinese ? "直接显示在右键菜单" : "Show directly in context menu"
    }

    var menuModeHelp: String {
        language == .chinese
            ? "折叠会减少顶级菜单项；平铺会直接把动作显示在 Finder 右键菜单中。"
            : "Grouped reduces top-level items; Flat places the actions directly in Finder's context menu."
    }

    var actionsSection: String {
        language == .chinese ? "动作" : "Actions"
    }

    var actionsHelp: String {
        language == .chinese
            ? "关闭的动作会从 Finder 右键菜单中移除，并立即生效。"
            : "Disabled actions are removed from Finder's context menu immediately."
    }

    var fileSection: String {
        language == .chinese ? "新建文件" : "New file"
    }

    var defaultFileName: String {
        language == .chinese ? "默认文件名" : "Default file name"
    }

    var fileHelp: String {
        language == .chinese
            ? "点击 New File Here 后会以此名称预填，用户仍可修改。"
            : "New File Here uses this name as a starting point; it can still be edited."
    }

    var extensionSection: String {
        language == .chinese ? "Finder 扩展" : "Finder extension"
    }

    var extensionIncluded: String {
        language == .chinese ? "已包含在应用中" : "Included in the app"
    }

    var openExtensionSettings: String {
        language == .chinese ? "打开系统扩展设置" : "Open system extension settings"
    }

    var extensionHelp: String {
        language == .chinese
            ? "如果右键菜单没有出现，请在系统设置中确认 FinderActions 已启用，然后重启 Finder。"
            : "If the menu does not appear, enable FinderActions in System Settings and restart Finder."
    }

    var startupSection: String {
        language == .chinese ? "启动" : "Startup"
    }

    var launchAtLogin: String {
        language == .chinese ? "登录时启动 FinderActions" : "Launch FinderActions at login"
    }

    var launchAtLoginHelp: String {
        language == .chinese
            ? "在菜单栏运行 FinderActions，不打开设置窗口。"
            : "Run FinderActions in the menu bar without opening Settings."
    }

    var reset: String {
        language == .chinese ? "恢复默认设置" : "Reset to defaults"
    }

    func description(for item: MenuItemID) -> String {
        switch (language, item) {
        case (.chinese, .newFile):
            return "在当前目录创建空文件"
        case (.chinese, .openTerminal):
            return "使用 Apple Terminal 打开当前目录"
        case (.chinese, .copyPath):
            return "复制完整 POSIX 路径"
        case (.chinese, .copyName):
            return "复制文件名或文件夹名"
        case (.english, .newFile):
            return "Create an empty file in the current folder"
        case (.english, .openTerminal):
            return "Open the current folder in Apple Terminal"
        case (.english, .copyPath):
            return "Copy the full POSIX path"
        case (.english, .copyName):
            return "Copy the file or folder name"
        }
    }
}
