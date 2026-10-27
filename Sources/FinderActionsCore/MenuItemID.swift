import Foundation

public enum MenuItemID: String, CaseIterable, Codable, Sendable {
    case newFile
    case openTerminal
    case copyPath
    case copyName

    public func title(for language: AppLanguage) -> String {
        switch language {
        case .chinese:
            switch self {
            case .newFile: return "新建文件…"
            case .openTerminal: return "在此打开终端"
            case .copyPath: return "复制路径"
            case .copyName: return "复制名称"
            }
        case .english:
            switch self {
            case .newFile: return "New File…"
            case .openTerminal: return "Open Terminal Here"
            case .copyPath: return "Copy Path"
            case .copyName: return "Copy Name"
            }
        }
    }
}
