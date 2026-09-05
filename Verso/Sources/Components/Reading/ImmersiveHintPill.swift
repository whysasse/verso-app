import SwiftUI

struct ImmersiveHintPill: View {
    @Binding var isVisible: Bool
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        if isVisible {
            // FAB-325: was a hardcoded black pill regardless of theme -- a foreign object
            // on Paper's cream. Reuses the theme's own highest-contrast pair, inverted
            // (textPrimary as fill, background as text) -- works in all four themes since
            // contrast ratio is symmetric, no new color invented.
            //
            // FAB-318: a real `Button` instead of a bare `Text` + `.onTapGesture` -- gets a
            // correct accessibility label for free (SwiftUI infers it from the visible
            // Text), where before there was none. `.frame(minHeight: 44)` +
            // `.contentShape(Rectangle())` grow the tappable area to the 44pt minimum
            // without changing the pill's own small visual size.
            Button {
                isVisible = false
            } label: {
                Text(L10n.Reading.immersiveHint)
                    .font(.system(size: 13))
                    .foregroundColor(themeManager.colors.background)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(themeManager.colors.textPrimary)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .frame(minHeight: 44)
            .contentShape(Rectangle())
            .transition(.opacity.animation(VersoAnimation.normal))
        }
    }
}

struct ImmersiveHintPill_Preview: View {
    @State private var visible = true
    var body: some View {
        ZStack {
            Color.gray.opacity(0.3)
            VStack {
                Spacer()
                ImmersiveHintPill(isVisible: $visible)
                    .padding(.bottom, 100)
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ImmersiveHintPill_Preview()
        .environmentObject(ThemeManager())
}
