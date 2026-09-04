import SwiftUI
import CoreData
import UIKit

struct AddArticleView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var folderBookmarkService: FolderBookmarkService
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var urlText = ""
    @State private var viewState: ViewState = .idle
    @State private var errorMessage: String?
    @State private var failedURL: URL?

    private let parserService = ArticleParserService()

    enum ViewState: Equatable {
        case idle
        case saving
        case duplicatePrompt(pending: PendingArticle, existingPath: String, existingTitle: String)
        case success
        case failure
    }

    private var showsDismissToolbarButton: Bool {
        switch viewState {
        case .idle, .failure, .duplicatePrompt:
            return true
        case .saving, .success:
            return false
        }
    }

    private var isValidURL: Bool {
        guard !urlText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let url = URL(string: urlText.trimmingCharacters(in: .whitespacesAndNewlines)),
              let scheme = url.scheme,
              (scheme == "http" || scheme == "https"),
              url.host != nil
        else { return false }
        return true
    }

    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.colors.background
                    .ignoresSafeArea()

                switch viewState {
                case .idle:
                    idleContent
                case .saving:
                    savingContent
                case .duplicatePrompt(let pending, let existingPath, let existingTitle):
                    duplicatePromptContent(pending: pending, existingPath: existingPath, existingTitle: existingTitle)
                case .success:
                    successContent
                case .failure:
                    failureContent
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if showsDismissToolbarButton {
                        VersoToolbarIconButton(
                            systemName: "xmark",
                            accent: themeManager.colors.accent,
                            action: { dismiss() },
                            iconPointSize: 17,
                            labelWidth: 44,
                            labelHeight: 44,
                            accessibilityLabel: L10n.AddArticle.closeAccessibilityLabel,
                            accessibilityHint: L10n.AddArticle.closeAccessibilityHint
                        )
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text(L10n.AddArticle.navTitle)
                        .font(VersoTypography.UI.listTitle)
                        .foregroundColor(themeManager.colors.textPrimary)
                }
            }
        }
        .frame(maxWidth: 520)
        .frame(maxWidth: .infinity)
        .presentationDetents([.large])
        .onAppear {
            prefillURLFromClipboardIfNeeded()
        }
    }

    // MARK: - Idle

    private var idleContent: some View {
        VStack(alignment: .leading, spacing: VersoSpacing.lg) {
            Text(L10n.AddArticle.idleInstructions)
                .font(VersoTypography.UI.listSubtitle)
                .foregroundColor(themeManager.colors.textSecondary)

            VersoTextField(
                placeholder: L10n.AddArticle.idlePlaceholder,
                text: $urlText,
                keyboardType: .URL,
                autocapitalization: .never,
                autocorrectionDisabled: true
            )

            Button(L10n.AddArticle.idleSave) {
                Task { await save() }
            }
            .buttonStyle(VersoButtonStyle(variant: .primary, theme: themeManager.colors))
            .disabled(!isValidURL)

            Spacer()
        }
        .padding(.horizontal, VersoSpacing.md)
        .padding(.top, VersoSpacing.lg)
    }

    // MARK: - Duplicate prompt

    private func duplicatePromptContent(pending: PendingArticle, existingPath: String, existingTitle: String) -> some View {
        VStack(alignment: .leading, spacing: VersoSpacing.lg) {
            Text(L10n.Share.duplicateHeadline)
                .font(VersoTypography.UI.listTitle)
                .foregroundColor(themeManager.colors.textPrimary)

            Text(L10n.Share.duplicateSubheadline(existingTitle: existingTitle))
                .font(VersoTypography.UI.listSubtitle)
                .foregroundColor(themeManager.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: VersoSpacing.sm) {
                Button(L10n.Share.duplicateUpdateExisting) {
                    Task { await applyDuplicateReplace(pending: pending, existingPath: existingPath) }
                }
                .buttonStyle(VersoButtonStyle(variant: .primary, theme: themeManager.colors))

                Button(L10n.Share.duplicateSaveCopy) {
                    Task { await applyDuplicateCopy(pending: pending) }
                }
                .buttonStyle(VersoButtonStyle(variant: .secondary, theme: themeManager.colors))

                Button(L10n.Share.duplicateCancel) {
                    viewState = .idle
                }
                .font(VersoTypography.UI.button)
                .foregroundColor(themeManager.colors.textSecondary)
                .frame(maxWidth: .infinity)
            }

            Spacer()
        }
        .padding(.horizontal, VersoSpacing.md)
        .padding(.top, VersoSpacing.lg)
    }

    // MARK: - Saving

    private var savingContent: some View {
        VStack(spacing: VersoSpacing.md) {
            Spacer()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: themeManager.colors.accent))
                .scaleEffect(1.5)
            Text(L10n.AddArticle.savingMessage)
                .font(VersoTypography.UI.caption)
                .foregroundColor(themeManager.colors.textSecondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Success

    private var successContent: some View {
        VStack(spacing: VersoSpacing.md) {
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 56))
                .foregroundColor(themeManager.colors.accent)
            Text(L10n.AddArticle.successHeadline)
                .font(VersoTypography.UI.listTitle)
                .foregroundColor(themeManager.colors.textPrimary)
            Text(L10n.AddArticle.successSubheadline)
                .font(VersoTypography.UI.listSubtitle)
                .foregroundColor(themeManager.colors.textSecondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(.horizontal, VersoSpacing.md)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                dismiss()
            }
        }
    }

    // MARK: - Failure

    private var failureContent: some View {
        VStack(spacing: VersoSpacing.md) {
            Spacer()
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 56))
                .foregroundColor(.red.opacity(0.8))
            Text(L10n.AddArticle.failureHeadline)
                .font(VersoTypography.UI.listTitle)
                .foregroundColor(themeManager.colors.textPrimary)
            if let message = errorMessage {
                Text(message)
                    .font(VersoTypography.UI.listSubtitle)
                    .foregroundColor(themeManager.colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, VersoSpacing.md)
            }

            VStack(spacing: VersoSpacing.sm) {
                Button(L10n.AddArticle.failureTryAgain) {
                    viewState = .idle
                }
                .buttonStyle(VersoButtonStyle(variant: .primary, theme: themeManager.colors))

                if let url = failedURL {
                    Link(destination: url) {
                        Text(L10n.Error.parsingOpenInSafari)
                            .font(VersoTypography.UI.button)
                            .foregroundColor(themeManager.colors.accent)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, VersoSpacing.md)

            Spacer()
        }
        .padding(.horizontal, VersoSpacing.md)
    }

    /// FAB-135: Prefill URL field when the sheet opens with a plausible HTTP(S) URL on the pasteboard.
    /// Uses detectPatterns first so iOS does not show the "Pasted from…" system banner.
    private func prefillURLFromClipboardIfNeeded() {
        guard viewState == .idle else { return }
        guard urlText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        Task {
            // `hasURLs` is a quiet check — no "Pasted from…" banner, no permission prompt.
            // Replaces the deprecated `detectPatterns(for: [.probableWebURL])`.
            // `.string` covers plain-text pastes; `.url?.absoluteString` covers URL-type pastes
            // (e.g. from Safari's address bar) where `.string` may return nil.
            guard UIPasteboard.general.hasURLs else { return }
            guard let raw = UIPasteboard.general.string ?? UIPasteboard.general.url?.absoluteString else { return }
            let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            guard let urlString = Self.firstHTTPURLString(in: trimmed) else { return }
            await MainActor.run {
                // Re-check: user may have typed something while detection was running.
                guard urlText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                urlText = urlString
            }
        }
    }

    private static func firstHTTPURLString(in string: String) -> String? {
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
            return nil
        }
        let range = NSRange(string.startIndex..<string.endIndex, in: string)
        guard let match = detector.firstMatch(in: string, options: [], range: range),
              let url = match.url,
              let scheme = url.scheme?.lowercased(),
              scheme == "http" || scheme == "https",
              url.host != nil
        else { return nil }
        return url.absoluteString
    }

    // MARK: - Save Logic

    private func save() async {
        guard let url = URL(string: urlText.trimmingCharacters(in: .whitespacesAndNewlines)) else { return }
        failedURL = url
        viewState = .saving
        errorMessage = nil

        do {
            let pending = try await parserService.parse(url: url)

            if let folderURL = folderBookmarkService.folderURL {
                let folderAccessed = folderURL.startAccessingSecurityScopedResource()
                defer { if folderAccessed { folderURL.stopAccessingSecurityScopedResource() } }

                if let match = ArticleDuplicateFinder.findDuplicate(of: pending.url, libraryFolder: folderURL) {
                    viewState = .duplicatePrompt(
                        pending: pending,
                        existingPath: match.fileURL.path,
                        existingTitle: match.existingTitle
                    )
                    return
                }

                try await writeNewArticleToLibrary(pending: pending, folderURL: folderURL, articleId: pending.id)
            } else {
                try writeToPendingQueue(pending)
            }

            AnalyticsService.shared.track(
                "article.saved",
                parameters: ["source": "in_app", "duplicate_resolution": "none"]
            )
            viewState = .success
        } catch {
            errorMessage = error.localizedDescription
            viewState = .failure
        }
    }

    private func applyDuplicateReplace(pending: PendingArticle, existingPath: String) async {
        failedURL = pending.url
        viewState = .saving
        errorMessage = nil
        guard let folderURL = folderBookmarkService.folderURL else {
            errorMessage = L10n.AddArticle.errorNoLibraryFolder
            viewState = .failure
            return
        }
        let folderAccessed = folderURL.startAccessingSecurityScopedResource()
        defer { if folderAccessed { folderURL.stopAccessingSecurityScopedResource() } }
        do {
            try await replaceArticleInLibrary(pending: pending, existingPath: existingPath, folderURL: folderURL)
            AnalyticsService.shared.track(
                "article.saved",
                parameters: ["source": "in_app", "duplicate_resolution": "update"]
            )
            viewState = .success
        } catch {
            errorMessage = error.localizedDescription
            viewState = .failure
        }
    }

    private func applyDuplicateCopy(pending: PendingArticle) async {
        failedURL = pending.url
        viewState = .saving
        errorMessage = nil
        guard let folderURL = folderBookmarkService.folderURL else {
            errorMessage = L10n.AddArticle.errorNoLibraryFolder
            viewState = .failure
            return
        }
        let folderAccessed = folderURL.startAccessingSecurityScopedResource()
        defer { if folderAccessed { folderURL.stopAccessingSecurityScopedResource() } }
        do {
            var copyPending = pending
            copyPending.title = ShareDuplicateArticleTitle.titleByAppendingCopySuffix(to: pending.title)
            try await writeNewArticleToLibrary(pending: copyPending, folderURL: folderURL, articleId: UUID())
            AnalyticsService.shared.track(
                "article.saved",
                parameters: ["source": "in_app", "duplicate_resolution": "copy"]
            )
            viewState = .success
        } catch {
            errorMessage = error.localizedDescription
            viewState = .failure
        }
    }

    private func parsedArticle(from pending: PendingArticle, folderURL: URL, id: UUID) -> ParsedArticle {
        ParsedArticle(
            id: id,
            filePath: folderURL,
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
    }

    private func writeNewArticleToLibrary(pending: PendingArticle, folderURL: URL, articleId: UUID) async throws {
        let parsed = parsedArticle(from: pending, folderURL: folderURL, id: articleId)
        let fileURL = try await MarkdownWriter.write(article: parsed, to: folderURL)
        _ = Article.create(
            in: viewContext,
            id: articleId,
            filePath: fileURL.path,
            title: pending.title,
            url: pending.url,
            status: .unread,
            dateAdded: pending.dateAdded,
            source: pending.url.host,
            author: pending.author,
            siteName: pending.siteName,
            searchableBody: ArticlePlainText.fromMarkdown(pending.contentMarkdown)
        )
        if viewContext.hasChanges {
            try viewContext.save()
        }
    }

    private func replaceArticleInLibrary(pending: PendingArticle, existingPath: String, folderURL: URL) async throws {
        let fileURL = URL(fileURLWithPath: existingPath)
        let parsed = parsedArticle(from: pending, folderURL: folderURL, id: pending.id)
        try await MarkdownWriter.replaceArticle(at: fileURL, incoming: parsed, libraryRoot: folderURL)
        try upsertCoreDataAfterReplace(filePath: fileURL, pending: pending)
    }

    private func upsertCoreDataAfterReplace(filePath: URL, pending: PendingArticle) throws {
        let request = NSFetchRequest<Article>(entityName: "Article")
        request.predicate = NSPredicate(format: "filePath == %@", filePath.path)
        request.fetchLimit = 1
        guard let existing = try viewContext.fetch(request).first else {
            let refreshed = try MarkdownReader.read(fileURL: filePath)
            _ = Article.create(
                in: viewContext,
                id: pending.id,
                filePath: filePath.path,
                title: pending.title,
                url: pending.url,
                status: refreshed.status,
                dateAdded: pending.dateAdded,
                source: pending.url.host,
                author: pending.author,
                siteName: pending.siteName,
                scrollPosition: refreshed.scrollPosition.map { NSNumber(value: $0) },
                tagsSerialized: Article.makeTagsSerialized(from: refreshed.tags),
                searchableBody: ArticlePlainText.fromMarkdown(pending.contentMarkdown),
                archived: refreshed.archived,
                archivedAt: refreshed.archivedAt
            )
            if viewContext.hasChanges {
                try viewContext.save()
            }
            return
        }
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
        if viewContext.hasChanges {
            try viewContext.save()
        }
    }

    private func writeToPendingQueue(_ article: PendingArticle) throws {
        let suiteName = AppConstants.appGroupID
        guard let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: suiteName) else {
            return
        }
        let pendingDir = container.appendingPathComponent("pending", isDirectory: true)
        try FileManager.default.createDirectory(at: pendingDir, withIntermediateDirectories: true)
        let fileURL = pendingDir.appendingPathComponent("\(article.id.uuidString).json")
        let data = try JSONEncoder().encode(article)
        try data.write(to: fileURL, options: .atomic)
    }
}

#Preview {
    struct PreviewWrapper: View {
        var body: some View {
            AddArticleView()
                .environmentObject(ThemeManager())
                .environmentObject(FolderBookmarkService())
        }
    }
    return PreviewWrapper()
}
