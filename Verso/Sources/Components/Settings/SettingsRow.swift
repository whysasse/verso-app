import SwiftUI

enum SettingsRowType {
    case `default`(label: String)
    case folder(label: String, path: String)
    case font(name: String, preview: String, isSelected: Bool)
    case theme
    case language(name: String, isSelected: Bool)
}

struct SettingsRow: View {
    let type: SettingsRowType
    var action: () -> Void = {}
    /// When `false`, the row is not its own button so an outer `NavigationLink` can receive taps (FAB-137).
    var usesButtonChrome: Bool = true
    @EnvironmentObject var themeManager: ThemeManager
    private var colors: ThemeColors { themeManager.colors }

    var body: some View {
        Group {
            if usesButtonChrome {
                Button(action: action) { rowBody }
                    .buttonStyle(.plain)
            } else {
                rowBody
            }
        }
    }

    @ViewBuilder
    private var rowBody: some View {
        switch type {
        case .default(let label):
            defaultRow(label: label)
        case .folder(let label, let path):
            folderRow(label: label, path: path)
        case .font(let name, let preview, let isSelected):
            fontRow(name: name, preview: preview, isSelected: isSelected)
        case .theme:
            ThemeSelector()
        case .language(let name, let isSelected):
            languageRow(name: name, isSelected: isSelected)
        }
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
        HStack(alignment: .center, spacing: VersoSpacing.md) {
            VStack(alignment: .leading, spacing: VersoSpacing.xxs) {
                Text(name)
                    .font(name.isEmpty ? .system(size: 17, weight: .semibold) : .custom(name, size: 17).weight(.semibold))
                    .foregroundColor(colors.textPrimary)

                Text(preview)
                    .font(name.isEmpty ? .system(size: 15) : .custom(name, size: 15))
                    .foregroundColor(colors.textSecondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if isSelected {
                Circle()
                    .fill(colors.accent)
                    .frame(width: 8, height: 8)
            }
        }
        .frame(minHeight: 78)
    }

    private func languageRow(name: String, isSelected: Bool) -> some View {
        HStack {
            Text(name)
                .font(VersoTypography.UI.input)
                .foregroundColor(colors.textPrimary)
            Spacer()
            if isSelected {
                Circle()
                    .fill(colors.accent)
                    .frame(width: 8, height: 8)
            }
        }
        .frame(minHeight: 44)
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
