import SwiftUI

struct LaunchView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        themeManager.colors.background
            .ignoresSafeArea()
            .overlay {
                Text("Verso")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(themeManager.colors.textPrimary)
            }
    }
}
