import Foundation

struct GoodLinksParser: ImportFileParser {

    func canParse(_ url: URL) -> Bool {
        guard url.pathExtension.lowercased() == "json" else { return false }
        guard let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data)
        else { return false }

        if let dict = json as? [String: Any], dict["items"] != nil {
            return true
        }
        if let array = json as? [[String: Any]], Self.isNativeGoodLinksBookmarkArray(array) {
            return true
        }
        return false
    }

    func parse(_ url: URL) throws -> [ParsedArticle] {
        guard let data = try? Data(contentsOf: url) else {
            throw ImportFileParserError.unreadableFile
        }
        guard let root = try? JSONSerialization.jsonObject(with: data) else {
            throw ImportFileParserError.malformedData("Invalid JSON")
        }

        if let array = root as? [[String: Any]], Self.isNativeGoodLinksBookmarkArray(array) {
            return Self.mapNativeBookmarks(array)
        }

        if let dict = root as? [String: Any], dict["items"] != nil {
            if let items = dict["items"] as? [[String: Any]],
               !items.isEmpty,
               Self.isNativeGoodLinksBookmarkArray(items) {
                return Self.mapNativeBookmarks(items)
            }

            let export: GoodLinksExport
            do {
                export = try JSONDecoder().decode(GoodLinksExport.self, from: data)
            } catch {
                throw ImportFileParserError.malformedData(error.localizedDescription)
            }
            return Self.mapLegacyItems(export.items)
        }

        throw ImportFileParserError.malformedData("Unexpected GoodLinks JSON structure")
    }

    // MARK: - Native export (top-level array or { "items": [...] } with numeric `addedAt`)

    private static func isMatterBookmarkRow(_ row: [String: Any]) -> Bool {
        row["content"] != nil || row["saved_at"] != nil
    }

    private static func isJSONNumber(_ value: Any) -> Bool {
        switch value {
        case is Int, is Int64, is UInt, is Double, is Float, is NSNumber:
            return true
        default:
            return false
        }
    }

    /// GoodLinks app export: bookmarks include a numeric Unix `addedAt` and are not Matter feed rows.
    private static func isNativeGoodLinksBookmarkRow(_ row: [String: Any]) -> Bool {
        if isMatterBookmarkRow(row) { return false }
        guard let urlString = row["url"] as? String, URL(string: urlString) != nil else { return false }
        guard let addedAt = row["addedAt"], isJSONNumber(addedAt) else { return false }
        return true
    }

    private static func isNativeGoodLinksBookmarkArray(_ rows: [[String: Any]]) -> Bool {
        guard let first = rows.first else { return false }
        return isNativeGoodLinksBookmarkRow(first)
    }

    private static func dateFromAddedAt(_ value: Any?) -> Date? {
        guard let value else { return nil }
        if let n = value as? NSNumber {
            return Date(timeIntervalSince1970: n.doubleValue)
        }
        if let d = value as? Double {
            return Date(timeIntervalSince1970: d)
        }
        if let i = value as? Int {
            return Date(timeIntervalSince1970: TimeInterval(i))
        }
        return nil
    }

    private static func mapNativeBookmarks(_ rows: [[String: Any]]) -> [ParsedArticle] {
        rows.compactMap { row -> ParsedArticle? in
            guard let title = row["title"] as? String,
                  !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  let urlString = row["url"] as? String,
                  let articleURL = URL(string: urlString)
            else { return nil }

            let tags = (row["tags"] as? [String]) ?? []
            let dateAdded = dateFromAddedAt(row["addedAt"]) ?? Date()

            return ParsedArticle(
                id: nil,
                filePath: URL(fileURLWithPath: "/"),
                title: title,
                url: articleURL,
                contentMarkdown: "",
                tags: tags.isEmpty ? nil : tags,
                scrollPosition: nil,
                dateAdded: dateAdded,
                status: .unread,
                author: nil,
                siteName: nil
            )
        }
    }

    // MARK: - Legacy `{ "items": [...] }` with ISO `created_at` / `read_at`

    private static func mapLegacyItems(_ items: [GoodLinksItem]) -> [ParsedArticle] {
        items.compactMap { item -> ParsedArticle? in
            guard !item.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  let articleURL = URL(string: item.url)
            else { return nil }
            let status: Article.Status = item.readAt != nil ? .read : .unread
            return ParsedArticle(
                id: nil,
                filePath: URL(fileURLWithPath: "/"),
                title: item.title,
                url: articleURL,
                contentMarkdown: "",
                tags: item.tags.isEmpty ? nil : item.tags,
                scrollPosition: nil,
                dateAdded: item.createdAt ?? Date(),
                status: status,
                author: nil,
                siteName: nil
            )
        }
    }

    private struct GoodLinksExport: Decodable {
        let items: [GoodLinksItem]
    }

    private struct GoodLinksItem: Decodable {
        let title: String
        let url: String
        let tags: [String]
        let createdAt: Date?
        let readAt: Date?

        enum CodingKeys: String, CodingKey {
            case title, url, tags
            case createdAt = "created_at"
            case readAt = "read_at"
        }

        init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            title = try c.decodeIfPresent(String.self, forKey: .title) ?? ""
            url = try c.decodeIfPresent(String.self, forKey: .url) ?? ""
            tags = try c.decodeIfPresent([String].self, forKey: .tags) ?? []
            if let raw = try c.decodeIfPresent(String.self, forKey: .createdAt) {
                createdAt = Self.parseISO8601(raw)
            } else {
                createdAt = nil
            }
            if let raw = try c.decodeIfPresent(String.self, forKey: .readAt) {
                readAt = Self.parseISO8601(raw)
            } else {
                readAt = nil
            }
        }

        private static func parseISO8601(_ raw: String) -> Date? {
            let withFractional = ISO8601DateFormatter()
            withFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let d = withFractional.date(from: raw) { return d }
            let basic = ISO8601DateFormatter()
            return basic.date(from: raw)
        }
    }
}
