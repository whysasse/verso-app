import CoreData
import Foundation
import OSLog

private let logger = Logger(subsystem: "com.fabiosasseron.verso", category: "ingestion")
private let appGroupID = AppConstants.appGroupID

/// Runs on the main actor because it reads/writes `CoreDataStack.shared.persistentContainer.viewContext`,
/// which (like `ArticleLibraryService` and `ImportOrchestrator`) is confined to the main thread.
/// Without this, ingestion racing the UI's fetch on app launch / foreground caused sporadic
/// crashes reading `Article` properties mid-fault (FAB-291).
@MainActor
struct PendingArticleIngester {

    func ingest(folderURL: URL?, context: NSManagedObjectContext) async {
        guard let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) else {
            logger.warning("App group container unavailable — skipping ingestion")
            return
        }

        let pendingDir = container.appendingPathComponent("pending", isDirectory: true)

        guard let files = try? FileManager.default.contentsOfDirectory(
            at: pendingDir,
            includingPropertiesForKeys: nil
        ).filter({ $0.pathExtension == "json" }), !files.isEmpty else {
            return
        }

        guard let folderURL else {
            logger.info("No iCloud folder selected — \(files.count) pending article(s) held for later")
            return
        }

        let folderAccessed = folderURL.startAccessingSecurityScopedResource()
        defer { if folderAccessed { folderURL.stopAccessingSecurityScopedResource() } }

        for fileURL in files {
            do {
                let data = try Data(contentsOf: fileURL)
                let pending = try JSONDecoder().decode(PendingArticle.self, from: data)

                // FAB-296: ingest-time backstop. `duplicateResolution == nil` means the Share
                // Extension's own check either found nothing or never ran (e.g. a missing/stale
                // library bookmark at share time — see LibraryBookmarkResolver). The main app
                // normally has full folder access here, so re-check before writing. Per Fabio:
                // keep both articles rather than interrupt with a prompt at an arbitrary
                // launch/foreground moment — just flag the new one so it surfaces via the
                // existing tag filter.
                var backstopTags: [String]?
                if pending.duplicateResolution == nil,
                   let match = ArticleDuplicateFinder.findDuplicate(of: pending.url, libraryFolder: folderURL) {
                    backstopTags = ["Possible Duplicate"]
                    logger.info("Ingest-time duplicate backstop matched existing file: \(match.fileURL.lastPathComponent, privacy: .public) — keeping both, flagged")
                }

                let writtenURL = try await writeToDisk(pending: pending, folderURL: folderURL, tags: backstopTags)
                try upsertCoreData(pending: pending, filePath: writtenURL, tags: backstopTags, context: context)
                try FileManager.default.removeItem(at: fileURL)
                let duplicateResolutionKey: String = {
                    switch pending.duplicateResolution {
                    case .some(.replaceExisting): return "update"
                    case .some(.saveCopy): return "copy"
                    case .none: return backstopTags == nil ? "none" : "backstop_flagged"
                    }
                }()
                AnalyticsService.shared.track(
                    "article.saved",
                    parameters: ["source": "share_extension", "duplicate_resolution": duplicateResolutionKey]
                )
                logger.info("Ingested article: \(pending.title, privacy: .public)")
            } catch {
                logger.warning("Failed to ingest \(fileURL.lastPathComponent, privacy: .public): \(error.localizedDescription, privacy: .public)")
            }
        }
    }

    // MARK: - Private

    private func writeToDisk(pending: PendingArticle, folderURL: URL, tags: [String]?) async throws -> URL {
        let parsed = ParsedArticle(
            id: pending.id,
            filePath: folderURL, // placeholder; MarkdownWriter uses directory for new writes only
            title: pending.title,
            url: pending.url,
            contentMarkdown: pending.contentMarkdown,
            tags: tags,
            scrollPosition: nil,
            dateAdded: pending.dateAdded,
            status: .unread,
            author: pending.author,
            siteName: pending.siteName
        )
        if case .replaceExisting(let pathStr) = pending.duplicateResolution {
            let fileURL = URL(fileURLWithPath: pathStr)
            try await MarkdownWriter.replaceArticle(at: fileURL, incoming: parsed, libraryRoot: folderURL)
            return fileURL
        }
        return try await MarkdownWriter.write(article: parsed, to: folderURL)
    }

    private func upsertCoreData(pending: PendingArticle, filePath: URL, tags: [String]?, context: NSManagedObjectContext) throws {
        if case .replaceExisting(let pathStr) = pending.duplicateResolution {
            let request = NSFetchRequest<Article>(entityName: "Article")
            request.predicate = NSPredicate(format: "filePath == %@", pathStr)
            request.fetchLimit = 1
            if let existing = try context.fetch(request).first {
                existing.title = pending.title
                existing.url = pending.url
                existing.author = pending.author
                existing.siteName = pending.siteName
                existing.searchableBody = ArticlePlainText.fromMarkdown(pending.contentMarkdown)
                existing.source = pending.url.host
                let refreshed = try MarkdownReader.read(fileURL: filePath)
                existing.statusEnum = refreshed.status
                existing.archived = refreshed.archived
                existing.archivedAt = refreshed.archivedAt
                if let sp = refreshed.scrollPosition {
                    existing.scrollPosition = NSNumber(value: sp)
                } else {
                    existing.scrollPosition = nil
                }
                existing.tagsSerialized = Article.makeTagsSerialized(from: refreshed.tags)
                try context.save()
                return
            }
        }

        // FAB-296: guard double-ingest of the same pending JSON (e.g. a prior run that wrote
        // the file and upserted Core Data but was interrupted before deleting the pending JSON)
        // from inserting a second `Article` row for the same file.
        let existingRequest = NSFetchRequest<Article>(entityName: "Article")
        existingRequest.predicate = NSPredicate(format: "filePath == %@", filePath.path)
        existingRequest.fetchLimit = 1
        if let existing = try context.fetch(existingRequest).first {
            existing.title = pending.title
            existing.url = pending.url
            existing.author = pending.author
            existing.siteName = pending.siteName
            existing.searchableBody = ArticlePlainText.fromMarkdown(pending.contentMarkdown)
            existing.source = pending.url.host
            existing.tagsSerialized = Article.makeTagsSerialized(from: tags)
            try context.save()
            return
        }

        let article = Article(context: context)
        article.id = pending.id
        article.title = pending.title
        article.url = pending.url
        article.filePath = filePath.path
        article.status = Article.Status.unread.rawValue
        article.dateAdded = pending.dateAdded
        article.author = pending.author
        article.siteName = pending.siteName
        article.searchableBody = ArticlePlainText.fromMarkdown(pending.contentMarkdown)
        article.source = pending.url.host
        // FAB-296: previously never set on the fresh-insert path (dead until now, since `tags`
        // was always nil here) — needed now so a backstop-flagged article's tag is visible
        // immediately via the tag filter, not just after the next full cache rebuild.
        article.tagsSerialized = Article.makeTagsSerialized(from: tags)
        try context.save()
    }
}
