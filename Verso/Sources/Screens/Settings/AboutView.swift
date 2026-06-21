import SwiftUI

struct AboutView: View {
    @EnvironmentObject var themeManager: ThemeManager

    private var colors: ThemeColors { themeManager.colors }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
    }

    private var appBuild: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
    }

    private let githubURL = URL(string: "https://github.com/whysasse/verso-app")!

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    rows
                    footer
                }
            }

            Spacer()
        }
        .background(colors.background.ignoresSafeArea())
        .versoNavigationBar(title: L10n.About.title)
    }

    private var rows: some View {
        VStack(spacing: 0) {
            // Version
            HStack {
                Text(L10n.About.versionRowLabel)
                    .font(VersoTypography.UI.input)
                    .foregroundColor(colors.textPrimary)
                Spacer()
                Text("\(appVersion) (\(appBuild))")
                    .font(VersoTypography.UI.listSubtitle)
                    .foregroundColor(colors.textSecondary)
            }
            .frame(minHeight: 44)
            .padding(.horizontal, VersoSpacing.md)

            Divider().background(colors.border).padding(.horizontal, VersoSpacing.md)

            // Acknowledgements
            NavigationLink(destination: AcknowledgementsView()) {
                HStack {
                    Text(L10n.About.acknowledgementsRowLabel)
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

            // GitHub
            NavigationLink(destination: InAppWebView(url: githubURL, title: L10n.About.githubRowLabel)) {
                HStack {
                    Text(L10n.About.githubRowLabel)
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

            // Privacy Policy
            NavigationLink(destination: PrivacyPolicyView()) {
                HStack {
                    Text(L10n.About.privacyPolicyRowLabel)
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

    private var footer: some View {
        Text(L10n.About.footer(version: appVersion))
            .font(VersoTypography.UI.caption)
            .foregroundColor(colors.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, VersoSpacing.lg)
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
    .environmentObject(ThemeManager())
}
