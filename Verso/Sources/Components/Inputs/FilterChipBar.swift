import SwiftUI

struct FilterChipBar: View {
    @Binding var activeFilter: ArticleStatus?
    let counts: [ArticleStatus: Int]

    @EnvironmentObject var themeManager: ThemeManager

    /// Unread + Reading + Read only — excludes Archived, which never shows in any of those lists
    /// and has its own chip/count already.
    private var allCount: Int {
        [ArticleStatus.unread, .reading, .read].reduce(0) { $0 + counts[$1, default: 0] }
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: VersoSpacing.xs) {
                FilterChip(
                    label: L10n.Filter.all,
                    count: allCount,
                    isActive: activeFilter == nil,
                    colors: themeManager.colors,
                    accessibilityLabel: L10n.Filter.allAccessibilityLabel(count: allCount)
                ) {
                    activeFilter = nil
                }

                ForEach(ArticleStatus.allCases, id: \.self) { status in
                    FilterChip(
                        label: status.filterLabel,
                        count: counts[status, default: 0],
                        isActive: activeFilter == status,
                        colors: themeManager.colors,
                        accessibilityLabel: status.filterAccessibilityLabel(count: counts[status, default: 0])
                    ) {
                        activeFilter = status
                    }
                }
            }
            .padding(.horizontal, VersoSpacing.md)
        }
    }
}

struct FilterChipBar_Preview: View {
    @State private var filter: ArticleStatus? = nil

    var body: some View {
        FilterChipBar(
            activeFilter: $filter,
            counts: [.unread: 5, .reading: 3, .read: 4]
        )
        .environmentObject(ThemeManager())
    }
}

#Preview {
    FilterChipBar_Preview()
}
