import Foundation

enum MarkdownWriterError: Error, LocalizedError {
    case emptyTitle
    case fileWriteFailed(Error)
    case couldNotGenerateUniqueFilename(maxAttempts: Int)
    case replacePathOutsideLibrary

    var errorDescription: String? {
        switch self {
        case .emptyTitle:
            return "Article title cannot be empty."
        case .fileWriteFailed(let underlying):
            return "Failed to write file: \(underlying.localizedDescription)"
        case .couldNotGenerateUniqueFilename(let maxAttempts):
            return "Could not generate a unique filename after \(maxAttempts) attempts."
        case .replacePathOutsideLibrary:
            return "Replace target is outside the Verso library folder."
        }
    }
}

struct MarkdownWriter {

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        // Fixed-format storage value: pin to POSIX so a non-Gregorian device calendar or
        // localized digits can never corrupt the on-disk frontmatter. See docs/LOCALIZATION.md §3.
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    /// Sanitizes a string for use in a filename by removing/replacing invalid characters.
    static func sanitizeFilename(_ name: String) -> String {
        // Replace path separators and colons with dashes
        var sanitized = name.replacingOccurrences(of: "/", with: "-")
        sanitized = sanitized.replacingOccurrences(of: ":", with: "-")
        sanitized = sanitized.replacingOccurrences(of: "..", with: ".")
        // Remove any characters not allowed in filenames
        let allowedCharacters = CharacterSet.alphanumerics
            .union(CharacterSet.whitespaces)
            .union(CharacterSet(charactersIn: "-_."))
        sanitized = sanitized.components(separatedBy: allowedCharacters.inverted).joined()
        // Collapse multiple spaces/dashes
        while sanitized.contains("  ") {
            sanitized = sanitized.replacingOccurrences(of: "  ", with: " ")
        }
        while sanitized.contains("--") {
            sanitized = sanitized.replacingOccurrences(of: "--", with: "-")
        }
        return sanitized.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Generates the initial filename for an article: YYYY-MM-DD Title.md
    static func generateFilename(for article: ParsedArticle) -> String {
        let dateStr = dateFormatter.string(from: article.dateAdded)
        let sanitizedTitle = sanitizeFilename(article.title)
        let truncated = String(sanitizedTitle.prefix(100))
        return "\(dateStr) Article \(truncated).md"
    }

    /// Resolves filename collisions by appending a counter: Title (2).md, Title (3).md, etc.
    static func uniqueFilename(baseName: String, in directory: URL, maxAttempts: Int = 100) throws -> String {
        let baseURL = directory.appendingPathComponent(baseName)
        if !FileManager.default.fileExists(atPath: baseURL.path) {
            return baseName
        }

        let name = (baseName as NSString).deletingPathExtension
        let ext = (baseName as NSString).pathExtension

        for attempt in 2...maxAttempts {
            let candidate = "\(name) (\(attempt)).\(ext)"
            let candidateURL = directory.appendingPathComponent(candidate)
            if !FileManager.default.fileExists(atPath: candidateURL.path) {
                return candidate
            }
        }

        throw MarkdownWriterError.couldNotGenerateUniqueFilename(maxAttempts: maxAttempts)
    }

    /// Builds the YAML frontmatter string for the article.
    static func buildFrontmatter(for article: ParsedArticle) -> String {
        var lines = ["---"]

        // Title (always present)
        let escapedTitle = article.title.replacingOccurrences(of: "\"", with: "\\\"")
        lines.append("title: \"\(escapedTitle)\"")

        // URL (optional)
        if let url = article.url {
            lines.append("url: \"\(url.absoluteString)\"")
        }

        if let author = article.author?.trimmingCharacters(in: .whitespacesAndNewlines), !author.isEmpty {
            let escaped = author.replacingOccurrences(of: "\"", with: "\\\"")
            lines.append("author: \"\(escaped)\"")
        }

        if let site = article.siteName?.trimmingCharacters(in: .whitespacesAndNewlines), !site.isEmpty {
            let escaped = site.replacingOccurrences(of: "\"", with: "\\\"")
            lines.append("site_name: \"\(escaped)\"")
        }

        // Status
        lines.append("status: \(article.status.rawValue)")

        if let sp = article.scrollPosition {
            let clamped = min(1, max(0, sp))
            lines.append(String(format: "scroll_position: %.4f", clamped))
        }

        // Tags (optional)
        if let tags = article.tags, !tags.isEmpty {
            let tagsStr = tags.map { "\"\($0.replacingOccurrences(of: "\"", with: "\\\""))\"" }.joined(separator: ", ")
            lines.append("tags: [\(tagsStr)]")
        }

        // Added date
        let dateStr = dateFormatter.string(from: article.dateAdded)
        lines.append("added: \(dateStr)")

        lines.append("---")
        return lines.joined(separator: "\n") + "\n"
    }

    /// Deletes the .md file at the given path.
    static func delete(at filePath: String) throws {
        try FileManager.default.removeItem(atPath: filePath)
    }

    /// Moves the .md file into an Archive/ subfolder of the given folder, creating it if needed.
    /// Returns the destination URL.
    @discardableResult
    static func archive(filePath: String, in folderURL: URL) throws -> URL {
        let archiveDir = folderURL.appendingPathComponent("Archive", isDirectory: true)
        let fm = FileManager.default
        if !fm.fileExists(atPath: archiveDir.path) {
            try fm.createDirectory(at: archiveDir, withIntermediateDirectories: true)
        }
        let filename = URL(fileURLWithPath: filePath).lastPathComponent
        let destination = archiveDir.appendingPathComponent(filename)
        try fm.moveItem(atPath: filePath, toPath: destination.path)
        return destination
    }

    /// Updates the `status:` line in the YAML frontmatter of an existing .md file.
    static func updateStatus(_ status: Article.Status, for filePath: String) throws {
        let url = URL(fileURLWithPath: filePath)
        var content = try String(contentsOf: url, encoding: .utf8)
        let pattern = #"(?m)^status: \S+$"#
        let replacement = "status: \(status.rawValue)"
        if let regex = try? NSRegularExpression(pattern: pattern) {
            let range = NSRange(content.startIndex..., in: content)
            content = regex.stringByReplacingMatches(in: content, range: range, withTemplate: replacement)
        }
        try content.write(to: url, atomically: true, encoding: .utf8)
    }

    /// Persists normalized scroll depth (0...1) in frontmatter for cross-device resume via iCloud Drive.
    static func updateScrollPosition(_ fraction: Double, for filePath: String) throws {
        let clamped = min(1, max(0, fraction))
        let line = String(format: "scroll_position: %.4f", clamped)
        let url = URL(fileURLWithPath: filePath)
        var content = try String(contentsOf: url, encoding: .utf8)
        let pattern = #"(?m)^scroll_position:.*$"#
        if let regex = try? NSRegularExpression(pattern: pattern) {
            let range = NSRange(content.startIndex..., in: content)
            if regex.firstMatch(in: content, options: [], range: range) != nil {
                content = regex.stringByReplacingMatches(in: content, range: range, withTemplate: line)
                try content.write(to: url, atomically: true, encoding: .utf8)
                return
            }
        }
        // Insert after `status:` line when missing
        let statusPattern = #"(?m)^(status: \S+)$"#
        if let regex = try? NSRegularExpression(pattern: statusPattern) {
            let range = NSRange(content.startIndex..., in: content)
            if regex.firstMatch(in: content, options: [], range: range) != nil {
                let template = "$1\n\(line)"
                content = regex.stringByReplacingMatches(in: content, range: range, withTemplate: template)
                try content.write(to: url, atomically: true, encoding: .utf8)
                return
            }
        }
        throw MarkdownWriterError.fileWriteFailed(NSError(domain: "MarkdownWriter", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not insert scroll_position into frontmatter"]))
    }

    /// Replaces or inserts the `tags:` YAML line (JSON-array style, same as new articles).
    static func updateTags(_ tags: [String], for filePath: String) throws {
        let url = URL(fileURLWithPath: filePath)
        var content = try String(contentsOf: url, encoding: .utf8)
        let sorted = tags.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        let tagsLine: String
        if sorted.isEmpty {
            tagsLine = "tags: []"
        } else {
            let inner = sorted.map { "\"\($0.replacingOccurrences(of: "\\\"", with: "\\\\\""))\"" }.joined(separator: ", ")
            tagsLine = "tags: [\(inner)]"
        }
        let pattern = #"(?m)^tags:.*$"#
        if let regex = try? NSRegularExpression(pattern: pattern) {
            let range = NSRange(content.startIndex..., in: content)
            if regex.firstMatch(in: content, options: [], range: range) != nil {
                content = regex.stringByReplacingMatches(in: content, range: range, withTemplate: tagsLine)
                try content.write(to: url, atomically: true, encoding: .utf8)
                return
            }
        }
        if let regex = try? NSRegularExpression(pattern: #"(?m)^(status: \S+)$"#) {
            let range = NSRange(content.startIndex..., in: content)
            if regex.firstMatch(in: content, options: [], range: range) != nil {
                content = regex.stringByReplacingMatches(in: content, range: range, withTemplate: "$1\n\(tagsLine)")
                try content.write(to: url, atomically: true, encoding: .utf8)
                return
            }
        }
        throw MarkdownWriterError.fileWriteFailed(NSError(domain: "MarkdownWriter", code: 2, userInfo: [NSLocalizedDescriptionKey: "Could not insert tags into frontmatter"]))
    }

    /// Writes a ParsedArticle to a .md file in the specified directory.
    /// - Parameters:
    ///   - article: The parsed article to write.
    ///   - directoryURL: The directory URL where the file should be saved.
    /// - Returns: The URL of the written file.
    /// - Throws: MarkdownWriterError or other file-related errors.
    static func write(article: ParsedArticle, to directoryURL: URL) async throws -> URL {
        guard !article.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw MarkdownWriterError.emptyTitle
        }

        // Generate filename and handle collisions
        let baseFilename = generateFilename(for: article)
        let filename = try uniqueFilename(baseName: baseFilename, in: directoryURL)

        let fileURL = directoryURL.appendingPathComponent(filename)
        let processedBody = try await ArticleMarkdownImageLocalizer.localizeMarkdownRemoteImages(
            article.contentMarkdown,
            markdownFileURL: fileURL
        )
        let frontmatter = buildFrontmatter(for: article)
        let content = frontmatter + processedBody

        do {
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            throw MarkdownWriterError.fileWriteFailed(error)
        }
    }

    /// Overwrites an existing `.md` file. Preserves `added`, `status`, `scroll_position`, and `tags` from disk;
    /// refreshes title, URL, body, author, and site from `incoming`.
    static func replaceArticle(at fileURL: URL, incoming: ParsedArticle, libraryRoot: URL) async throws {
        try assertReplacePath(fileURL, isWithin: libraryRoot)
        guard !incoming.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw MarkdownWriterError.emptyTitle
        }

        let existing = try MarkdownReader.read(fileURL: fileURL)
        let merged = ParsedArticle(
            id: existing.id,
            filePath: fileURL,
            title: incoming.title,
            url: incoming.url,
            contentMarkdown: incoming.contentMarkdown,
            tags: existing.tags,
            scrollPosition: existing.scrollPosition,
            dateAdded: existing.dateAdded,
            status: existing.status,
            author: incoming.author,
            siteName: incoming.siteName
        )

        let processedBody = try await ArticleMarkdownImageLocalizer.localizeMarkdownRemoteImages(
            merged.contentMarkdown,
            markdownFileURL: fileURL
        )
        let frontmatter = buildFrontmatter(for: merged)
        let content = frontmatter + processedBody
        do {
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            throw MarkdownWriterError.fileWriteFailed(error)
        }
    }

    private static func assertReplacePath(_ fileURL: URL, isWithin libraryRoot: URL) throws {
        let f = fileURL.resolvingSymlinksInPath().standardizedFileURL.path
        let r = libraryRoot.resolvingSymlinksInPath().standardizedFileURL.path
        let prefix = r.hasSuffix("/") ? r : r + "/"
        guard f.hasPrefix(prefix) else {
            throw MarkdownWriterError.replacePathOutsideLibrary
        }
    }
}
