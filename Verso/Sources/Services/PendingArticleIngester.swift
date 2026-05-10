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
                let writtenURL = try writeToDisk(pending: pending, folderURL: folderURL)
                try insertIntoCoreData(pending: pending, filePath: writtenURL, context: context)
                try FileManager.default.removeItem(at: fileURL)
                AnalyticsService.shared.track("article.saved", parameters: ["source": "share_extension"])
                logger.info("Ingested article: \(pending.title, privacy: .public)")
            } catch {
                logger.warning("Failed to ingest \(fileURL.lastPathComponent, privacy: .public): \(error.localizedDescription, privacy: .public)")
            }
        }
    }

    // MARK: - Private

    private func writeToDisk(pending: PendingArticle, folderURL: URL) throws -> URL {
        let parsed = ParsedArticle(
            id: pending.id,
            filePath: folderURL, // placeholder; MarkdownWriter uses this for collision-checking only
            title: pending.title,
            url: pending.url,
            contentMarkdown: pending.contentMarkdown,
            tags: nil,
            dateAdded: pending.dateAdded,
            status: .unread,
            author: pending.author,
            siteName: pending.siteName
        )
        return try MarkdownWriter.write(article: parsed, to: folderURL)
    }

    private func insertIntoCoreData(pending: PendingArticle, filePath: URL, context: NSManagedObjectContext) throws {
        let article = Article(context: context)
        article.id = pending.id
        article.title = pending.title
        article.url = pending.url
        article.filePath = filePath.path
        article.status = Article.Status.unread.rawValue
        article.dateAdded = pending.dateAdded
        article.author = pending.author
        article.siteName = pending.siteName
        try context.save()
    }
}
