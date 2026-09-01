import Foundation
import OSLog

private let logger = Logger(subsystem: "com.fabiosasseron.verso", category: "libraryBookmark")

/// Resolves the user-selected Verso library folder from the app group bookmark (same storage as `FolderBookmarkService`).
enum LibraryBookmarkResolver {
    private static let defaultsKey = "folderBookmark"

    /// Returns the security-scoped library folder URL, or `nil` if unset or bookmark resolution fails.
    /// Callers must `startAccessingSecurityScopedResource()` on the returned URL before file access.
    ///
    /// FAB-296: a `nil` return here used to silently skip the Share Extension's duplicate check
    /// with nothing logged. Now logged, and a stale bookmark is refreshed in place — mirroring
    /// `FolderBookmarkService.restore()`'s existing stale-refresh pattern — so a stale bookmark
    /// self-heals instead of degrading on every subsequent share.
    static func resolveLibraryFolderURL() -> URL? {
        let defaults = UserDefaults(suiteName: AppConstants.appGroupID)
        guard let data = defaults?.data(forKey: defaultsKey) else {
            logger.warning("No library bookmark saved — skipping duplicate check for this save")
            return nil
        }
        var isStale = false
        guard let url = try? URL(
            resolvingBookmarkData: data,
            options: [],
            relativeTo: nil,
            bookmarkDataIsStale: &isStale
        ) else {
            logger.warning("Library bookmark failed to resolve — skipping duplicate check for this save")
            return nil
        }
        if isStale {
            refreshBookmark(for: url, defaults: defaults)
        }
        return url
    }

    private static func refreshBookmark(for url: URL, defaults: UserDefaults?) {
        let accessed = url.startAccessingSecurityScopedResource()
        defer { if accessed { url.stopAccessingSecurityScopedResource() } }
        guard let data = try? url.bookmarkData(options: [], includingResourceValuesForKeys: nil, relativeTo: nil) else {
            logger.warning("Library bookmark is stale and could not be refreshed")
            return
        }
        defaults?.set(data, forKey: defaultsKey)
        logger.info("Refreshed stale library bookmark")
    }
}
