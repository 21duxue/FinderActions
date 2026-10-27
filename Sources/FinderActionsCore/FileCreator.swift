import Foundation

public enum FileCreator {
    public static func createFile(in directory: URL, fileName: String) throws -> URL {
        let trimmedName = fileName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard FilenameGenerator.isValidName(trimmedName) else {
            throw CocoaError(.fileWriteInvalidFileName)
        }

        let uniqueName = FilenameGenerator.uniqueName(for: trimmedName, in: directory)
        let destination = directory.appendingPathComponent(uniqueName)
        try Data().write(to: destination, options: .withoutOverwriting)
        return destination
    }
}
