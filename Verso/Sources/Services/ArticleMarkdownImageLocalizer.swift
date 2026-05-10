import Foundation

/// FAB-140: Downloads Markdown images referenced as remote `![](https://…)`, saves them beside the Markdown file in `"{articleBasename}.media"`,
/// and rewrites markdown to `./{articleBasename}.media/{file}` URLs.
enum ArticleMarkdownImageLocalizer {

    private static let maxImageBytes = 25 * 1024 * 1024

    private static let imageRegex: NSRegularExpression = {
        // swiftlint:disable:next force_try
        try! NSRegularExpression(pattern: #"!\[([^\]]*)\]\((https?://[^)\s]+)\)"#, options: [])
    }()

    static func localizeMarkdownRemoteImages(_ markdown: String, markdownFileURL: URL) async throws -> String {
        guard !markdown.isEmpty else { return markdown }

        let nsFull = markdown as NSString
        let whole = NSRange(location: 0, length: nsFull.length)
        let matches = imageRegex.matches(in: markdown, options: [], range: whole)
        guard !matches.isEmpty else { return markdown }

        let stem = markdownFileURL.deletingPathExtension().lastPathComponent
        let mediaDirURL = markdownFileURL
            .deletingLastPathComponent()
            .appendingPathComponent("\(stem).media", isDirectory: true)

        try FileManager.default.createDirectory(at: mediaDirURL, withIntermediateDirectories: true)

        var remoteToFilename: [String: String] = [:]
        for match in matches where match.numberOfRanges >= 3 {
            let remote = nsFull.substring(with: match.range(at: 2))
            guard URL(string: remote)?.scheme?.lowercased().hasPrefix("http") == true else { continue }
            guard remoteToFilename[remote] == nil else { continue }
            guard let remoteURL = URL(string: remote) else { continue }

            do {
                let (data, response) = try await download(remoteURL)
                guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else { continue }
                let ext = mimeExtension(http.mimeType) ?? guessedExtension(for: remoteURL)
                let filename = UUID().uuidString + "." + ext
                try data.write(to: mediaDirURL.appendingPathComponent(filename), options: .atomic)
                remoteToFilename[remote] = filename
            } catch {
                continue
            }
        }

        guard !remoteToFilename.isEmpty else { return markdown }

        let mutable = NSMutableString(string: markdown)
        for match in matches.reversed() where match.numberOfRanges >= 3 {
            let remote = nsFull.substring(with: match.range(at: 2))
            guard let filename = remoteToFilename[remote] else { continue }
            let alt = nsFull.substring(with: match.range(at: 1))
            let replacement = "![\(alt)](./\(stem).media/\(filename))"
            mutable.replaceCharacters(in: match.range(at: 0), with: replacement)
        }

        return mutable as String
    }

    // MARK: - Networking

    private static func download(_ url: URL) async throws -> (Data, URLResponse) {
        var request = URLRequest(url: url, timeoutInterval: 35)
        request.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard data.count <= maxImageBytes else {
            throw URLError(.dataNotAllowed)
        }
        return (data, response)
    }

    private static func guessedExtension(for url: URL) -> String {
        let ext = url.pathExtension.lowercased().trimmingCharacters(in: .whitespaces)
        if ["jpg", "jpeg", "png", "gif", "webp", "heic"].contains(ext) {
            return ext == "jpeg" ? "jpg" : ext
        }
        return "jpg"
    }

    private static func mimeExtension(_ mime: String?) -> String? {
        guard let mime else { return nil }
        switch mime.lowercased() {
        case "image/jpeg", "image/jpg":
            return "jpg"
        case "image/png":
            return "png"
        case "image/gif":
            return "gif"
        case "image/webp":
            return "webp"
        case "image/heic", "image/heif":
            return "heic"
        default:
            return nil
        }
    }
}
