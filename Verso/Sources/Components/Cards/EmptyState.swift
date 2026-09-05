import SwiftUI

struct EmptyState: View {
    enum Variant {
        case empty
        case searchMiss
        case noArchived
    }

    let variant: Variant
    /// FAB-319: the caller supplies the action since only it knows how to add an article or
    /// clear the active filters -- `EmptyState` itself just renders whichever CTA `ctaTitle`
    /// names for this variant. `nil` (the default) renders no button, e.g. `.noArchived`, which
    /// has no CTA copy and isn't currently instantiated anywhere in the app.
    var onAction: (() -> Void)? = nil
    @EnvironmentObject var themeManager: ThemeManager
    private var colors: ThemeColors { themeManager.colors }

    var body: some View {
        VStack(spacing: 48) {
            Spacer()

            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(colors.textSecondary)

            VStack(spacing: VersoSpacing.md) {
                Text(headline)
                    .font(.system(.title3).weight(.semibold))
                    .foregroundColor(colors.textPrimary)

                if let ctaTitle, let onAction {
                    Button(ctaTitle, action: onAction)
                        .buttonStyle(VersoButtonStyle(variant: .primary, theme: colors))
                        .padding(.horizontal, VersoSpacing.xl)
                }

                Text(subheadline)
                    .font(VersoTypography.UI.listSubtitle)
                    .foregroundColor(colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, VersoSpacing.xl)
            }

            Spacer()
        }
    }

    private var icon: String {
        switch variant {
        case .empty:      return "tray"
        case .searchMiss: return "doc.text.magnifyingglass"
        case .noArchived: return "archivebox"
        }
    }

    private var headline: String {
        switch variant {
        case .empty:      return L10n.Home.emptyNoArticlesHeadline
        case .searchMiss: return L10n.Home.emptyNoResultsHeadline
        case .noArchived: return L10n.Home.emptyArchiveHeadline
        }
    }

    private var ctaTitle: String? {
        switch variant {
        case .empty:      return L10n.Home.emptyNoArticlesCta
        case .searchMiss: return L10n.Home.emptyNoResultsCta
        case .noArchived: return nil
        }
    }

    private var subheadline: String {
        switch variant {
        case .empty:      return L10n.Home.emptyNoArticlesSubheadline
        case .searchMiss: return L10n.Home.emptyNoResultsSubheadline
        case .noArchived: return L10n.Home.emptyArchiveSubheadline
        }
    }
}

#Preview {
    VStack {
        EmptyState(variant: .empty, onAction: {})
        Divider()
        EmptyState(variant: .searchMiss, onAction: {})
    }
    .environmentObject(ThemeManager())
}
