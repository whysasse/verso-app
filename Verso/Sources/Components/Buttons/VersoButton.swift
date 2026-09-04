import SwiftUI

enum VersoButtonVariant {
    case primary
    case secondary
    case text
    case icon
}

struct VersoButtonStyle: ButtonStyle {
    let variant: VersoButtonVariant
    let theme: ThemeColors
    var isActive: Bool = false

    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        switch variant {
        case .primary:
            configuration.label
                .font(VersoTypography.UI.button)
                .foregroundColor(isEnabled ? theme.background : theme.textSecondary)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(isEnabled ? theme.accent : theme.surface)
                .cornerRadius(VersoRadius.md)
                .overlay(
                    RoundedRectangle(cornerRadius: VersoRadius.md)
                        .stroke(theme.border, lineWidth: isEnabled ? 0 : 1)
                )
                .opacity(configuration.isPressed ? 0.8 : 1)

        case .secondary:
            configuration.label
                .font(VersoTypography.UI.button)
                .foregroundColor(theme.accent)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.clear)
                .cornerRadius(VersoRadius.md)
                .overlay(
                    RoundedRectangle(cornerRadius: VersoRadius.md)
                        .stroke(theme.accent, lineWidth: 1.5)
                )
                .opacity(configuration.isPressed ? 0.7 : 1)

        case .text:
            configuration.label
                .font(VersoTypography.UI.button)
                .foregroundColor(theme.accent)
                .frame(minWidth: 44, minHeight: 44)
                .opacity(configuration.isPressed ? 0.6 : 1)

        case .icon:
            configuration.label
                .font(.system(size: 24))
                .foregroundColor(isActive ? theme.accent : theme.textSecondary)
                .frame(width: 44, height: 44)
                .opacity(configuration.isPressed ? 0.6 : 1)
        }
    }
}

#Preview {
    let theme = ThemeColors.paper

    return VStack(spacing: 24) {
        Button("Save Article") {}
            .buttonStyle(VersoButtonStyle(variant: .primary, theme: theme))

        Button("Save Article") {}
            .buttonStyle(VersoButtonStyle(variant: .primary, theme: theme))
            .disabled(true)

        Button("Add to Library") {}
            .buttonStyle(VersoButtonStyle(variant: .secondary, theme: theme))

        Button("Learn more") {}
            .buttonStyle(VersoButtonStyle(variant: .text, theme: theme))

        HStack(spacing: 16) {
            Button { } label: { Image(systemName: "bookmark") }
                .buttonStyle(VersoButtonStyle(variant: .icon, theme: theme))
            Button { } label: { Image(systemName: "bookmark.fill") }
                .buttonStyle(VersoButtonStyle(variant: .icon, theme: theme, isActive: true))
        }
    }
    .padding()
}
