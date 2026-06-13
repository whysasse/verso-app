import Foundation

/// Represents a parsed article that has not yet been written to disk.
/// Shared between the main app and Share Extension targets.
struct PendingArticle: Codable, Equatable {
    let id: UUID
    let url: URL
    var title: String
    let contentMarkdown: String
    let dateAdded: Date
    /// Readability-byline-style author attribution when known.
    var author: String?
    /// Site / publication label (e.g. Readability `siteName`).
    var siteName: String?
    /// Set when the user resolves a duplicate URL (Share extension / in-app add).
    var duplicateResolution: DuplicateSaveResolution?

    init(
        id: UUID,
        url: URL,
        title: String,
        contentMarkdown: String,
        dateAdded: Date,
        author: String? = nil,
        siteName: String? = nil,
        duplicateResolution: DuplicateSaveResolution? = nil
    ) {
        self.id = id
        self.url = url
        self.title = title
        self.contentMarkdown = contentMarkdown
        self.dateAdded = dateAdded
        self.author = author
        self.siteName = siteName
        self.duplicateResolution = duplicateResolution
    }
}
