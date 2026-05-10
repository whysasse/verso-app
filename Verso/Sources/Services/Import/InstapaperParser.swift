import Foundation

struct InstapaperParser: ImportFileParser {

    func canParse(_ url: URL) -> Bool {
        guard url.pathExtension.lowercased() == "csv" else { return false }
        guard let data = try? Data(contentsOf: url) else { return false }
        let rows = CSVParser.parse(data: data)
        guard let header = rows.first else { return false }
        // Instapaper CSV: URL, Title, Selection, Folder, Timestamp
        return header.contains("URL") && header.contains("Folder") && header.contains("Timestamp")
    }

    func parse(_ url: URL) throws -> [ParsedArticle] {
        guard let data = try? Data(contentsOf: url) else {
            throw ImportFileParserError.unreadableFile
        }
        let rows = CSVParser.parseWithHeaders(data: data)
        guard !rows.isEmpty else {
            throw ImportFileParserError.malformedData("No rows found in CSV")
        }
        return rows.compactMap { row -> ParsedArticle? in
            guard let rawURL = row["URL"], let articleURL = URL(string: rawURL),
                  let title = row["Title"], !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            else { return nil }
            let folder = row["Folder"] ?? "Unread"
            let status: Article.Status = folder.lowercased() == "archive" ? .read : .unread
            let dateAdded: Date
            if let tsStr = row["Timestamp"], let ts = Double(tsStr) {
                dateAdded = Date(timeIntervalSince1970: ts)
            } else {
                dateAdded = Date()
            }
            return ParsedArticle(
                id: nil,
                filePath: URL(fileURLWithPath: "/"),
                title: title,
                url: articleURL,
                contentMarkdown: "",
                tags: nil,
                scrollPosition: nil,
                dateAdded: dateAdded,
                status: status,
                author: nil,
                siteName: nil
            )
        }
    }
}
