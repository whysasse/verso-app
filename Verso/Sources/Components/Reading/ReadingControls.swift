import SwiftUI

struct ReadingControls: View {
    enum Variant {
        case font
        case theme
    }

    let variant: Variant
    @Binding var fontSize: CGFloat
    @Binding var lineSpacing: Int
    @EnvironmentObject var themeManager: ThemeManager
    private var colors: ThemeColors { themeManager.colors }

    var body: some View {
        VStack(spacing: 0) {
            dragHandle
                .padding(.top, VersoSpacing.md)

            Group {
                switch variant {
                case .font:  fontControls
                case .theme: themeControls
                }
            }
            .padding(.horizontal, VersoSpacing.lg)
            .padding(.top, VersoSpacing.md)
            .padding(.bottom, 28)
        }
        .background(colors.surface)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(colors.border),
            alignment: .top
        )
        .clipShape(UnevenRoundedRectangle(topLeadingRadius: VersoRadius.lg, topTrailingRadius: VersoRadius.lg))
    }

    private var dragHandle: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(colors.border)
            .frame(width: 36, height: 4)
    }

    private var fontControls: some View {
        VStack(spacing: VersoSpacing.lg) {
            HStack {
                Text("Font size")
                    .font(VersoTypography.UI.listSubtitle)
                    .foregroundColor(colors.textSecondary)
                Spacer()
                HStack(spacing: VersoSpacing.lg) {
                    Button {
                        fontSize = max(14, fontSize - 1)
                    } label: {
                        Text("A")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(colors.accent)
                    }
                    .buttonStyle(.plain)

                    Text("\(Int(fontSize))")
                        .font(VersoTypography.UI.listTitle)
                        .foregroundColor(colors.textPrimary)
                        .frame(minWidth: 28, alignment: .center)

                    Button {
                        fontSize = min(26, fontSize + 1)
                    } label: {
                        Text("A")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(colors.accent)
                    }
                    .buttonStyle(.plain)
                }
            }

            HStack {
                Text("Line spacing")
                    .font(VersoTypography.UI.listSubtitle)
                    .foregroundColor(colors.textSecondary)
                Spacer()
                HStack(spacing: VersoSpacing.xs) {
                    ForEach(0..<4) { index in
                        Button {
                            lineSpacing = index
                        } label: {
                            Image(systemName: spacingIcon(for: index))
                                .font(.system(size: 18))
                                .foregroundColor(lineSpacing == index ? colors.accent : colors.textSecondary)
                                .frame(width: 44, height: 36)
                                .background(
                                    RoundedRectangle(cornerRadius: VersoRadius.sm)
                                        .fill(lineSpacing == index ? colors.accentSurface : Color.clear)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func spacingIcon(for index: Int) -> String {
        ["text.alignleft", "text.justify", "text.justify.leading", "text.justify.trailing"][index]
    }

    private var themeControls: some View {
        HStack(spacing: 0) {
            ForEach(VersoTheme.allCases) { theme in
                Button {
                    themeManager.currentTheme = theme
                } label: {
                    ThemeChipView(theme: theme, isSelected: themeManager.currentTheme == theme, colors: colors)
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
            }
        }
    }
}

private struct ThemeChipView: View {
    let theme: VersoTheme
    let isSelected: Bool
    let colors: ThemeColors

    private var swatchColor: Color {
        switch theme {
        case .paper: return Color(hex: "F5F0E8")
        case .sepia: return Color(hex: "F2E8D5")
        case .night: return Color(hex: "1C1A16")
        case .ink:   return Color(hex: "111418")
        }
    }

    var body: some View {
        VStack(spacing: VersoSpacing.xs) {
            RoundedRectangle(cornerRadius: 8)
                .fill(swatchColor)
                .frame(height: 32)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? colors.accent : colors.border, lineWidth: isSelected ? 2 : 1)
                )

            Text(theme.rawValue)
                .font(.system(size: 11))
                .foregroundColor(colors.textSecondary)
        }
    }
}

#Preview {
    @Previewable @State var fontSize: CGFloat = 18
    @Previewable @State var lineSpacing = 1

    VStack {
        Spacer()
        ReadingControls(variant: .font, fontSize: $fontSize, lineSpacing: $lineSpacing)
            .environmentObject(ThemeManager())
    }
    .background(Color.gray.opacity(0.2))
}
