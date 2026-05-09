import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let onNext: () -> Void

    private var colors: ThemeColors { themeManager.colors }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: VersoSpacing.lg) {
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 64))
                    .foregroundColor(colors.accent)

                VStack(spacing: VersoSpacing.sm) {
                    Text("Your articles.\nYour files.")
                        .font(VersoTypography.UI.screenTitle)
                        .foregroundColor(colors.textPrimary)
                        .multilineTextAlignment(.center)

                    Text("Save any article, read on your terms.")
                        .font(VersoTypography.UI.listSubtitle)
                        .foregroundColor(colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }

            Spacer()

            Button("Get Started", action: onNext)
                .buttonStyle(VersoButtonStyle(variant: .primary, theme: colors))
                .padding(.horizontal, VersoSpacing.lg)
                .padding(.bottom, VersoSpacing.xl)
        }
    }
}

#Preview {
    struct Preview: View {
        @StateObject private var themeManager = ThemeManager()
        var body: some View {
            WelcomeView(onNext: {})
                .environmentObject(themeManager)
                .background(themeManager.colors.background.ignoresSafeArea())
        }
    }
    return Preview()
}
