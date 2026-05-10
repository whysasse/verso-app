import Foundation

struct MatterParser: ImportFileParser {

    func canParse(_ url: URL) -> Bool {
        guard url.pathExtension.lowercased() == "json" else { return false }
        guard let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data)
        else { return false }
        // Matter exports as a top-level array of feed entry objects with "content" dicts
        if let array = json as? [[String: Any]], let first = array.first {
            return first["content"] != nil || first["saved_at"] != nil
        }
        // Some Matter exports wrap in { "feed": [...] }
        if let dict = json as? [String: Any], dict["feed"] != nil {
            return true
        }
        return false
    }

    func parse(_ url: URL) throws -> [ParsedArticle] {
        guard let data = try? Data(contentsOf: url) else {
            throw ImportFileParserError.unreadableFile
        }
        let items: [[String: Any]]
        if let array = (try? JSONSerialization.jsonObject(with: data)) as? [[String: Any]] {
            items = array
        } else if let dict = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any],
                  let feed = dict["feed"] as? [[String: Any]] {
            items = feed
        } else {
            throw ImportFileParserError.malformedData("Unexpected JSON structure")
        }

        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let isoShort = ISO8601DateFormatter()

        return items.compactMap { item -> ParsedArticle? in
            let content = item["content"] as? [String: Any] ?? item
            guard let title = (content["title"] as? String) ?? (item["title"] as? String),
                  !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  let rawURL = (content["url"] as? String) ?? (item["url"] as? String),
                  let articleURL = URL(string: rawURL)
            else { return nil }

            let finishedAt = (item["finished_at"] as? String).flatMap { iso.date(from: $0) ?? isoShort.date(from: $0) }
            let status: Article.Status = finishedAt != nil ? .read : .unread

            let dateAdded: Date
            if let savedStr = (item["saved_at"] as? String) ?? (item["created_at"] as? String) {
                dateAdded = iso.date(from: savedStr) ?? isoShort.date(from: savedStr) ?? Date()
            } else {
                dateAdded = Date()
            }

            let tagsArr = (item["tags"] as? [String]) ?? (content["tags"] as? [String])
            let tags: [String]? = tagsArr?.isEmpty == false ? tagsArr : nil

            return ParsedArticle(
                id: nil,
                filePath: URL(fileURLWithPath: "/"),
                title: title,
                url: articleURL,
                contentMarkdown: "",
                tags: tags,
                dateAdded: dateAdded,
                status: status
            )
        }
    }
}
