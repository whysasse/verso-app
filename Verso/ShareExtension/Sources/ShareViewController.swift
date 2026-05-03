import UIKit
import Social
import UniformTypeIdentifiers

class ShareViewController: SLComposeServiceViewController {

    override func isContentValid() -> Bool {
        return true
    }

    override func didSelectPost() {
        guard let extensionItems = extensionContext?.inputItems as? [NSExtensionItem],
              let item = extensionItems.first,
              let attachments = item.attachments else {
            self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
            return
        }

        for attachment in attachments {
            if attachment.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                attachment.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { item, error in
                    if let url = item as? URL {
                        self.saveURLToSharedContainer(url)
                    }
                    self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
                }
                return
            }
        }

        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }

    private func saveURLToSharedContainer(_ url: URL) {
        guard let sharedContainer = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group.com.fabiosasseron.verso"
        ) else { return }

        let savedURLsURL = savedURLsURL(in: sharedContainer)
        var urls: [String] = []

        if FileManager.default.fileExists(atPath: savedURLsURL.path),
           let data = try? Data(contentsOf: savedURLsURL),
           let existing = try? JSONDecoder().decode([String].self, from: data) {
            urls = existing
        }

        urls.append(url.absoluteString)

        if let data = try? JSONEncoder().encode(urls) {
            try? data.write(to: savedURLsURL)
        }
    }

    private func savedURLsURL(in container: URL) -> URL {
        container.appendingPathComponent("saved_urls.json")
    }

    override func configurationItems() -> [Any]! {
        return []
    }
}
