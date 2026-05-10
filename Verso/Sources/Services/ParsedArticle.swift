import Foundation

struct ParsedArticle {
    let id: UUID?
    let filePath: URL
    let title: String
    let url: URL?
    let contentMarkdown: String
    let tags: [String]?
    /// Normalized scroll depth in the article body (0...1), persisted in frontmatter.
    let scrollPosition: Double?
    let dateAdded: Date
    let status: Article.Status
    let author: String?
    let siteName: String?
}
