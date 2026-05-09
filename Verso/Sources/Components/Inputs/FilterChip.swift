import SwiftUI

struct FilterChip: View {
    let label: String
    let count: Int
    let isActive: Bool
    let colors: ThemeColors
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
    }
}

#Preview {
    let colors = ThemeColors.paper

    return VStack(spacing: 16) {
        HStack(spacing: 8) {
            FilterChip(label: "All", count: 12, isActive: true, colors: colors) {}
            FilterChip(label: "Unread", count: 5, isActive: false, colors: colors) {}
            FilterChip(label: "Reading", count: 3, isActive: false, colors: colors) {}
            FilterChip(label: "Read", count: 0, isActive: false, colors: colors) {}
        }
        HStack(spacing: 8) {
            FilterChip(label: "All", count: 12, isActive: false, colors: colors) {}
            FilterChip(label: "Unread", count: 5, isActive: true, colors: colors) {}
        }
    }
    .padding()
}
