import SwiftUI

struct VersoTextField: View {
    enum FieldState {
        case `default`
        case error(String)
        case disabled
    }

    let placeholder: String
    @Binding var text: String
    var fieldState: FieldState = .default
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences
    var autocorrectionDisabled: Bool = false
    @EnvironmentObject var themeManager: ThemeManager
    @FocusState private var isFocused: Bool
    private var colors: ThemeColors { themeManager.colors }
    private var semanticColors: SemanticColors { SemanticColors.semanticColors(for: themeManager.currentTheme) }

    var body: some View {
        VStack(alignment: .leading, spacing: VersoSpacing.xxs) {
            TextField(placeholder, text: $text)
                .font(VersoTypography.UI.input)
                .foregroundColor(colors.textPrimary)
                .tint(colors.accent)
                .focused($isFocused)
                .disabled(isDisabled)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(autocapitalization)
                .autocorrectionDisabled(autocorrectionDisabled)
                .padding(.horizontal, VersoSpacing.md)
                .padding(.vertical, VersoSpacing.sm)
                .background(colors.surface)
                .cornerRadius(VersoRadius.sm)
                .overlay(
                    RoundedRectangle(cornerRadius: VersoRadius.sm)
                        .stroke(borderColor, lineWidth: borderWidth)
                )
                .opacity(isDisabled ? 0.4 : 1)

            if case .error(let message) = fieldState {
                Text(message)
                    .font(VersoTypography.UI.caption)
                    .foregroundColor(semanticColors.error)
            }
        }
    }

    private var isDisabled: Bool {
        if case .disabled = fieldState { return true }
        return false
    }

    private var borderColor: Color {
        switch fieldState {
        case .default:      return isFocused ? colors.accent : colors.border
        case .error:        return semanticColors.error
        case .disabled:     return colors.border
        }
    }

    private var borderWidth: CGFloat {
        switch fieldState {
        case .default:  return isFocused ? 2 : 1
        case .error:    return 2
        case .disabled: return 1
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var text1 = ""
        @State var text2 = "hello@example.com"
        @State var text3 = "bad input"
        @State var text4 = "disabled"

        var body: some View {
            VStack(spacing: 16) {
                VersoTextField(placeholder: "Email", text: $text1)
                VersoTextField(placeholder: "Email", text: $text2)
                VersoTextField(placeholder: "Email", text: $text3, fieldState: .error("Invalid email address"))
                VersoTextField(placeholder: "Email", text: $text4, fieldState: .disabled)
            }
            .padding()
            .environmentObject(ThemeManager())
        }
    }
    return PreviewWrapper()
}
