import SwiftUI

// FAB-334 phase 4: split out of VersoNavigationBar.swift (deleted). That file bundled
// this button with the VersoNavigationBar modifier -- phase 1 tried to delete the
// whole file as "dead code" and broke the build, because this component is very much
// alive: ReadingChrome (out of scope for the whole epic) and AddArticleView/ImportView
// all depend on it. It survives here on its own, unrelated to the navigation-bar
// chrome the rest of the file existed for.

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
