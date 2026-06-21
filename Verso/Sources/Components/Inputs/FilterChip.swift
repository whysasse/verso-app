import SwiftUI

struct FilterChip: View {
    let label: String
    let count: Int
    let isActive: Bool
    let colors: ThemeColors
    let accessibilityLabel: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: VersoSpacing.xxs) {
                Text(label)
                Text("\(count)")
            }
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(isActive ? colors.accent : colors.textSecondary)
            .padding(.horizontal, VersoSpacing.sm)
            .frame(height: 36)
            .background(
                Capsule().fill(isActive ? colors.accentSurface : Color.clear)
            )
            .opacity(count == 0 && !isActive ? 0.5 : 1)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(isActive ? L10n.Filter.chipSelectedHint : L10n.Filter.chipUnselectedHint)
    }
}

#Preview {
    let colors = ThemeColors.paper

    return VStack(spacing: 16) {
        HStack(spacing: 8) {
            FilterChip(label: L10n.Filter.all, count: 12, isActive: true, colors: colors, accessibilityLabel: L10n.Filter.allAccessibilityLabel(count: 12)) {}
            FilterChip(label: L10n.Filter.unread, count: 5, isActive: false, colors: colors, accessibilityLabel: L10n.Filter.unreadAccessibilityLabel(count: 5)) {}
            FilterChip(label: L10n.Filter.reading, count: 3, isActive: false, colors: colors, accessibilityLabel: L10n.Filter.readingAccessibilityLabel(count: 3)) {}
            FilterChip(label: L10n.Filter.read, count: 0, isActive: false, colors: colors, accessibilityLabel: L10n.Filter.readAccessibilityLabel(count: 0)) {}
        }
        HStack(spacing: 8) {
            FilterChip(label: L10n.Filter.all, count: 12, isActive: false, colors: colors, accessibilityLabel: L10n.Filter.allAccessibilityLabel(count: 12)) {}
            FilterChip(label: L10n.Filter.unread, count: 5, isActive: true, colors: colors, accessibilityLabel: L10n.Filter.unreadAccessibilityLabel(count: 5)) {}
        }
    }
    .padding()
}
