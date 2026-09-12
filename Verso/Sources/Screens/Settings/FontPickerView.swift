import SwiftUI

/// FAB-334 phase 3: destination for Settings' "Font" value+chevron row. Same 4
/// options and preview-text row that used to render inline via `SettingsRow.font`;
/// only the presentation moved from an always-visible list to a pushed screen with
/// a native checkmark per row.
struct FontPickerView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var readingPreferences: ReadingPreferencesService
    private var colors: ThemeColors { themeManager.colors }

    private let availableFonts: [(name: String, displayName: String)] = [
        ("Georgia", "Georgia"),
        ("NewYork", "New York"),
        ("OpenDyslexic-Regular", "OpenDyslexic"),
        ("", "System"),
    ]

    var body: some View {
        Form {
            Section {
                ForEach(availableFonts, id: \.name) { font in
                    let isSelected = readingPreferences.fontFamily == font.name
                    Button {
                        readingPreferences.fontFamily = font.name
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: VersoSpacing.xxs) {
                                Text(font.displayName)
                                    .font(font.name.isEmpty ? .system(size: 17, weight: .semibold) : .custom(font.name, size: 17).weight(.semibold))
                                    .foregroundColor(colors.textPrimary)
                                Text(L10n.Settings.fontPreview)
                                    .font(font.name.isEmpty ? .system(size: 15) : .custom(font.name, size: 15))
                                    .foregroundColor(colors.textSecondary)
                            }
                            Spacer()
                            if isSelected {
                                Image(systemName: "checkmark")
                                    .foregroundColor(colors.accent)
                            }
                        }
                        .padding(.vertical, VersoSpacing.xxs)
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(isSelected ? .isSelected : [])
                }
            }
        }
        .navigationTitle(L10n.Settings.fontSectionLabel)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        FontPickerView()
    }
    .environmentObject(ThemeManager())
    .environmentObject(ReadingPreferencesService())
}
