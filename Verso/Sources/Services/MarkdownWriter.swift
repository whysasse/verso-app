import Foundation

enum MarkdownWriterError: Error, LocalizedError {
    case emptyTitle
    case fileWriteFailed(Error)
    case couldNotGenerateUniqueFilename(maxAttempts: Int)

    var errorDescription: String? {
        switch self {
        case .emptyTitle:
            return "Article title cannot be empty."
        case .fileWriteFailed(let underlying):
            return "Failed to write file: \(underlying.localizedDescription)"
        case .couldNotGenerateUniqueFilename(let maxAttempts):
            return "Could not generate a unique filename after \(maxAttempts) attempts."
        }
    }
}

struct MarkdownWriter {

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
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

        // Status
        lines.append("status: \(article.status.rawValue)")

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

    /// Writes a ParsedArticle to a .md file in the specified directory.
    /// - Parameters:
    ///   - article: The parsed article to write.
    ///   - directoryURL: The directory URL where the file should be saved.
    /// - Returns: The URL of the written file.
    /// - Throws: MarkdownWriterError or other file-related errors.
    static func write(article: ParsedArticle, to directoryURL: URL) throws -> URL {
        guard !article.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw MarkdownWriterError.emptyTitle
        }

        // Generate filename and handle collisions
        let baseFilename = generateFilename(for: article)
        let filename = try uniqueFilename(baseName: baseFilename, in: directoryURL)

        // Build file content
        let frontmatter = buildFrontmatter(for: article)
        let content = frontmatter + article.contentMarkdown

        // Write file
        let fileURL = directoryURL.appendingPathComponent(filename)

        do {
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            throw MarkdownWriterError.fileWriteFailed(error)
        }
    }
}
