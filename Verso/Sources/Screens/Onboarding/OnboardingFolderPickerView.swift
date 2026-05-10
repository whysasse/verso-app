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

                    Text("☁")
                        .font(.system(size: 28))
                        .foregroundColor(colors.textSecondary)
                }

                VStack(spacing: VersoSpacing.sm) {
                    Text("Where should Verso save your articles?")
                        .font(VersoTypography.UI.screenTitle)
                        .foregroundColor(colors.textPrimary)
                        .multilineTextAlignment(.center)

                    Text("Pick a folder in iCloud Drive. Articles are saved as Markdown files — yours to keep.")
                        .font(VersoTypography.UI.listSubtitle)
                        .foregroundColor(colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, VersoSpacing.md)
                }

                Button {
                    showDocumentPicker = true
                } label: {
                    HStack {
                        Text(folderSelected ? folderBookmarkService.folderURL!.lastPathComponent : "Choose folder…")
                            .font(VersoTypography.UI.listSubtitle)
                            .foregroundColor(folderSelected ? colors.textPrimary : colors.textSecondary)
                        Spacer()
                        Text("›")
                            .font(.system(size: 20))
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
            }
            .padding(.horizontal, VersoSpacing.lg)

            Spacer()

            VStack(spacing: VersoSpacing.sm) {
                Button("Continue") {
                    AnalyticsService.shared.track("onboarding.stepCompleted", parameters: ["step": "folder_picker"])
                    onNext()
                }
                .buttonStyle(VersoButtonStyle(variant: .primary, theme: colors))
                .disabled(!folderSelected)
                .opacity(folderSelected ? 1 : 0.5)

                Text("Verso never uploads your files. They live in your iCloud Drive.")
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
