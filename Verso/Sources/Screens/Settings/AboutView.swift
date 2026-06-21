import SwiftUI

struct AboutView: View {
    @EnvironmentObject var themeManager: ThemeManager

    private var colors: ThemeColors { themeManager.colors }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
    }

    private let githubURL = URL(string: "https://github.com/whysasse/verso-app")!

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header
                Divider().background(colors.border).padding(.horizontal, VersoSpacing.md)
                links
            }
        }
        .background(colors.background.ignoresSafeArea())
        .versoNavigationBar(title: L10n.About.navTitle)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: VersoSpacing.xs) {
            Text(L10n.About.brandName)
                .font(VersoTypography.UI.screenTitle)
                .foregroundColor(colors.textPrimary)

            Text(L10n.About.versionLabel(version: appVersion))
                .font(VersoTypography.UI.caption)
                .foregroundColor(colors.textSecondary)

            Text(L10n.About.description)
                .font(VersoTypography.UI.listSubtitle)
                .foregroundColor(colors.textSecondary)
                .padding(.top, VersoSpacing.xxs)
        }
        .padding(.horizontal, VersoSpacing.md)
        .padding(.top, VersoSpacing.lg)
        .padding(.bottom, VersoSpacing.md)
    }

    private var links: some View {
        VStack(spacing: 0) {
            NavigationLink(destination: InAppWebView(url: githubURL, title: L10n.About.githubLinkLabel)) {
                HStack {
                    Text(L10n.About.githubLinkLabel)
                        .font(VersoTypography.UI.input)
                        .foregroundColor(colors.textPrimary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(colors.textSecondary)
                }
                .frame(minHeight: 44)
                .padding(.horizontal, VersoSpacing.md)
            }
            .buttonStyle(.plain)

            Divider().background(colors.border).padding(.horizontal, VersoSpacing.md)

            NavigationLink(destination: PrivacyPolicyView()) {
                HStack {
                    Text(L10n.About.privacyPolicyLinkLabel)
                        .font(VersoTypography.UI.input)
                        .foregroundColor(colors.textPrimary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(colors.textSecondary)
                }
                .frame(minHeight: 44)
                .padding(.horizontal, VersoSpacing.md)
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
    .environmentObject(ThemeManager())
}
