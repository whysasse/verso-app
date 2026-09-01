import Foundation

/// First match when an article with the same canonical source URL already exists on disk.
struct ArticleDuplicateMatch: Equatable {
    let fileURL: URL
    let existingTitle: String
}

/// Scans library Markdown files for `url:` frontmatter matching `sourceURL` (canonical comparison).
/// FAB-296: scans the whole library tree recursively, not just the root and `Archive/`.
enum ArticleDuplicateFinder {

    /// Returns the first `.md` anywhere under `libraryFolder` (root, `Archive/`, or any nested
    /// subfolder — FAB-296) whose frontmatter `url:` matches `sourceURL`.
    static func findDuplicate(of sourceURL: URL, libraryFolder: URL) -> ArticleDuplicateMatch? {
        let key = VersoArticleURL.canonicalKey(for: sourceURL)
        return scanDirectory(libraryFolder, sourceKey: key)
    }

    /// Recursive (FAB-296: was `.skipsSubdirectoryDescendants`, so an article in any subfolder
    /// besides the library root was invisible to the check). `.media` sidecar folders never
    /// contain `.md` files — only downloaded images — so they're pruned rather than descended.
    private static func scanDirectory(_ directoryURL: URL, sourceKey: String) -> ArticleDuplicateMatch? {
        let fm = FileManager.default
        guard let enumerator = fm.enumerator(
            at: directoryURL,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else { return nil }

        for case let fileURL as URL in enumerator {
            let isDirectory = (try? fileURL.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory ?? false
            if isDirectory {
                if fileURL.pathExtension.lowercased() == "media" {
                    enumerator.skipDescendants()
                }
                continue
            }
            guard fileURL.pathExtension.lowercased() == "md" else { continue }
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
