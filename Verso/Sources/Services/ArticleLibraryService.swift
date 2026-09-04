import Foundation
import CoreData
import os.log

@MainActor
final class ArticleLibraryService: ObservableObject {
    private static let log = OSLog(subsystem: "com.fabiosasseron.verso", category: "ArticleLibraryService")

    @Published private(set) var isRebuilding = false

    /// Scans the folder for .md files, upserts them into Core Data, and removes stale records.
    ///
    /// FAB-304 (cause 3): unlike every other file-touching call site (`PendingArticleIngester`,
    /// `ArticleReaderView`'s persist helpers), this used to assume security-scoped access to
    /// `folderURL` was already open rather than bracketing its own. `VersoApp` stops access on
    /// `scenePhase == .background` and never restarts it on `.active` before calling this, so from
    /// the first backgrounding of a session onward, every later rebuild raced whatever unrelated
    /// bracket elsewhere happened to still be open. Losing that race made `MarkdownReader.readAll`
    /// return zero files, which the stale-record cleanup below then read as "the user deleted
    /// everything" and wiped the entire cache — surfacing as a spurious "No articles yet" empty
    /// state, fixed only by relaunching (which re-runs `FolderBookmarkService.restore()`).
    /// Bracketing access here, the same way every sibling call site already does, makes this
    /// self-sufficient instead of dependent on ambient state set up elsewhere.
    func rebuildCache(from folderURL: URL, context: NSManagedObjectContext) async {
        guard !isRebuilding else { return }
        isRebuilding = true
        defer { isRebuilding = false }

        let accessed = folderURL.startAccessingSecurityScopedResource()
        defer { if accessed { folderURL.stopAccessingSecurityScopedResource() } }

        // FAB-304 (cause 4): the scan below (`Task.detached`) can take real wall-clock time --
        // scanning every file in the folder, on iCloud storage. If `ArticleReaderView` writes a
        // fresher `status`/`scroll_position` to a file *while* this scan is in flight, this
        // rebuild's snapshot of that one file predates the write, but still gets applied to Core
        // Data afterwards, silently reverting the fresher value even though the file on disk is
        // already correct (confirmed 2026-09-04: file said `status: reading`, Core Data showed
        // `unread` after a rebuild ran mid-open). `scanStartedAt` lets the upsert loop below detect
        // and skip exactly that case per-file, rather than trusting every parsed snapshot blindly.
        let scanStartedAt = Date()

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
                    if Self.wasModified(atPath: path, after: scanStartedAt) {
                        // Someone wrote to this file after our scan captured its content -- our
                        // parse is stale for every field, not just the one that changed. Leave
                        // this row alone this round; the write's own file-watcher notification
                        // (or the next rebuild) will pick up the fresher content.
                        continue
                    }
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

            // Remove records whose files no longer exist on disk. Guard against a failed or
            // incomplete folder read (bad security-scoped access, an unmounted iCloud volume,
            // a transient I/O error) masquerading as "the user deleted every article" — belt and
            // suspenders alongside the access bracket above, for any other way this read can come
            // back empty. A folder that's genuinely been emptied is the one case this misses; that
            // trades against never mass-deleting the cache on a bad read.
            let readLooksValid = !parsedArticles.isEmpty || existing.isEmpty
            if readLooksValid {
                for article in existing where !filePaths.contains(article.filePath) {
                    context.delete(article)
                }
            } else {
                os_log("Cache rebuild: folder read came back empty with %d existing articles cached — skipping stale-record cleanup", log: Self.log, type: .error, existing.count)
            }

            if context.hasChanges {
                try context.save()
                os_log("Cache rebuild complete: %d articles", log: Self.log, type: .info, parsedArticles.count)
            }
        } catch {
            os_log("Cache rebuild failed: %@", log: Self.log, type: .error, error.localizedDescription)
        }
    }

    /// True if the file at `path` was written after `date` — a cheap `stat`, not a re-read of
    /// content. A missing/unreadable file conservatively reports "not modified" so the caller falls
    /// through to its normal (pre-FAB-304-cause-4) behavior rather than silently skipping it.
    private static func wasModified(atPath path: String, after date: Date) -> Bool {
        guard let attrs = try? FileManager.default.attributesOfItem(atPath: path),
              let modDate = attrs[.modificationDate] as? Date else { return false }
        return modDate > date
    }
}
