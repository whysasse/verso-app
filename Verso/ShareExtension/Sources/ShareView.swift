import SwiftUI

/// FAB-323: reads the theme the user actually picked in the app. `ThemeManager` itself
/// stays main-app-only (it's an `ObservableObject` with no reason to live here), but it
/// mirrors `selectedTheme` into the App Group suite specifically for this -- extensions
/// don't share `UserDefaults.standard` with the host app. Falls back to `.paper`,
/// matching `ThemeManager`'s own default.
enum SharedTheme {
    static var current: VersoTheme {
        let raw = UserDefaults(suiteName: AppConstants.appGroupID)?.string(forKey: AppConstants.selectedThemeKey)
        return VersoTheme(rawValue: raw ?? "Paper") ?? .paper
    }
    static var colors: ThemeColors { ThemeColors.colors(for: current) }
    static var semanticColors: SemanticColors { SemanticColors.semanticColors(for: current) }
}

struct ShareView: View {
    @ObservedObject var viewModel: ShareViewModel
    let extensionContext: NSExtensionContext?
    private let colors = SharedTheme.colors
    private let semanticColors = SharedTheme.semanticColors

    var body: some View {
        ZStack(alignment: .top) {
            colors.background.ignoresSafeArea()

            VStack(spacing: 16) {
                switch viewModel.state {
                case .idle, .saving:
                    savingView

                case .duplicatePrompt(let pending, let existingPath, let existingTitle):
                    duplicatePromptView(
                        pending: pending,
                        existingTitle: existingTitle,
                        existingPath: existingPath
                    )

                case .success(let title, let isUpdate):
                    successView(title: title, isUpdate: isUpdate)
                        .task {
                            try? await Task.sleep(nanoseconds: 1_500_000_000)
                            extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
                        }

                case .failure(let url):
                    failureView(url: url)
                }
            }
            .padding(24)
            .padding(.top, 24)
            .frame(maxWidth: 480)
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - State views

    private var savingView: some View {
        VStack(spacing: 12) {
            ProgressView()
                .tint(colors.accent)
                .scaleEffect(1.2)
            Text(L10n.AddArticle.savingMessage)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(colors.textSecondary)
        }
        .frame(minHeight: 80)
    }

    private func duplicatePromptView(pending: PendingArticle, existingTitle: String, existingPath: String) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(L10n.Share.duplicateHeadline)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(colors.textPrimary)

            Text(L10n.Share.duplicateSubheadline(existingTitle: existingTitle))
                .font(.system(size: 15))
                .foregroundStyle(colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 10) {
                Button {
                    viewModel.chooseUpdateExisting(pending: pending, existingPath: existingPath)
                } label: {
                    Text(L10n.Share.duplicateUpdateExisting)
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(colors.accent)
                        // Matches VersoButtonStyle.primary's contrast fix (FAB-305) — accent
                        // isn't reliably light enough for literal white in every theme.
                        .foregroundStyle(colors.background)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .buttonStyle(.plain)

                Button {
                    viewModel.chooseSaveCopy(pending: pending)
                } label: {
                    Text(L10n.Share.duplicateSaveCopy)
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(colors.surface)
                        .foregroundStyle(colors.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(colors.border, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)

                Button(L10n.Share.cancel) {
                    extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
                }
                .font(.system(size: 15))
                .foregroundStyle(colors.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.top, 4)
            }
        }
        .frame(minHeight: 120)
    }

    private func successView(title: String, isUpdate: Bool) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 36))
                .foregroundStyle(semanticColors.success)
            Text(isUpdate ? L10n.Share.duplicateSuccessUpdated : L10n.Share.duplicateSuccessSaved)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(colors.textPrimary)
            Text(title)
                .font(.system(size: 13))
                .foregroundStyle(colors.textSecondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .truncationMode(.tail)
        }
        .frame(minHeight: 80)
    }

    private func failureView(url: URL) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.circle")
                .font(.system(size: 36))
                .foregroundStyle(colors.textSecondary)
            Text(L10n.Share.errorHeadline)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(colors.textPrimary)
            HStack(spacing: 16) {
                Button(L10n.Share.errorDismiss) {
                    extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
                }
                .font(.system(size: 15))
                .foregroundStyle(colors.textSecondary)

                Link(L10n.Share.errorOpenInSafari, destination: url)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(colors.accent)
            }
        }
        .frame(minHeight: 80)
    }
}
