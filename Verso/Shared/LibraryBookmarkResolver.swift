import Foundation

/// Resolves the user-selected Verso library folder from the app group bookmark (same storage as `FolderBookmarkService`).
enum LibraryBookmarkResolver {
    private static let defaultsKey = "folderBookmark"

    /// Returns the security-scoped library folder URL, or `nil` if unset or bookmark resolution fails.
    /// Callers must `startAccessingSecurityScopedResource()` on the returned URL before file access.
    static func resolveLibraryFolderURL() -> URL? {
        let defaults = UserDefaults(suiteName: AppConstants.appGroupID)
        guard let data = defaults?.data(forKey: defaultsKey) else { return nil }
        var isStale = false
        guard let url = try? URL(
            resolvingBookmarkData: data,
            options: [],
            relativeTo: nil,
            bookmarkDataIsStale: &isStale
        ) else {
            return nil
        }
        return url
    }
}
