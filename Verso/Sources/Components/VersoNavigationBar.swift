import SwiftUI

/// Icon-only control matching article list toolbar styling: plain button, no system tint, accent foreground.
struct VersoToolbarIconButton: View {
    let systemName: String
    let accent: Color
    let action: () -> Void

    /// Pass `nil` to use the default symbol metrics (navigation bar).
    var iconPointSize: CGFloat? = nil
    var labelWidth: CGFloat? = nil
    var labelHeight: CGFloat? = nil
    var accessibilityLabel: String? = nil
    var accessibilityHint: String? = nil

    var body: some View {
        Button(action: action) {
            Group {
                if let pt = iconPointSize {
                    Image(systemName: systemName)
                        .font(.system(size: pt))
                        .foregroundColor(accent)
                } else {
                    Image(systemName: systemName)
                        .foregroundColor(accent)
                }
            }
            .optionalFrame(width: labelWidth, height: labelHeight)
        }
        .buttonStyle(.plain)
        .tint(.clear)
        .optionalAccessibilityLabel(accessibilityLabel)
        .optionalAccessibilityHint(accessibilityHint)
    }
}

private extension View {
    @ViewBuilder
    func optionalFrame(width: CGFloat?, height: CGFloat?) -> some View {
        if let width, let height {
            self.frame(width: width, height: height)
        } else {
            self
        }
    }

    @ViewBuilder
    func optionalAccessibilityLabel(_ label: String?) -> some View {
        if let label {
            self.accessibilityLabel(label)
        } else {
            self
        }
    }

    @ViewBuilder
    func optionalAccessibilityHint(_ hint: String?) -> some View {
        if let hint {
            self.accessibilityHint(hint)
        } else {
            self
        }
    }
}

struct VersoNavigationBar: ViewModifier {
    let title: String
    var trailingIcon: String = "plus.circle"
    var trailingAction: (() -> Void)? = nil
    @EnvironmentObject var themeManager: ThemeManager

    func body(content: Content) -> some View {
        content
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(themeManager.colors.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                if let action = trailingAction {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        VersoToolbarIconButton(
                            systemName: trailingIcon,
                            accent: themeManager.colors.accent,
                            action: action
                        )
                    }
                }
            }
    }
}

extension View {
    func versoNavigationBar(
        title: String,
        trailingIcon: String = "plus.circle",
        trailingAction: (() -> Void)? = nil
    ) -> some View {
        modifier(VersoNavigationBar(title: title, trailingIcon: trailingIcon, trailingAction: trailingAction))
    }
}
