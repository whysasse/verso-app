import SwiftUI

struct FilterChipBar: View {
    @Binding var activeFilter: ArticleStatus?
    let counts: [ArticleStatus: Int]

    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: VersoSpacing.xs) {
                FilterChip(
                    label: "All",
                    count: counts.values.reduce(0, +),
                    isActive: activeFilter == nil,
                    colors: themeManager.colors
                ) {
                    activeFilter = nil
                }

                ForEach(ArticleStatus.allCases, id: \.self) { status in
                    FilterChip(
                        label: status.rawValue,
                        count: counts[status, default: 0],
                        isActive: activeFilter == status,
                        colors: themeManager.colors
                    ) {
                        activeFilter = status
                    }
                }
            }
            .padding(.horizontal, VersoSpacing.md)
        }
    }
}

#Preview {
    @Previewable @State var filter: ArticleStatus? = nil

    FilterChipBar(
        activeFilter: $filter,
        counts: [.unread: 5, .reading: 3, .read: 4]
    )
    .environmentObject(ThemeManager())
}
