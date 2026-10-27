import Foundation
import FinderActionsCore

func expect(_ condition: Bool, _ message: String) {
    if condition {
        print("PASS: \(message)")
    } else {
        print("FAIL: \(message)")
        exit(1)
    }
}

let settings = AppSettings()
expect(settings.language == .chinese, "default language is Chinese")
expect(settings.menu.mode == .submenu, "default menu mode is submenu")
expect(settings.defaultFileName == "Untitled.txt", "default file name is Untitled.txt")
expect(settings.menu.enabledItems == Set(MenuItemID.allCases), "all actions are enabled by default")

var configured = settings
configured.menu.set(.copyName, enabled: false)
expect(!configured.menu.isEnabled(.copyName), "copy name can be disabled")
configured.menu.mode = .flat
expect(configured.menu.mode == .flat, "menu mode can be flat")

expect(FilenameGenerator.isValidName("notes.md"), "valid file name accepted")
expect(!FilenameGenerator.isValidName("a/b.md"), "file names with slash rejected")
expect(!FilenameGenerator.isValidName(".."), "reserved name rejected")

let selection = PathSelection(
    target: URL(fileURLWithPath: "/tmp/FinderActions"),
    selectedItems: [
        URL(fileURLWithPath: "/tmp/FinderActions/README.md"),
        URL(fileURLWithPath: "/tmp/FinderActions/Sources")
    ]
)
expect(CopiedText.paths(from: selection) == "/tmp/FinderActions/README.md\n/tmp/FinderActions/Sources", "paths are newline separated")
expect(CopiedText.names(from: selection) == "README.md\nSources", "names are newline separated")

let suiteName = "dev.finderactions.FinderActionsSmokeTests"
UserDefaults.standard.removePersistentDomain(forName: suiteName)
let store = SettingsStore(suiteName: suiteName)
var saved = AppSettings()
saved.language = .english
saved.menu.mode = .flat
saved.defaultFileName = "Example.md"
store.save(saved)
let loaded = store.load()
expect(loaded == saved, "settings round-trip through shared defaults")
UserDefaults.standard.removePersistentDomain(forName: suiteName)

let newFileURL = ActionLink.newFile(directory: URL(fileURLWithPath: "/tmp/FinderActions"), fileName: "Untitled.txt")
if case let .newFile(directory, name) = ActionLink.parse(newFileURL) {
    expect(directory == URL(fileURLWithPath: "/tmp/FinderActions"), "new-file URL round-trips directory")
    expect(name == "Untitled.txt", "new-file URL round-trips file name")
} else {
    expect(false, "new-file URL round-trips")
}

let terminalURL = ActionLink.openTerminal(directory: URL(fileURLWithPath: "/tmp/FinderActions"))
if case let .openTerminal(directory) = ActionLink.parse(terminalURL) {
    expect(directory == URL(fileURLWithPath: "/tmp/FinderActions"), "terminal URL round-trips directory")
} else {
    expect(false, "terminal URL round-trips")
}

let copyPathsURL = ActionLink.copyPaths([
    URL(fileURLWithPath: "/tmp/One.md"),
    URL(fileURLWithPath: "/tmp/Two.md")
])
if case let .copyPaths(paths) = ActionLink.parse(copyPathsURL) {
    expect(paths == [URL(fileURLWithPath: "/tmp/One.md"), URL(fileURLWithPath: "/tmp/Two.md")], "copy path URL round-trips paths")
} else {
    expect(false, "copy path URL round-trips")
}

var menuSettings = AppSettings()
menuSettings.menu.mode = .flat
let flatPresentation = MenuPresenter.presentation(for: menuSettings)
expect(flatPresentation?.parentTitle == nil, "flat menu has no parent title")
expect(flatPresentation?.items == [.newFile, .openTerminal, .copyPath, .copyName], "flat menu includes enabled actions")

menuSettings.menu.mode = .submenu
menuSettings.menu.set(.copyName, enabled: false)
let submenuPresentation = MenuPresenter.presentation(for: menuSettings)
expect(submenuPresentation?.parentTitle == "FinderActions", "submenu has parent title")
expect(submenuPresentation?.items == [.newFile, .openTerminal, .copyPath], "disabled action is removed from submenu")

let creatorDirectory = FileManager.default.temporaryDirectory
    .appendingPathComponent("FinderActionsSmokeFileCreator", isDirectory: true)
try? FileManager.default.removeItem(at: creatorDirectory)
try FileManager.default.createDirectory(at: creatorDirectory, withIntermediateDirectories: true)
let createdFile = try FileCreator.createFile(in: creatorDirectory, fileName: "notes.md")
expect(createdFile.lastPathComponent == "notes.md", "file creator creates requested file")
do {
    _ = try FileCreator.createFile(in: creatorDirectory, fileName: "a/b.md")
    expect(false, "file creator rejects invalid file names")
} catch let error as CocoaError {
    expect(error.code == .fileWriteInvalidFileName, "file creator rejects invalid file names")
} catch {
    expect(false, "file creator rejects invalid file names with CocoaError")
}
let createdFile2 = try FileCreator.createFile(in: creatorDirectory, fileName: "notes.md")
expect(createdFile2.lastPathComponent == "notes 2.md", "file creator avoids overwriting")
try? FileManager.default.removeItem(at: creatorDirectory)

print("All smoke tests passed.")
