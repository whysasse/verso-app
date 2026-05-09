import Foundation

final class FolderBookmarkService: ObservableObject {
    private static let defaultsKey = "folderBookmark"
    private static let suiteName = "group.com.fabiosasseron.verso"

    @Published private(set) var folderURL: URL?

    func restore() {
        let defaults = UserDefaults(suiteName: Self.suiteName)
        guard let data = defaults?.data(forKey: Self.defaultsKey) else { return }
        var isStale = false
        guard let url = try? URL(
            resolvingBookmarkData: data,
            options: [],
            relativeTo: nil,
            bookmarkDataIsStale: &isStale
        ) else { return }
        _ = url.startAccessingSecurityScopedResource()
        folderURL = url
        if isStale { save(url: url) }
    }

    func save(url: URL) {
        _ = url.startAccessingSecurityScopedResource()
        guard let data = try? url.bookmarkData(
            options: [],
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        ) else {
            url.stopAccessingSecurityScopedResource()
            return
        }
        UserDefaults(suiteName: Self.suiteName)?.set(data, forKey: Self.defaultsKey)
        url.stopAccessingSecurityScopedResource()
        folderURL = url
        _ = url.startAccessingSecurityScopedResource()
    }

    func stopAccess() {
        folderURL?.stopAccessingSecurityScopedResource()
    }
}
