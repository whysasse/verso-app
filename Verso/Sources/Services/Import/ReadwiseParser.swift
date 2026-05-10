import Foundation

struct ReadwiseParser: ImportFileParser {

    func canParse(_ url: URL) -> Bool {
        guard url.pathExtension.lowercased() == "csv" else { return false }
        guard let data = try? Data(contentsOf: url) else { return false }
        let rows = CSVParser.parse(data: data)
        guard let header = rows.first else { return false }
        // Readwise Reader CSV has a "Reading progress" or "Document tags" column
        return header.contains("Reading progress") || header.contains("Document tags")
    }

    func parse(_ url: URL) throws -> [ParsedArticle] {
        guard let data = try? Data(contentsOf: url) else {
            throw ImportFileParserError.unreadableFile
        }
        let rows = CSVParser.parseWithHeaders(data: data)
        guard !rows.isEmpty else {
            throw ImportFileParserError.malformedData("No rows found in CSV")
        }

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let isoFormatterShort = ISO8601DateFormatter()

        return rows.compactMap { row -> ParsedArticle? in
            guard let title = row["Title"], !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  let rawURL = row["URL"] ?? row["Source URL"], let articleURL = URL(string: rawURL)
            else { return nil }

            let status: Article.Status
            if let progressStr = row["Reading progress"], let progress = Double(progressStr) {
                if progress >= 0.9 {
                    status = .read
                } else if progress > 0 {
                    status = .reading
                } else {
                    status = .unread
                }
            } else {
                status = .unread
            }

            let dateAdded: Date
            if let savedDate = row["Saved date"] ?? row["Highlighted at"] {
                dateAdded = isoFormatter.date(from: savedDate) ?? isoFormatterShort.date(from: savedDate) ?? Date()
            } else {
                dateAdded = Date()
            }

            let tagsStr = row["Document tags"] ?? ""
            let tags: [String]? = tagsStr.isEmpty ? nil : tagsStr.split(separator: ",").map {
                $0.trimmingCharacters(in: .whitespaces)
            }.filter { !$0.isEmpty }

            return ParsedArticle(
                id: nil,
                filePath: URL(fileURLWithPath: "/"),
                title: title,
                url: articleURL,
                contentMarkdown: "",
                tags: tags,
                scrollPosition: nil,
                dateAdded: dateAdded,
                status: status,
                author: nil,
                siteName: nil
            )
        }
    }
}
