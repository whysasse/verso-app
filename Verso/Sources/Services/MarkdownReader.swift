import Foundation
import os.log

enum MarkdownReaderError: Error, LocalizedError {
    case invalidFrontmatter(String)
    case missingTitle(String)
    case fileReadFailed(Error)

    var errorDescription: String? {
        switch self {
        case .invalidFrontmatter(let msg):
            return "Invalid frontmatter: \(msg)"
        case .missingTitle(let filename):
            return "Missing required title in \(filename)"
        case .fileReadFailed(let underlying):
            return "Failed to read file: \(underlying.localizedDescription)"
        }
    }
}

struct MarkdownReader {

    private static let log = OSLog(subsystem: "com.fabiosasseron.verso", category: "MarkdownReader")

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    /// Reads all .md files in a directory, returning successfully parsed articles.
    /// Files that fail to parse are logged and skipped.
    static func readAll(from directoryURL: URL) -> [ParsedArticle] {
        let fm = FileManager.default
        guard let enumerator = fm.enumerator(at: directoryURL,
                                              includingPropertiesForKeys: nil,
                                              options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants]) else {
            os_log("Could not enumerate directory: %@", log: log, type: .error, directoryURL.path)
            return []
        }

        var articles: [ParsedArticle] = []
        for case let fileURL as URL in enumerator where fileURL.pathExtension == "md" {
            do {
                let article = try read(fileURL: fileURL)
                articles.append(article)
            } catch {
                os_log("Skipping %@: %@", log: log, type: .default, fileURL.lastPathComponent, error.localizedDescription)
            }
        }
        return articles
    }

    /// Reads a .md file from disk, parses YAML frontmatter, and returns a ParsedArticle.
    static func read(fileURL: URL) throws -> ParsedArticle {
        // 1. Read file
        let content: String
        do {
            content = try String(contentsOf: fileURL, encoding: .utf8)
        } catch {
            throw MarkdownReaderError.fileReadFailed(error)
        }

        // 2. Split on line-boundary --- delimiters to avoid splitting on horizontal rules in body
        let normalized = content.hasPrefix("---") ? content : "---\n" + content
        guard let frontmatterRange = extractFrontmatter(from: normalized) else {
            throw MarkdownReaderError.invalidFrontmatter("Expected opening and closing '---' delimiters in \(fileURL.lastPathComponent)")
        }

        let frontmatterRaw = frontmatterRange.frontmatter
        let body = frontmatterRange.body.trimmingCharacters(in: .whitespacesAndNewlines)

        // 3. Parse YAML lines
        var title: String?
        var url: URL?
        var status = Article.Status.unread
        var tags: [String]?
        var dateAdded: Date?

        let lines = frontmatterRaw.components(separatedBy: .newlines)
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { continue }

            if trimmed.hasPrefix("title:") {
                title = extractValue(from: trimmed, key: "title:")
            } else if trimmed.hasPrefix("url:") {
                if let raw = extractValue(from: trimmed, key: "url:"), let parsed = URL(string: raw) {
                    url = parsed
                }
            } else if trimmed.hasPrefix("status:") {
                let raw = trimmed.dropFirst("status:".count).trimmingCharacters(in: .whitespaces)
                if let s = Article.Status(rawValue: raw) {
                    status = s
                } else {
                    os_log("Invalid status '%@' in %@, defaulting to unread", log: log, type: .default, raw, fileURL.lastPathComponent)
                }
            } else if trimmed.hasPrefix("tags:") {
                tags = extractTagsArray(from: trimmed)
            } else if trimmed.hasPrefix("added:") {
                let raw = trimmed.dropFirst("added:".count).trimmingCharacters(in: .whitespaces)
                if let d = dateFormatter.date(from: raw) {
                    dateAdded = d
                } else {
                    os_log("Invalid date '%@' in %@, will use default", log: log, type: .default, raw, fileURL.lastPathComponent)
                }
            }
        }

        // 4. Validate required fields
        guard let finalTitle = title, !finalTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw MarkdownReaderError.missingTitle(fileURL.lastPathComponent)
        }

        // 5. Defaults for optional/missing fields
        let finalDateAdded: Date
        if let d = dateAdded {
            finalDateAdded = d
        } else {
            if let attrs = try? FileManager.default.attributesOfItem(atPath: fileURL.path),
               let creationDate = attrs[.creationDate] as? Date {
                finalDateAdded = creationDate
                os_log("Using file creation date for %@", log: log, type: .info, fileURL.lastPathComponent)
            } else {
                finalDateAdded = Date()
                os_log("No date found for %@, using now", log: log, type: .default, fileURL.lastPathComponent)
            }
        }

        return ParsedArticle(
            id: UUID(),
            filePath: fileURL,
            title: finalTitle,
            url: url,
            contentMarkdown: body,
            tags: tags,
            dateAdded: finalDateAdded,
            status: status
        )
    }

    // MARK: - Private Helpers

    private struct FrontmatterSplit {
        let frontmatter: String
        let body: String
    }

    /// Splits content into frontmatter and body by finding the closing `---` at a line boundary.
    /// The content is expected to start with `---\n`.
    private static func extractFrontmatter(from content: String) -> FrontmatterSplit? {
        // Content must start with ---
        guard content.hasPrefix("---") else { return nil }

        let lines = content.components(separatedBy: "\n")
        guard lines.count > 1 else { return nil }

        // Find the closing --- (line index > 0)
        guard let closingIndex = lines.indices.dropFirst().first(where: { lines[$0] == "---" }) else {
            return nil
        }

        let frontmatter = lines[1..<closingIndex].joined(separator: "\n")
        let body = lines[(closingIndex + 1)...].joined(separator: "\n")
        return FrontmatterSplit(frontmatter: frontmatter, body: body)
    }

    /// Extracts a value from a YAML line: handles quoted (`"value"`, `'value'`) and unquoted values.
    private static func extractValue(from line: String, key: String) -> String? {
        guard let keyRange = line.range(of: key) else { return nil }
        let afterKey = String(line[keyRange.upperBound...]).trimmingCharacters(in: .whitespaces)
        guard !afterKey.isEmpty else { return nil }

        // Quoted value
        if (afterKey.hasPrefix("\"") && afterKey.hasSuffix("\"")) ||
           (afterKey.hasPrefix("'") && afterKey.hasSuffix("'")) {
            var inner = String(afterKey.dropFirst().dropLast())
            inner = inner.replacingOccurrences(of: "\\\"", with: "\"")
            return inner.isEmpty ? nil : inner
        }

        // Unquoted value
        return afterKey.isEmpty ? nil : afterKey
    }

    /// Parses a YAML inline tags array: `tags: ["tag1", "tag2"]`.
    private static func extractTagsArray(from line: String) -> [String]? {
        guard let startBracket = line.firstIndex(of: "["),
              let endBracket = line.lastIndex(of: "]") else { return nil }

        let arrayContent = line[line.index(after: startBracket)..<endBracket]
        let rawTags = arrayContent.components(separatedBy: ",")

        let tags = rawTags.compactMap { tag -> String? in
            var cleaned = tag.trimmingCharacters(in: .whitespaces)
            guard !cleaned.isEmpty else { return nil }
            if (cleaned.hasPrefix("\"") && cleaned.hasSuffix("\"")) ||
               (cleaned.hasPrefix("'") && cleaned.hasSuffix("'")) {
                cleaned = String(cleaned.dropFirst().dropLast())
                cleaned = cleaned.replacingOccurrences(of: "\\\"", with: "\"")
            }
            return cleaned.isEmpty ? nil : cleaned
        }

        return tags.isEmpty ? nil : tags
    }
}
