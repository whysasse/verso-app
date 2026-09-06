import SwiftUI

struct OnboardingFolderPickerView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var folderBookmarkService: FolderBookmarkService
    let onNext: () -> Void

    @State private var showDocumentPicker = false

    private var colors: ThemeColors { themeManager.colors }
    private var folderSelected: Bool { folderBookmarkService.folderURL != nil }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: VersoSpacing.lg) {
                ZStack {
                    Circle()
                        .fill(colors.surface)
                        .overlay(Circle().stroke(colors.border, lineWidth: 1))
                        .frame(width: 64, height: 64)

                    // FAB-328: was Text("☁"), which renders as a colour emoji (a shaded
                    // 3D cloud) -- .foregroundColor does nothing to it, so it broke the
                    // crisp accent-tinted SF Symbol language every neighboring screen uses.
                    Image(systemName: "icloud")
                        .font(.system(size: 28))
                        .foregroundColor(colors.textSecondary)
                }

                VStack(spacing: VersoSpacing.sm) {
                    Text(L10n.Onboarding.folderHeadline)
                        .font(VersoTypography.UI.screenTitle)
                        .foregroundColor(colors.textPrimary)
                        .multilineTextAlignment(.center)

                    Text(L10n.Onboarding.folderSubheadline)
                        .font(VersoTypography.UI.listSubtitle)
                        .foregroundColor(colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, VersoSpacing.md)
                }

                Button {
                    showDocumentPicker = true
                } label: {
                    HStack {
                        Text(folderSelected ? folderBookmarkService.folderURL!.lastPathComponent : L10n.Onboarding.folderChooseCta)
                            .font(VersoTypography.UI.listSubtitle)
                            .foregroundColor(folderSelected ? colors.textPrimary : colors.textSecondary)
                        Spacer()
                        // FAB-328: was Text("›"), a thin typographic mark visibly
                        // different from the real chevron used elsewhere (QuickTourView,
                        // SettingsRow.folderRow) for the same "tap to pick" affordance.
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(colors.textSecondary)
                    }
                    .padding(.horizontal, VersoSpacing.md)
                    .frame(height: 52)
                    .background(colors.surface)
                    .cornerRadius(VersoRadius.md)
                    .overlay(RoundedRectangle(cornerRadius: VersoRadius.md).stroke(colors.border, lineWidth: 1))
                }
                .buttonStyle(.plain)
                .tint(.clear)

                Text(L10n.Onboarding.folderObsidianTip)
                    .font(VersoTypography.UI.caption)
                    .foregroundColor(colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, VersoSpacing.md)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, VersoSpacing.lg)

            Spacer()

            VStack(spacing: VersoSpacing.sm) {
                Button(L10n.Onboarding.folderContinueCta) {
                    AnalyticsService.shared.track("onboarding.stepCompleted", parameters: ["step": "folder_picker"])
                    onNext()
                }
                .buttonStyle(VersoButtonStyle(variant: .primary, theme: colors))
                .disabled(!folderSelected)

                // FAB-328: Continue disables until a folder is chosen, but nothing on
                // screen said why. Swaps the always-shown privacy note for that
                // explanation while it's actually relevant, reverting once a folder is
                // picked -- one caption line either way, not two stacked strings.
                Text(folderSelected ? L10n.Onboarding.folderPrivacyNote : L10n.Onboarding.folderContinueDisabledHint)
                    .font(VersoTypography.UI.caption)
                    .foregroundColor(colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, VersoSpacing.md)
            }
            .padding(.horizontal, VersoSpacing.lg)
            .padding(.bottom, VersoSpacing.xl)
        }
        .sheet(isPresented: $showDocumentPicker) {
            DocumentPicker { urls in
                guard let url = urls.first else { return }
                folderBookmarkService.save(url: url)
                showDocumentPicker = false
            }
        }
    }
}

#Preview {
    struct Preview: View {
        @StateObject private var themeManager = ThemeManager()
        @StateObject private var folderBookmarkService = FolderBookmarkService()
        var body: some View {
            OnboardingFolderPickerView(onNext: {})
                .environmentObject(themeManager)
                .environmentObject(folderBookmarkService)
                .background(themeManager.colors.background.ignoresSafeArea())
        }
    }
    return Preview()
}
