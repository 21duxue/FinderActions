import Foundation

public enum FinderAction: Equatable, Sendable {
    case newFile(name: String)
    case openTerminal
    case copyPath
    case copyName
}
