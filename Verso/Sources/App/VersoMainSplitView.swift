import SwiftUI

/// Post-onboarding shell: `NavigationSplitView` collapses to a stacked experience on iPhone and compact iPad widths.
struct VersoMainSplitView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    /// Drives sidebar → detail: a runtime warning confirmed `NavigationLink(value:)` in the
    /// sidebar can't see a `.navigationDestination(for:)` registered in the detail column — SwiftUI
    /// only resolves destinations within the link's own column or an enclosing `NavigationStack`.
    /// `List(selection:)` is the mechanism `NavigationSplitView` actually wires up for the
    /// automatic sidebar→detail collapse/push on iPhone (the master-detail pattern), so the
    /// sidebar's List (in ArticleListView) is bound to this instead.
    @State private var selectedArticle: Article?
    /// Drives the detail column's own stack — lets "open a related article" push another reader
    /// on top, without touching `selectedArticle` (that would re-trigger the sidebar's collapse logic).
    @State private var detailPath = NavigationPath()

    var body: some View {
        NavigationSplitView {
            ArticleListView(selectedArticle: $selectedArticle)
                // Hybrid iPad spec (FAB-152 Figma): sidebar "Column — Article list" = 320pt regular width.
                .navigationSplitViewColumnWidth(min: 280, ideal: 320, max: 420)
        } detail: {
            NavigationStack(path: $detailPath) {
                Group {
                    if let article = selectedArticle {
                        ArticleReaderView(
                            article: article,
                            // Clears the sidebar's selection: on iPhone this pops back to the list
                            // (mirrors what the system back button does for selection-driven detail).
                            onRequestClose: { selectedArticle = nil },
                            onSelectRelatedArticle: { detailPath.append($0) }
                        )
                    } else {
                        readerPlaceholder
                    }
                }
                // Only used for the related-article push above: that destination is declared and
                // consumed within this same NavigationStack/column, so it's a legitimate use of
                // navigationDestination(for:) — unlike trying to reach it from the sidebar.
                .navigationDestination(for: Article.self) { article in
                    ArticleReaderView(
                        article: article,
                        onSelectRelatedArticle: { detailPath.append($0) }
                    )
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
                Text(L10n.Reading.splitViewPlaceholderHeadline)
                    .font(VersoTypography.UI.listTitle)
                    .foregroundColor(themeManager.colors.textSecondary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(L10n.Reading.splitViewPlaceholderAccessibilityLabel)
        }
    }
}
