import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String = "Search titles..."
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
        .overlay(
            RoundedRectangle(cornerRadius: VersoRadius.sm)
                .stroke(isFocused ? colors.accent : colors.border, lineWidth: isFocused ? 2 : 1)
        )
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var text = ""
        @State private var filled = "Swift"
        var body: some View {
            VStack(spacing: 16) {
                SearchBar(text: $text)
                SearchBar(text: $filled)
            }
            .padding()
            .environmentObject(ThemeManager())
        }
    }
    return PreviewWrapper()
}
