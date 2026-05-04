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

private struct FilterChip: View {
    let label: String
    let count: Int
    let isActive: Bool
    let colors: ThemeColors
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("\(label) \(count)")
                .font(VersoTypography.UI.caption)
                .foregroundColor(isActive ? .white : colors.accent)
                .padding(.horizontal, VersoSpacing.sm)
                .frame(height: 36)
                .background(isActive ? colors.accent : colors.accentSurface)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
