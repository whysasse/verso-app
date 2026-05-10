import SwiftUI
import CoreData

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

    enum ViewState {
        case idle
        case saving
        case success
        case failure
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
        NavigationView {
            ZStack {
                themeManager.colors.background
                    .ignoresSafeArea()

                switch viewState {
                case .idle:
                    idleContent
                case .saving:
                    savingContent
                case .success:
                    successContent
                case .failure:
                    failureContent
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if viewState == .idle || viewState == .failure {
                        Button("Cancel") {
                            dismiss()
                        }
                        .foregroundColor(themeManager.colors.accent)
                        .buttonStyle(.plain)
                        .tint(.clear)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Add Article")
                        .font(VersoTypography.UI.listTitle)
                        .foregroundColor(themeManager.colors.textPrimary)
                }
            }
        }
    }

    // MARK: - Idle

    private var idleContent: some View {
        VStack(alignment: .leading, spacing: VersoSpacing.lg) {
            Text("Paste a link to save an article to your library.")
                .font(VersoTypography.UI.listSubtitle)
                .foregroundColor(themeManager.colors.textSecondary)

            VersoTextField(
                placeholder: "Paste a link…",
                text: $urlText,
                keyboardType: .URL,
                autocapitalization: .never,
                autocorrectionDisabled: true
            )

            Button("Save") {
                Task { await save() }
            }
            .buttonStyle(VersoButtonStyle(variant: .primary, theme: themeManager.colors))
            .disabled(!isValidURL)
            .opacity(isValidURL ? 1 : 0.4)

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
            Text("Saving article…")
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
            Text("Article saved!")
                .font(VersoTypography.UI.listTitle)
                .foregroundColor(themeManager.colors.textPrimary)
            Text("It will appear in your library shortly.")
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
            Text("Could not save article")
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
                Button("Try Again") {
                    viewState = .idle
                }
                .buttonStyle(VersoButtonStyle(variant: .primary, theme: themeManager.colors))

                if let url = failedURL {
                    Link(destination: url) {
                        Text("Open in Safari")
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

    // MARK: - Save Logic

    private func save() async {
        guard let url = URL(string: urlText.trimmingCharacters(in: .whitespacesAndNewlines)) else { return }
        failedURL = url
        viewState = .saving

        do {
            let pending = try await parserService.parse(url: url)

            if let folderURL = folderBookmarkService.folderURL {
                let folderAccessed = folderURL.startAccessingSecurityScopedResource()
                defer { if folderAccessed { folderURL.stopAccessingSecurityScopedResource() } }
                // Write markdown file directly
                let parsed = ParsedArticle(
                    id: pending.id,
                    filePath: folderURL, // placeholder; MarkdownWriter uses directory
                    title: pending.title,
                    url: pending.url,
                    contentMarkdown: pending.contentMarkdown,
                    tags: nil,
                    dateAdded: pending.dateAdded,
                    status: .unread
                )
                let fileURL = try MarkdownWriter.write(article: parsed, to: folderURL)

                // Insert into Core Data
                _ = Article.create(
                    in: viewContext,
                    id: pending.id,
                    filePath: fileURL.path,
                    title: pending.title,
                    url: pending.url,
                    status: .unread,
                    dateAdded: pending.dateAdded,
                    source: pending.url.host
                )
                if viewContext.hasChanges {
                    try viewContext.save()
                }
            } else {
                // Write to pending queue in app group container
                try writeToPendingQueue(pending)
            }

            AnalyticsService.shared.track("article.saved", parameters: ["source": "in_app"])
            viewState = .success
        } catch {
            errorMessage = error.localizedDescription
            viewState = .failure
        }
    }

    private func writeToPendingQueue(_ article: PendingArticle) throws {
        let suiteName = "group.com.fabiosasseron.verso"
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
