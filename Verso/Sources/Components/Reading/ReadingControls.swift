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

    private var currentBodySize: VersoTypography.Reading.BodySize {
        .nearest(to: fontSize)
    }

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
            .padding(.bottom, VersoSpacing.md)

            // The sheet's presentation detent is a fixed height that doesn't
            // always exactly match this content's natural height; without this,
            // any leftover space at the bottom shows through uncolored instead
            // of the sheet's surface. Push content to the top and let the
            // surface color fill whatever's left below it.
            Spacer(minLength: 0)
        }
        .frame(maxHeight: .infinity, alignment: .top)
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
                Text(L10n.Reading.controlsSheetFontSizeLabel)
                    .font(VersoTypography.UI.listSubtitle)
                    .foregroundColor(colors.textSecondary)
                Spacer()
                HStack(spacing: VersoSpacing.sm) {
                    fontSizeStepButton(
                        glyphSize: 14,
                        accessibilityLabel: L10n.Reading.controlsDecreaseFontSize,
                        action: { fontSize = currentBodySize.stepped(by: -1).rawValue }
                    )

                    Text("\(Int(fontSize))")
                        .font(VersoTypography.UI.listTitle)
                        .foregroundColor(colors.textPrimary)
                        .frame(minWidth: 28, alignment: .center)

                    fontSizeStepButton(
                        glyphSize: 20,
                        accessibilityLabel: L10n.Reading.controlsIncreaseFontSize,
                        action: { fontSize = currentBodySize.stepped(by: 1).rawValue }
                    )
                }
            }

            HStack {
                Text(L10n.Reading.controlsSheetLineSpacingLabel)
                    .font(VersoTypography.UI.listSubtitle)
                    .foregroundColor(colors.textSecondary)
                Spacer()
                HStack(spacing: VersoSpacing.xs) {
                    ForEach(0..<4) { index in
                        Button {
                            lineSpacing = index
                        } label: {
                            LineSpacingBarsIcon(
                                barCount: lineSpacingBarCount(for: index),
                                color: lineSpacing == index ? colors.accent : colors.textSecondary
                            )
                            .frame(width: 44, height: 44)
                            .background(
                                RoundedRectangle(cornerRadius: VersoRadius.sm)
                                    .fill(lineSpacing == index ? colors.accentSurface : Color.clear)
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(lineSpacingLabel(for: index))
                        .accessibilityAddTraits(lineSpacing == index ? .isSelected : [])
                    }
                }
            }
        }
    }

    /// Small "A" / big "A" button, each in its own filled, bordered 44×44
    /// container — the affordance Safari's own Reader font-size control uses.
    /// Both ends of the scale look the same: tapping past the limit is a
    /// harmless no-op (`BodySize.stepped(by:)` clamps), not a disabled state.
    private func fontSizeStepButton(
        glyphSize: CGFloat,
        accessibilityLabel: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text("A")
                .font(.system(size: glyphSize, weight: .semibold))
                .foregroundColor(colors.accent)
                .frame(width: 44, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: VersoRadius.sm)
                        .fill(colors.background)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: VersoRadius.sm)
                        .stroke(colors.border, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }

    /// Bar counts mirror the four Material Symbols icons Fabio picked
    /// (format_align_justify → density_small → density_medium → density_large):
    /// more, tighter-packed bars read as denser/compact spacing, fewer and
    /// wider-spaced bars read as airier spacing.
    private func lineSpacingBarCount(for index: Int) -> Int {
        switch index {
        case 0:  return 5  // Compact
        case 1:  return 4  // Normal
        case 2:  return 3  // Relaxed
        default: return 2  // Airy
        }
    }

    private func lineSpacingLabel(for index: Int) -> String {
        switch index {
        case 0:  return L10n.ReaderSettings.lineSpacingCompact
        case 1:  return L10n.ReaderSettings.lineSpacingNormal
        case 2:  return L10n.ReaderSettings.lineSpacingRelaxed
        default: return L10n.ReaderSettings.lineSpacingAiry
        }
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

/// A small stack of horizontal bars representing a line-spacing density
/// level — redraws the four Material Symbols icons (format_align_justify,
/// density_small/medium/large) as themable vector bars instead of bundling
/// them as fixed-color image assets, so they tint correctly in all 4 themes.
private struct LineSpacingBarsIcon: View {
    private static let height: CGFloat = 18
    private static let barWidth: CGFloat = 20
    private static let barThickness: CGFloat = 2

    let barCount: Int
    let color: Color

    private var gap: CGFloat {
        guard barCount > 1 else { return 0 }
        return (Self.height - CGFloat(barCount) * Self.barThickness) / CGFloat(barCount - 1)
    }

    var body: some View {
        VStack(spacing: gap) {
            ForEach(0..<barCount, id: \.self) { _ in
                Capsule()
                    .fill(color)
                    .frame(width: Self.barWidth, height: Self.barThickness)
            }
        }
        .frame(height: Self.height)
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

            Text(theme.displayName)
                .font(.system(size: 11))
                .foregroundColor(colors.textSecondary)
        }
    }
}

private struct ReadingControlsPreview: View {
    @State var fontSize: CGFloat = 18
    @State var lineSpacing = 1

    var body: some View {
        VStack {
            Spacer()
            ReadingControls(variant: .font, fontSize: $fontSize, lineSpacing: $lineSpacing)
                .environmentObject(ThemeManager())
        }
        .background(Color.gray.opacity(0.2))
    }
}

#Preview {
    ReadingControlsPreview()
}
