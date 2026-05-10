import Foundation
import SwiftSoup

struct PocketParser: ImportFileParser {

    func canParse(_ url: URL) -> Bool {
        guard url.pathExtension.lowercased() == "html" else { return false }
        guard let text = try? String(contentsOf: url, encoding: .utf8) else { return false }
        return text.contains("Pocket") || text.contains("getpocket.com")
    }

    func parse(_ url: URL) throws -> [ParsedArticle] {
        guard let text = try? String(contentsOf: url, encoding: .utf8) else {
            throw ImportFileParserError.unreadableFile
        }
        let doc: Document
        do {
            doc = try SwiftSoup.parse(text)
        } catch {
            throw ImportFileParserError.malformedData(error.localizedDescription)
        }

        var articles: [ParsedArticle] = []

        // Pocket export has two <H3> sections: "Unread List" and "Read Archive"
        // Each followed by a <DL> containing <DT><A ...> entries
        let sections = try doc.select("h3")
        for section in sections {
            let sectionTitle = try section.text().lowercased()
            let isRead = sectionTitle.contains("read archive") || sectionTitle.contains("archive")

            // The DL immediately follows the H3
            var sibling = try? section.nextElementSibling()
            while let el = sibling, el.tagName() != "dl" {
                sibling = try? el.nextElementSibling()
            }
            guard let dl = sibling else { continue }

            let links = try dl.select("a")
            for link in links {
                let href = try link.attr("href")
                let title = try link.text()
                let timeAdded = try link.attr("time_added")
                let tagsStr = try link.attr("tags")

                guard !href.isEmpty, let articleURL = URL(string: href) else { continue }
                let displayTitle = title.isEmpty ? href : title
                let dateAdded: Date
                if let ts = Double(timeAdded) {
                    dateAdded = Date(timeIntervalSince1970: ts)
                } else {
                    dateAdded = Date()
                }
                let tags: [String]? = tagsStr.isEmpty ? nil : tagsStr.split(separator: ",").map {
                    $0.trimmingCharacters(in: .whitespaces)
                }.filter { !$0.isEmpty }

                articles.append(ParsedArticle(
                    id: nil,
                    filePath: URL(fileURLWithPath: "/"),
                    title: displayTitle,
                    url: articleURL,
                    contentMarkdown: "",
                    tags: tags,
                    dateAdded: dateAdded,
                    status: isRead ? .read : .unread,
                    author: nil,
                    siteName: nil
                ))
            }
        }

        // Fallback: if no <H3> sections found, treat all links as unread
        if articles.isEmpty {
            let links = try doc.select("a[href]")
            for link in links {
                let href = try link.attr("href")
                let title = try link.text()
                guard !href.isEmpty, let articleURL = URL(string: href),
                      articleURL.scheme == "http" || articleURL.scheme == "https"
                else { continue }
                articles.append(ParsedArticle(
                    id: nil,
                    filePath: URL(fileURLWithPath: "/"),
                    title: title.isEmpty ? href : title,
                    url: articleURL,
                    contentMarkdown: "",
                    tags: nil,
                    dateAdded: Date(),
                    status: .unread,
                    author: nil,
                    siteName: nil
                ))
            }
        }

        return articles
    }
}
