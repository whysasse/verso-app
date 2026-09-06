import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    /// No default on purpose (FAB-308): a hardcoded, unlocalized fallback here
    /// was dead code (every real caller already passes an `L10n` string) but a
    /// landmine for the next one — making it required closes that off for good.
    var placeholder: String
    @EnvironmentObject var themeManager: ThemeManager
    @FocusState private var isFocused: Bool
    private var colors: ThemeColors { themeManager.colors }

    var body: some View {
        HStack(spacing: VersoSpacing.xs) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(colors.textSecondary)

            TextField(placeholder, text: $text)
                .font(VersoTypography.UI.input)
                .foregroundColor(colors.textPrimary)
                .tint(colors.accent)
                .focused($isFocused)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    // FAB-336: was colors.placeholder (1.12-1.55:1 against surface across
                    // themes, well under the 3:1 non-text floor -- `scripts/check_contrast.py`
                    // caught it). `placeholder` is meant for decorative, intentionally-recessive
                    // fills (skeleton loaders) per DESIGN_TOKENS.md, not an icon someone needs to
                    // see -- the actual fix is matching this to the magnifying glass above, the
                    // other neutral utility icon in this same control, already validated ≥4.5:1.
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(colors.textSecondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, VersoSpacing.sm)
        .frame(height: 44)
        .background(colors.surface)
        .cornerRadius(VersoRadius.sm)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var text = ""
        @State private var filled = "Swift"
        var body: some View {
            VStack(spacing: 16) {
                SearchBar(text: $text, placeholder: "Search titles...")
                SearchBar(text: $filled, placeholder: "Search titles...")
            }
            .padding()
            .environmentObject(ThemeManager())
        }
    }
    return PreviewWrapper()
}
