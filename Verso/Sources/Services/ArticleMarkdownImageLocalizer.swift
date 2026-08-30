import Foundation

/// FAB-140: Downloads Markdown images referenced as remote `![](https://…)`, saves them beside the Markdown file in `"{articleBasename}.media"`,
/// and rewrites markdown to `./{articleBasename}.media/{file}` URLs.
enum ArticleMarkdownImageLocalizer {

    private static let maxImageBytes = 25 * 1024 * 1024
    /// FAB-295: keeps individual downloaded filenames well under filesystem path limits even
    /// when the article stem itself is close to its own ~100-char cap (`MarkdownWriter.generateFilename`).
    private static let maxFilenameStemLength = 80

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

        // The `.media` directory itself keeps the article's full (untruncated) stem -- it
        // already works today and already-saved articles link to it by that exact name.
        // Individual filenames use a separately truncated prefix (FAB-295) since the stem alone
        // can already be 100+ chars and the full path (directory + filename) has OS limits.
        let stem = markdownFileURL.deletingPathExtension().lastPathComponent
        let filenameStem = truncatedFilenameStem(stem)
        let mediaDirURL = markdownFileURL
            .deletingLastPathComponent()
            .appendingPathComponent("\(stem).media", isDirectory: true)

        try FileManager.default.createDirectory(at: mediaDirURL, withIntermediateDirectories: true)

        var remoteToFilename: [String: String] = [:]
        var nextIndex = 1
        for match in matches where match.numberOfRanges >= 3 {
            let remote = nsFull.substring(with: match.range(at: 2))
            guard URL(string: remote)?.scheme?.lowercased().hasPrefix("http") == true else { continue }
            guard remoteToFilename[remote] == nil else { continue }
            guard let remoteURL = URL(string: remote) else { continue }

            do {
                let (data, response) = try await download(remoteURL)
                guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else { continue }
                let ext = mimeExtension(http.mimeType) ?? guessedExtension(for: remoteURL)
                // Stable, ordered, readable name in document order -- e.g. "My Article-01.jpg" --
                // instead of a random UUID (Fabio's request, FAB-295).
                let baseName = "\(filenameStem)-\(String(format: "%02d", nextIndex))"
                let filename = uniqueMediaFilename(base: baseName, ext: ext, in: mediaDirURL)
                try data.write(to: mediaDirURL.appendingPathComponent(filename), options: .atomic)
                remoteToFilename[remote] = filename
                nextIndex += 1
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

    // MARK: - Filenames (FAB-295)

    /// Truncates an article stem to a safe length for use as an image-filename *prefix* — the
    /// stem alone can already be 100+ chars (`MarkdownWriter.generateFilename`'s own 100-char
    /// title cap plus the date/"Article" prefix). Internal (not `private`) so it's directly
    /// unit-testable, matching `MarkdownWriter.uniqueFilename`'s existing convention.
    static func truncatedFilenameStem(_ stem: String, maxLength: Int = maxFilenameStemLength) -> String {
        guard stem.count > maxLength else { return stem }
        return String(stem.prefix(maxLength))
    }

    /// Appends `-b`, `-c`, … when `base.ext` (or an earlier lettered variant) already exists in
    /// `directory` — e.g. re-localizing an article that already has downloaded images. Letters
    /// (not more digits) keep a collision suffix visually distinct from the `-01`/`-02` document
    /// ordering. Internal (not `private`) so it's directly unit-testable.
    static func uniqueMediaFilename(base: String, ext: String, in directory: URL) -> String {
        let plain = "\(base).\(ext)"
        let fm = FileManager.default
        if !fm.fileExists(atPath: directory.appendingPathComponent(plain).path) {
            return plain
        }
        // Starts at "b" (never "a") -- same convention as MarkdownWriter.uniqueFilename, where
        // the plain name is the implicit first variant and numbering starts at "(2)".
        for letterOffset in 1..<26 {
            let letter = Character(UnicodeScalar(UInt8(97 + letterOffset)))
            let candidate = "\(base)-\(letter).\(ext)"
            if !fm.fileExists(atPath: directory.appendingPathComponent(candidate).path) {
                return candidate
            }
        }
        // Astronomically unlikely (26+ same-named collisions in one article's media folder).
        return "\(base)-\(UUID().uuidString.prefix(6)).\(ext)"
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
