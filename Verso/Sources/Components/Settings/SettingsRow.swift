import SwiftUI

enum SettingsRowType {
    case `default`(label: String)
    case folder(label: String, path: String)
    case font(name: String, preview: String, isSelected: Bool)
    case theme
}

struct SettingsRow: View {
    let type: SettingsRowType
    var action: () -> Void = {}
    @EnvironmentObject var themeManager: ThemeManager
    private var colors: ThemeColors { themeManager.colors }

    var body: some View {
        Button(action: action) {
            switch type {
            case .default(let label):
                defaultRow(label: label)
            case .folder(let label, let path):
                folderRow(label: label, path: path)
            case .font(let name, let preview, let isSelected):
                fontRow(name: name, preview: preview, isSelected: isSelected)
            case .theme:
                ThemeSelector()
            }
        }
        .buttonStyle(.plain)
    }

    private func defaultRow(label: String) -> some View {
        HStack {
            Text(label)
                .font(VersoTypography.UI.input)
                .foregroundColor(colors.textPrimary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(colors.textSecondary)
        }
        .frame(minHeight: 44)
    }

    private func folderRow(label: String, path: String) -> some View {
        HStack {
            Text(label)
                .font(VersoTypography.UI.input)
                .foregroundColor(colors.textPrimary)
            Spacer()
            Text(path)
                .font(VersoTypography.UI.listSubtitle)
                .foregroundColor(colors.textSecondary)
                .lineLimit(1)
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(colors.textSecondary)
        }
        .frame(minHeight: 44)
    }

    private func fontRow(name: String, preview: String, isSelected: Bool) -> some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: VersoSpacing.xxs) {
                Text(name)
                    .font(.custom(name, size: 17).weight(.semibold))
                    .foregroundColor(colors.textPrimary)

                Text(preview)
                    .font(.custom(name, size: 15))
                    .foregroundColor(colors.textSecondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(minHeight: 78)

            if isSelected {
                Circle()
                    .fill(colors.accent)
                    .frame(width: 8, height: 8)
            }
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        SettingsRow(type: .default(label: "Notifications"))
        Divider()
        SettingsRow(type: .folder(label: "Articles folder", path: "~/iCloud Drive/Verso"))
        Divider()
        SettingsRow(type: .font(name: "Georgia", preview: "The quick brown fox jumps over the lazy dog", isSelected: true))
        Divider()
        SettingsRow(type: .font(name: "New York", preview: "The quick brown fox jumps over the lazy dog", isSelected: false))
        Divider()
        SettingsRow(type: .theme)
    }
    .padding(.horizontal, VersoSpacing.md)
    .environmentObject(ThemeManager())
}
