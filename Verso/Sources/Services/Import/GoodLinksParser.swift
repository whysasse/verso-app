import Foundation

struct GoodLinksParser: ImportFileParser {

    func canParse(_ url: URL) -> Bool {
        guard url.pathExtension.lowercased() == "json" else { return false }
        guard let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return false }
        return json["items"] != nil
    }

    func parse(_ url: URL) throws -> [ParsedArticle] {
        guard let data = try? Data(contentsOf: url) else {
            throw ImportFileParserError.unreadableFile
        }
        let export: GoodLinksExport
        do {
            export = try JSONDecoder().decode(GoodLinksExport.self, from: data)
        } catch {
            throw ImportFileParserError.malformedData(error.localizedDescription)
        }
        return export.items.compactMap { item -> ParsedArticle? in
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
                dateAdded: item.createdAt ?? Date(),
                status: status
            )
        }
    }

    // MARK: - Decodable models

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
            let iso = ISO8601DateFormatter()
            if let raw = try c.decodeIfPresent(String.self, forKey: .createdAt) {
                createdAt = iso.date(from: raw)
            } else {
                createdAt = nil
            }
            if let raw = try c.decodeIfPresent(String.self, forKey: .readAt) {
                readAt = iso.date(from: raw)
            } else {
                readAt = nil
            }
        }
    }
}
