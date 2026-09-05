import SwiftUI

struct EmptyState: View {
    enum Variant {
        case empty
        case searchMiss
        case noArchived
    }

    let variant: Variant
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
        EmptyState(variant: .empty)
        Divider()
        EmptyState(variant: .searchMiss)
    }
    .environmentObject(ThemeManager())
}
