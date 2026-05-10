import Foundation

protocol ImportFileParser {
    func canParse(_ url: URL) -> Bool
    func parse(_ url: URL) throws -> [ParsedArticle]
}

enum ImportFileParserError: Error, LocalizedError {
    case unsupportedFormat
    case unreadableFile
    case malformedData(String)

    var errorDescription: String? {
        switch self {
        case .unsupportedFormat:
            return "This file format is not supported. Please export from GoodLinks, Instapaper, Pocket, Readwise Reader, or Matter."
        case .unreadableFile:
            return "Could not read the selected file."
        case .malformedData(let detail):
            return "The file could not be parsed: \(detail)"
        }
    }
}

enum ImportFormatDetector {
    private static let parsers: [ImportFileParser] = [
        GoodLinksParser(),
        MatterParser(),
        ReadwiseParser(),
        InstapaperParser(),
        PocketParser(),
    ]

    static func parser(for url: URL) throws -> ImportFileParser {
        guard let parser = parsers.first(where: { $0.canParse(url) }) else {
            throw ImportFileParserError.unsupportedFormat
        }
        return parser
    }
}

// MARK: - CSV helpers (shared by CSV-based parsers)

enum CSVParser {
    static func parse(data: Data) -> [[String]] {
        guard let text = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .isoLatin1) else {
            return []
        }
        var rows: [[String]] = []
        var currentRow: [String] = []
        var currentField = ""
        var inQuotes = false
        var i = text.startIndex

        while i < text.endIndex {
            let c = text[i]
            let next = text.index(after: i)

            if inQuotes {
                if c == "\"" {
                    if next < text.endIndex && text[next] == "\"" {
                        currentField.append("\"")
                        i = text.index(after: next)
                        continue
                    } else {
                        inQuotes = false
                    }
                } else {
                    currentField.append(c)
                }
            } else {
                if c == "\"" {
                    inQuotes = true
                } else if c == "," {
                    currentRow.append(currentField)
                    currentField = ""
                } else if c == "\n" || (c == "\r" && (next >= text.endIndex || text[next] != "\n")) {
                    currentRow.append(currentField)
                    currentField = ""
                    if !currentRow.isEmpty {
                        rows.append(currentRow)
                    }
                    currentRow = []
                } else if c == "\r" {
                    // skip \r when followed by \n (handled on next iteration)
                } else {
                    currentField.append(c)
                }
            }
            i = next
        }

        // flush trailing field/row
        if !currentField.isEmpty || !currentRow.isEmpty {
            currentRow.append(currentField)
            rows.append(currentRow)
        }

        return rows
    }

    static func parseWithHeaders(data: Data) -> [[String: String]] {
        let rows = parse(data: data)
        guard rows.count >= 2 else { return [] }
        let headers = rows[0]
        return rows.dropFirst().compactMap { row -> [String: String]? in
            guard row.count == headers.count else { return nil }
            var dict: [String: String] = [:]
            for (index, header) in headers.enumerated() {
                dict[header] = row[index]
            }
            return dict
        }
    }
}
