import Foundation

public enum FilenameGenerator {
    public static func isValidName(_ name: String) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed != ".", trimmed != ".." else { return false }
        return !trimmed.contains("/")
    }

    public static func uniqueName(for proposedName: String, in directory: URL, fileManager: FileManager = .default) -> String {
        let name = proposedName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard isValidName(name) else { return name }

        let baseURL = directory.appendingPathComponent(name)
        if !fileManager.fileExists(atPath: baseURL.path) {
            return name
        }

        let stem = (name as NSString).deletingPathExtension
        let ext = (name as NSString).pathExtension

        for index in 2... {
            let candidate = ext.isEmpty ? "\(stem) \(index)" : "\(stem) \(index).\(ext)"
            let candidateURL = directory.appendingPathComponent(candidate)
            if !fileManager.fileExists(atPath: candidateURL.path) {
                return candidate
            }
        }

        return name
    }
}
