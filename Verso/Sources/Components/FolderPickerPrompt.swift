import SwiftUI

struct FolderPickerPrompt: View {
    let onChoose: () -> Void
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        VStack(spacing: VersoSpacing.sm) {
            Image(systemName: "folder.badge.plus")
                .font(.system(size: 32))
                .foregroundColor(themeManager.colors.accent)

            Text("No folder selected")
                .font(VersoTypography.UI.listTitle)
                .foregroundColor(themeManager.colors.textPrimary)

            Text("Choose an iCloud Drive folder where your articles will be stored.")
                .font(VersoTypography.UI.caption)
                .foregroundColor(themeManager.colors.textSecondary)
                .multilineTextAlignment(.center)

            Button(action: onChoose) {
                Text("Choose a folder to get started")
                    .font(VersoTypography.UI.button)
                    .foregroundColor(themeManager.colors.background)
                    .padding(.horizontal, VersoSpacing.md)
                    .padding(.vertical, VersoSpacing.sm)
                    .background(themeManager.colors.accent)
                    .cornerRadius(VersoRadius.pill)
            }
            .buttonStyle(.plain)
            .tint(.clear)
            .padding(.top, VersoSpacing.xs)
        }
        .padding(VersoSpacing.md)
        .frame(maxWidth: .infinity)
        .background(themeManager.colors.surface)
        .cornerRadius(VersoRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: VersoRadius.md)
                .stroke(themeManager.colors.border, lineWidth: 1)
        )
    }
}
