import Foundation
import os.log

@MainActor
final class ICloudFileWatcher: ObservableObject {
    private static let log = OSLog(subsystem: "com.fabiosasseron.verso", category: "ICloudFileWatcher")

    var onChange: (() -> Void)?

    private var query: NSMetadataQuery?
    private var debounceWork: DispatchWorkItem?

    func start(folderURL: URL) {
        stop()

        let q = NSMetadataQuery()
        q.predicate = NSPredicate(format: "%K LIKE '*.md'", NSMetadataItemFSNameKey)
        q.searchScopes = [folderURL]
        q.notificationBatchingInterval = 0.5

        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(handleQueryNotification),
                       name: .NSMetadataQueryDidFinishGathering, object: q)
        nc.addObserver(self, selector: #selector(handleQueryNotification),
                       name: .NSMetadataQueryDidUpdate, object: q)

        query = q
        q.start()
        os_log("File watcher started for %@", log: Self.log, type: .info, folderURL.path)
    }

    func stop() {
        debounceWork?.cancel()
        debounceWork = nil

        guard let q = query else { return }
        NotificationCenter.default.removeObserver(self, name: .NSMetadataQueryDidFinishGathering, object: q)
        NotificationCenter.default.removeObserver(self, name: .NSMetadataQueryDidUpdate, object: q)
        q.stop()
        query = nil
        os_log("File watcher stopped", log: Self.log, type: .info)
    }

    @objc private func handleQueryNotification(_ notification: Notification) {
        guard let q = query else { return }
        q.disableUpdates()
        q.enableUpdates()

        debounceWork?.cancel()
        let work = DispatchWorkItem { [weak self] in
            os_log("File change detected — triggering cache rebuild", log: ICloudFileWatcher.log, type: .info)
            self?.onChange?()
        }
        debounceWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: work)
    }
}
