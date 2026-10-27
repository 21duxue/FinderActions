import Testing
import Foundation
@testable import FinderActionsCore

@Suite
struct FileCreatorTests {
    @Test
    func createsFileWithUniqueName() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("FinderActionsFileCreatorTests", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        let first = try FileCreator.createFile(in: directory, fileName: "notes.md")
        #expect(first.lastPathComponent == "notes.md")

        let second = try FileCreator.createFile(in: directory, fileName: "notes.md")
        #expect(second.lastPathComponent == "notes 2.md")

        try? FileManager.default.removeItem(at: directory)
    }

    @Test
    func rejectsInvalidName() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("FinderActionsFileCreatorInvalidTests", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        #expect(throws: CocoaError.fileWriteInvalidFileName) {
            _ = try FileCreator.createFile(in: directory, fileName: "a/b.md")
        }

        try? FileManager.default.removeItem(at: directory)
    }
}
