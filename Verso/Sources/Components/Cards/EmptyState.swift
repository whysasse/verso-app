import SwiftUI

struct EmptyState: View {
    enum Variant {
        case empty
        case searchMiss
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
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(colors.textPrimary)

                Text(subheadline)
                    .font(.system(size: 15))
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
        }
    }

    private var headline: String {
        switch variant {
        case .empty:      return "No articles yet"
        case .searchMiss: return "No articles match your search"
        }
    }

    private var subheadline: String {
        switch variant {
        case .empty:      return "Save your first article to get started"
        case .searchMiss: return "Try a different search term"
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
