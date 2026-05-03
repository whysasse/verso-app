import Foundation

struct ParsedArticle {
    let title: String
    let url: URL?
    let contentMarkdown: String
    let tags: [String]?
    let dateAdded: Date
    let status: Article.Status
}
