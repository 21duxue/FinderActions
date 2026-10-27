import Testing
import Foundation
@testable import FinderActionsCore

@Suite
struct ActionLinkTests {
    @Test
    func newFileRoundTrip() {
        let directory = URL(fileURLWithPath: "/tmp/FinderActions")
        let url = ActionLink.newFile(directory: directory, fileName: "Untitled.txt")
        guard case let .newFile(parsedDirectory, parsedName) = ActionLink.parse(url) else {
            Issue.record()
            return
        }

        #expect(parsedDirectory == directory)
        #expect(parsedName == "Untitled.txt")
    }

    @Test
    func openTerminalRoundTrip() {
        let directory = URL(fileURLWithPath: "/tmp/FinderActions")
        let url = ActionLink.openTerminal(directory: directory)
        guard case let .openTerminal(parsedDirectory) = ActionLink.parse(url) else {
            Issue.record()
            return
        }

        #expect(parsedDirectory == directory)
    }

    @Test
    func copyPathsRoundTrip() {
        let paths = [
            URL(fileURLWithPath: "/tmp/One.md"),
            URL(fileURLWithPath: "/tmp/Two.md")
        ]
        let url = ActionLink.copyPaths(paths)
        guard case let .copyPaths(parsedPaths) = ActionLink.parse(url) else {
            Issue.record()
            return
        }

        #expect(parsedPaths == paths)
    }

    @Test
    func copyNamesRoundTrip() {
        let paths = [
            URL(fileURLWithPath: "/tmp/One.md"),
            URL(fileURLWithPath: "/tmp/Two.md")
        ]
        let url = ActionLink.copyNames(paths)
        guard case let .copyNames(parsedPaths) = ActionLink.parse(url) else {
            Issue.record()
            return
        }

        #expect(parsedPaths == paths)
    }

    @Test
    func rejectsOtherSchemes() {
        let url = URL(string: "https://example.com/new-file?directory=/tmp")!
        #expect(ActionLink.parse(url) == nil)
    }
}
