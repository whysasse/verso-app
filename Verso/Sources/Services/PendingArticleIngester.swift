import CoreData
import Foundation
import OSLog

private let logger = Logger(subsystem: "com.fabiosasseron.verso", category: "ingestion")
private let appGroupID = AppConstants.appGroupID

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
                let writtenURL = try await writeToDisk(pending: pending, folderURL: folderURL)
                try upsertCoreData(pending: pending, filePath: writtenURL, context: context)
                try FileManager.default.removeItem(at: fileURL)
                let duplicateResolutionKey: String = {
                    switch pending.duplicateResolution {
                    case .some(.replaceExisting): return "update"
                    case .some(.saveCopy): return "copy"
                    case .none: return "none"
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

    private func writeToDisk(pending: PendingArticle, folderURL: URL) async throws -> URL {
        let parsed = ParsedArticle(
            id: pending.id,
            filePath: folderURL, // placeholder; MarkdownWriter uses directory for new writes only
            title: pending.title,
            url: pending.url,
            contentMarkdown: pending.contentMarkdown,
            tags: nil,
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

    private func upsertCoreData(pending: PendingArticle, filePath: URL, context: NSManagedObjectContext) throws {
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
        try context.save()
    }
}
