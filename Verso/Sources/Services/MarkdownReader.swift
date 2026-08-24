import Foundation
import os.log

enum MarkdownReaderError: Error, LocalizedError {
    case fileReadFailed(Error)

    var errorDescription: String? {
        switch self {
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
        // Fixed-format storage value: pin to POSIX so a non-Gregorian device calendar or
        // localized digits can never corrupt parsing of the on-disk frontmatter. See docs/LOCALIZATION.md §3.
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    /// Reads all .md files in a directory, returning successfully parsed articles. Every `.md` file
    /// is a candidate article now (FAB-290) -- a file only fails to parse (logged and skipped) if
    /// it can't be read from disk at all (`.fileReadFailed`), not for missing/invalid frontmatter.
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

        // 2. Split on line-boundary --- delimiters to avoid splitting on horizontal rules in body.
        // A file with no opening/closing `---` pair at all -- including one with no frontmatter
        // whatsoever -- is graceful-degraded per docs/OBSIDIAN_INTEGRATION.md §9: the whole file
        // becomes the article body instead of being skipped (FAB-290).
        let normalized = content.hasPrefix("---") ? content : "---\n" + content
        let frontmatterRange = extractFrontmatter(from: normalized)
        let hadFrontmatter = frontmatterRange != nil
        let frontmatterRaw = frontmatterRange?.frontmatter ?? ""
        let body = (frontmatterRange?.body ?? content).trimmingCharacters(in: .whitespacesAndNewlines)

        // 3. Parse YAML lines
        var title: String?
        var url: URL?
        var status = Article.Status.unread
        var tags: [String]?
        var dateAdded: Date?
        var author: String?
        var siteName: String?
        var scrollPosition: Double?
        // Keys Verso doesn't recognize (e.g. Obsidian's `aliases`, `cssclass`, a personal `tags`
        // scheme), kept verbatim so a later adoption commit can merge them back in rather than
        // silently dropping another tool's fields (FAB-290; see MarkdownWriter.adoptIfNeeded).
        var unrecognizedLines: [String] = []

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
            } else if trimmed.hasPrefix("author:") {
                author = Self.extractValue(from: trimmed, key: "author:")?
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            } else if trimmed.hasPrefix("site_name:") {
                siteName = Self.extractValue(from: trimmed, key: "site_name:")?
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            } else if trimmed.hasPrefix("scroll_position:") {
                let raw = trimmed.dropFirst("scroll_position:".count).trimmingCharacters(in: .whitespaces)
                scrollPosition = Double(raw)
            } else {
                unrecognizedLines.append(line)
            }
        }

        // 4. Missing/empty title -> fall back to the filename (FAB-290; previously threw
        // .missingTitle and the file was skipped, contradicting the graceful-degradation this
        // docs/OBSIDIAN_INTEGRATION.md §9 already promised).
        let needsAdoption: Bool
        let finalTitle: String
        if let title, !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            finalTitle = title
            needsAdoption = !hadFrontmatter
        } else {
            finalTitle = synthesizedTitle(from: fileURL)
            needsAdoption = true
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

        let authorTrimmed = author?.trimmingCharacters(in: .whitespacesAndNewlines)
        let siteTrimmed = siteName?.trimmingCharacters(in: .whitespacesAndNewlines)

        return ParsedArticle(
            id: UUID(),
            filePath: fileURL,
            title: finalTitle,
            url: url,
            contentMarkdown: body,
            tags: tags,
            scrollPosition: scrollPosition,
            dateAdded: finalDateAdded,
            status: status,
            author: (authorTrimmed?.isEmpty == false) ? authorTrimmed : nil,
            siteName: (siteTrimmed?.isEmpty == false) ? siteTrimmed : nil,
            needsAdoption: needsAdoption,
            unrecognizedFrontmatterLines: unrecognizedLines
        )
    }

    /// Filename-derived fallback title for a file with no `title` key (or no frontmatter at all):
    /// the filename without its extension, minus a leading `YYYY-MM-DD ` date prefix if present.
    /// e.g. "2026-04-19 The Future of Reading Apps.md" -> "The Future of Reading Apps";
    /// "meeting-notes.md" -> "meeting-notes".
    static func synthesizedTitle(from fileURL: URL) -> String {
        let base = fileURL.deletingPathExtension().lastPathComponent
        guard let regex = try? NSRegularExpression(pattern: #"^\d{4}-\d{2}-\d{2} "#) else { return base }
        let range = NSRange(base.startIndex..., in: base)
        guard let match = regex.firstMatch(in: base, options: [], range: range), match.range.location == 0 else {
            return base
        }
        return (base as NSString).substring(from: match.range.length)
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
