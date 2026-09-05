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
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(colors.placeholder)
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
