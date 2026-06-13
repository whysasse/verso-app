import Foundation

/// First match when an article with the same canonical source URL already exists on disk.
struct ArticleDuplicateMatch: Equatable {
    let fileURL: URL
    let existingTitle: String
}

/// Scans library Markdown files for `url:` frontmatter matching `sourceURL` (canonical comparison).
enum ArticleDuplicateFinder {

    /// Returns the first `.md` in the library root or `Archive/` whose frontmatter `url:` matches `sourceURL`.
    static func findDuplicate(of sourceURL: URL, libraryFolder: URL) -> ArticleDuplicateMatch? {
        let key = VersoArticleURL.canonicalKey(for: sourceURL)
        if let m = scanDirectory(libraryFolder, sourceKey: key) { return m }
        let archive = libraryFolder.appendingPathComponent("Archive", isDirectory: true)
        var isDir: ObjCBool = false
        guard FileManager.default.fileExists(atPath: archive.path, isDirectory: &isDir), isDir.boolValue else {
            return nil
        }
        return scanDirectory(archive, sourceKey: key)
    }

    private static func scanDirectory(_ directoryURL: URL, sourceKey: String) -> ArticleDuplicateMatch? {
        let fm = FileManager.default
        guard let enumerator = fm.enumerator(
            at: directoryURL,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants]
        ) else { return nil }

        for case let fileURL as URL in enumerator where fileURL.pathExtension.lowercased() == "md" {
            guard let parsed = readFrontmatterURLAndTitle(fileURL: fileURL),
                  let fileURLFromYAML = parsed.url,
                  VersoArticleURL.canonicalKey(for: fileURLFromYAML) == sourceKey else { continue }
            return ArticleDuplicateMatch(fileURL: fileURL, existingTitle: parsed.title)
        }
        return nil
    }

    private struct FrontmatterURLTitle {
        let url: URL?
        let title: String
    }

    private static func readFrontmatterURLAndTitle(fileURL: URL) -> FrontmatterURLTitle? {
        let raw: String
        do {
            raw = try String(contentsOf: fileURL, encoding: .utf8)
        } catch {
            return nil
        }
        let normalized = raw.hasPrefix("---") ? raw : "---\n" + raw
        let lines = normalized.components(separatedBy: "\n")
        guard lines.count > 1 else { return nil }
        guard lines[0].trimmingCharacters(in: .whitespaces) == "---" else { return nil }
        guard let closingIndex = lines.indices.dropFirst().first(where: { lines[$0] == "---" }) else { return nil }
        let frontmatter = lines[1..<closingIndex].joined(separator: "\n")

        var url: URL?
        var title = fileURL.deletingPathExtension().lastPathComponent
        for line in frontmatter.components(separatedBy: .newlines) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("url:") {
                if let rawURL = extractYAMLValue(from: trimmed, key: "url:"), let u = URL(string: rawURL) {
                    url = u
                }
            } else if trimmed.hasPrefix("title:") {
                if let rawTitle = extractYAMLValue(from: trimmed, key: "title:"), !rawTitle.isEmpty {
                    title = rawTitle
                }
            }
        }
        return FrontmatterURLTitle(url: url, title: title)
    }

    private static func extractYAMLValue(from line: String, key: String) -> String? {
        guard let keyRange = line.range(of: key) else { return nil }
        let afterKey = String(line[keyRange.upperBound...]).trimmingCharacters(in: .whitespaces)
        guard !afterKey.isEmpty else { return nil }
        if (afterKey.hasPrefix("\"") && afterKey.hasSuffix("\"")) || (afterKey.hasPrefix("'") && afterKey.hasSuffix("'")) {
            var inner = String(afterKey.dropFirst().dropLast())
            inner = inner.replacingOccurrences(of: "\\\"", with: "\"")
            return inner.isEmpty ? nil : inner
        }
        return afterKey
    }
}
