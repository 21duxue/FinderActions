import Testing
import Foundation
@testable import FinderActionsCore

@Suite
struct FilenameGeneratorTests {
    @Test
    func validNames() {
        #expect(FilenameGenerator.isValidName("notes.md"))
        #expect(FilenameGenerator.isValidName(".env"))
        #expect(FilenameGenerator.isValidName("  spaced-name.txt  "))
    }

    @Test
    func invalidNames() {
        #expect(!FilenameGenerator.isValidName(""))
        #expect(!FilenameGenerator.isValidName("   "))
        #expect(!FilenameGenerator.isValidName("."))
        #expect(!FilenameGenerator.isValidName(".."))
        #expect(!FilenameGenerator.isValidName("a/b.md"))
    }

    @Test
    func uniqueNameUsesFinderStyleNumbering() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("FinderActionsTests", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        let first = FilenameGenerator.uniqueName(for: "notes.md", in: directory)
        #expect(first == "notes.md")
        try Data().write(to: directory.appendingPathComponent("notes.md"))

        let second = FilenameGenerator.uniqueName(for: "notes.md", in: directory)
        #expect(second == "notes 2.md")
        try Data().write(to: directory.appendingPathComponent("notes 2.md"))

        let third = FilenameGenerator.uniqueName(for: "notes.md", in: directory)
        #expect(third == "notes 3.md")

        try? FileManager.default.removeItem(at: directory)
    }
}
