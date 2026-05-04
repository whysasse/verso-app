import SwiftUI

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
            .preferredColorScheme(themeManager.currentTheme.isDark ? .dark : .light)
            .toolbar {
                if let action = trailingAction {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: action) {
                            Image(systemName: trailingIcon)
                                .font(.system(size: 20))
                                .foregroundColor(themeManager.colors.accent)
                        }
                        .buttonStyle(.plain)
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
