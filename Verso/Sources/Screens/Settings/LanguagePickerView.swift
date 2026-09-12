import SwiftUI

/// FAB-334 phase 3: destination for Settings' "Language" value+chevron row.
struct LanguagePickerView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localeManager: LocaleManager
    let onSelect: (AppLocale) -> Void
    private var colors: ThemeColors { themeManager.colors }

    var body: some View {
        Form {
            Section {
                ForEach(AppLocale.allCases) { locale in
                    let isSelected = localeManager.selectedLocale == locale
                    Button {
                        guard !isSelected else { return }
                        localeManager.selectedLocale = locale
                        onSelect(locale)
                    } label: {
                        HStack {
                            Text(locale.displayName)
                                .foregroundColor(colors.textPrimary)
                            Spacer()
                            if isSelected {
                                Image(systemName: "checkmark")
                                    .foregroundColor(colors.accent)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(isSelected ? .isSelected : [])
                }
            }
        }
        .navigationTitle(L10n.Settings.languageSectionLabel)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        LanguagePickerView(onSelect: { _ in })
    }
    .environmentObject(ThemeManager())
    .environmentObject(LocaleManager())
}
