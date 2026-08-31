import Foundation
import CoreData
import os.log

@MainActor
final class ArticleLibraryService: ObservableObject {
    private static let log = OSLog(subsystem: "com.fabiosasseron.verso", category: "ArticleLibraryService")

    @Published private(set) var isRebuilding = false

    /// Scans the folder for .md files, upserts them into Core Data, and removes stale records.
    func rebuildCache(from folderURL: URL, context: NSManagedObjectContext) async {
        guard !isRebuilding else { return }
        isRebuilding = true
        defer { isRebuilding = false }

        let mainArticles = await Task.detached(priority: .userInitiated) {
            MarkdownReader.readAll(from: folderURL)
        }.value
        let archiveDir = folderURL.appendingPathComponent("Archive", isDirectory: true)
        let archivedArticles = await Task.detached(priority: .userInitiated) {
            MarkdownReader.readAll(from: archiveDir)
        }.value
        let parsedArticles = mainArticles + archivedArticles

        let filePaths = Set(parsedArticles.map { $0.filePath.path })

        do {
            // Fetch all existing articles once
            let fetchRequest = NSFetchRequest<Article>(entityName: "Article")
            let existing = try context.fetch(fetchRequest)
            let existingByPath = Dictionary(uniqueKeysWithValues: existing.map { ($0.filePath, $0) })

            // Upsert parsed articles
            for parsed in parsedArticles {
                let path = parsed.filePath.path
                if let article = existingByPath[path] {
                    article.title = parsed.title
                    article.url = parsed.url
                    article.author = parsed.author
                    article.siteName = parsed.siteName
                    article.statusEnum = parsed.status
                    article.archived = parsed.archived
                    article.archivedAt = parsed.archivedAt
                    article.searchableBody = ArticlePlainText.fromMarkdown(parsed.contentMarkdown)
                    article.tagsSerialized = Article.makeTagsSerialized(from: parsed.tags)
                    if let sp = parsed.scrollPosition {
                        article.scrollPosition = NSNumber(value: sp)
                    } else {
                        article.scrollPosition = nil
                    }
                } else {
                    _ = Article.create(
                        in: context,
                        id: parsed.id ?? UUID(),
                        filePath: path,
                        title: parsed.title,
                        url: parsed.url,
                        status: parsed.status,
                        dateAdded: parsed.dateAdded,
                        author: parsed.author,
                        siteName: parsed.siteName,
                        scrollPosition: parsed.scrollPosition.map { NSNumber(value: $0) },
                        tagsSerialized: Article.makeTagsSerialized(from: parsed.tags),
                        searchableBody: ArticlePlainText.fromMarkdown(parsed.contentMarkdown),
                        archived: parsed.archived,
                        archivedAt: parsed.archivedAt
                    )
                }
            }

            // Remove records whose files no longer exist on disk
            for article in existing where !filePaths.contains(article.filePath) {
                context.delete(article)
            }

            if context.hasChanges {
                try context.save()
                os_log("Cache rebuild complete: %d articles", log: Self.log, type: .info, parsedArticles.count)
            }
        } catch {
            os_log("Cache rebuild failed: %@", log: Self.log, type: .error, error.localizedDescription)
        }
    }
}
