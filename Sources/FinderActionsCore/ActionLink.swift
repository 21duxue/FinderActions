import Foundation

public enum ActionLink {
    public static let scheme = "finderactions"

    public static func newFile(directory: URL, fileName: String) -> URL {
        url(host: "new-file", queryItems: [
            URLQueryItem(name: "directory", value: directory.path),
            URLQueryItem(name: "name", value: fileName)
        ])
    }

    public static func openTerminal(directory: URL) -> URL {
        url(host: "open-terminal", queryItems: [
            URLQueryItem(name: "directory", value: directory.path)
        ])
    }

    public static func copyPaths(_ paths: [URL]) -> URL {
        url(host: "copy-path", queryItems: [
            URLQueryItem(name: "paths", value: paths.map(\.path).joined(separator: "\n"))
        ])
    }

    public static func copyNames(_ paths: [URL]) -> URL {
        url(host: "copy-name", queryItems: [
            URLQueryItem(name: "paths", value: paths.map(\.path).joined(separator: "\n"))
        ])
    }

    public static func parse(_ url: URL) -> Parsed? {
        guard url.scheme?.lowercased() == scheme else { return nil }
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let items = components?.queryItems ?? []
        let values = Dictionary(uniqueKeysWithValues: items.map { ($0.name, $0.value ?? "") })

        switch url.host?.lowercased() {
        case "new-file":
            guard let directory = values["directory"], !directory.isEmpty,
                  let name = values["name"], !name.isEmpty else { return nil }
            return .newFile(directory: URL(fileURLWithPath: directory), fileName: name)
        case "open-terminal":
            guard let directory = values["directory"], !directory.isEmpty else { return nil }
            return .openTerminal(directory: URL(fileURLWithPath: directory))
        case "copy-path":
            guard let paths = values["paths"], !paths.isEmpty else { return nil }
            return .copyPaths(paths.split(separator: "\n").map { URL(fileURLWithPath: String($0)) })
        case "copy-name":
            guard let paths = values["paths"], !paths.isEmpty else { return nil }
            return .copyNames(paths.split(separator: "\n").map { URL(fileURLWithPath: String($0)) })
        default:
            return nil
        }
    }

    public enum Parsed {
        case newFile(directory: URL, fileName: String)
        case openTerminal(directory: URL)
        case copyPaths([URL])
        case copyNames([URL])
    }

    private static func url(host: String, queryItems: [URLQueryItem]) -> URL {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.queryItems = queryItems
        return components.url!
    }
}
