import Foundation

/// Represents a parsed article that has not yet been written to disk.
/// Shared between the main app and Share Extension targets.
struct PendingArticle: Codable {
    let id: UUID
    let url: URL
    let title: String
    let contentMarkdown: String
    let dateAdded: Date
}
