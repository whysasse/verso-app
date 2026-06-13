import SwiftUI

/// Post-onboarding shell: `NavigationSplitView` collapses to a stacked experience on iPhone and compact iPad widths.
struct VersoMainSplitView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var selectedArticle: Article?

    var body: some View {
        NavigationSplitView {
            ArticleListView(selectedArticle: $selectedArticle)
                // Hybrid iPad spec (FAB-152 Figma): sidebar "Column — Article list" = 320pt regular width.
                .navigationSplitViewColumnWidth(min: 280, ideal: 320, max: 420)
        } detail: {
            Group {
                if let article = selectedArticle {
                    ArticleReaderView(
                        article: article,
                        onRequestClose: { selectedArticle = nil },
                        onSelectRelatedArticle: { selectedArticle = $0 }
                    )
                } else {
                    readerPlaceholder
                }
            }
        }
        .navigationSplitViewStyle(.balanced)
    }

    private var readerPlaceholder: some View {
        ZStack {
            themeManager.colors.background
            VStack(spacing: VersoSpacing.md) {
                Image(systemName: "book.pages")
                    .font(.system(size: 44, weight: .light))
                    .foregroundColor(themeManager.colors.textSecondary)
                Text("Select an article")
                    .font(VersoTypography.UI.listTitle)
                    .foregroundColor(themeManager.colors.textSecondary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("No article selected")
        }
    }
}
