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
    /// Whether the article is archived (FAB-297), orthogonal to `status`. Mirrored to frontmatter
    /// `archived: true` / `archived_at:`.
    let archived: Bool
    let archivedAt: Date?
    /// True when this file was adopted from a manually-added/foreign note that had no frontmatter,
    /// or frontmatter with no `title` key -- `title`/`dateAdded`/etc. above are synthesized
    /// defaults, not yet written to disk. `MarkdownWriter.adoptIfNeeded` uses this to know whether
    /// the next write-back should perform the one-time adopt-and-rename (FAB-290).
    let needsAdoption: Bool
    /// Frontmatter YAML lines Verso doesn't recognize (e.g. Obsidian's `aliases`, `cssclass`),
    /// preserved verbatim so an adoption commit can merge them back in rather than dropping them.
    let unrecognizedFrontmatterLines: [String]

    init(
        id: UUID?,
        filePath: URL,
        title: String,
        url: URL?,
        contentMarkdown: String,
        tags: [String]?,
        scrollPosition: Double?,
        dateAdded: Date,
        status: Article.Status,
        author: String?,
        siteName: String?,
        needsAdoption: Bool = false,
        unrecognizedFrontmatterLines: [String] = [],
        archived: Bool = false,
        archivedAt: Date? = nil
    ) {
        self.id = id
        self.filePath = filePath
        self.title = title
        self.url = url
        self.contentMarkdown = contentMarkdown
        self.tags = tags
        self.scrollPosition = scrollPosition
        self.dateAdded = dateAdded
        self.status = status
        self.author = author
        self.siteName = siteName
        self.needsAdoption = needsAdoption
        self.unrecognizedFrontmatterLines = unrecognizedFrontmatterLines
        self.archived = archived
        self.archivedAt = archivedAt
    }
}
