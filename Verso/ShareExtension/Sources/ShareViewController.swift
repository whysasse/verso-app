import UIKit
import SwiftUI
import UniformTypeIdentifiers

final class ShareViewController: UIViewController {

    private let viewModel = ShareViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.973, green: 0.965, blue: 0.949, alpha: 1) // Paper background

        let hostingController = UIHostingController(rootView: ShareView(viewModel: viewModel, extensionContext: extensionContext))
        addChild(hostingController)
        hostingController.view.frame = view.bounds
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hostingController.view.backgroundColor = .clear
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)

        extractURL()
    }

    // MARK: - URL extraction (FAB-17)

    private func extractURL() {
        guard let items = extensionContext?.inputItems as? [NSExtensionItem] else {
            completeWithError()
            return
        }

        for item in items {
            guard let attachments = item.attachments else { continue }
            for attachment in attachments {
                if attachment.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                    attachment.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { [weak self] item, _ in
                        DispatchQueue.main.async {
                            guard let self else { return }
                            if let url = item as? URL, self.isValidWebURL(url) {
                                self.viewModel.save(url: url)
                            } else {
                                self.completeWithError()
                            }
                        }
                    }
                    return
                } else if attachment.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
                    attachment.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil) { [weak self] item, _ in
                        DispatchQueue.main.async {
                            guard let self else { return }
                            if let string = item as? String,
                               let url = URL(string: string),
                               self.isValidWebURL(url) {
                                self.viewModel.save(url: url)
                            } else {
                                self.completeWithError()
                            }
                        }
                    }
                    return
                }
            }
        }

        completeWithError()
    }

    private func isValidWebURL(_ url: URL) -> Bool {
        guard let scheme = url.scheme?.lowercased() else { return false }
        return scheme == "http" || scheme == "https"
    }

    private func completeWithError() {
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
}
