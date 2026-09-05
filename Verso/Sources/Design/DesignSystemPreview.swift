// DesignSystemPreview.swift
// Verso — Design System Foundations
// FAB-92
//
// Open this file in Xcode and use the Canvas (Cmd+Option+Return) to preview
// the full design system across all themes. Not included in the production build.

import SwiftUI

// MARK: - Main Preview

struct DesignSystemPreview: View {
    @State private var selectedTheme: VersoTheme = .paper

    private var colors: ThemeColors { ThemeColors.colors(for: selectedTheme) }
    private var statusPalette: ArticleStatusColors { ArticleStatusColors.colors(for: selectedTheme) }

    var body: some View {
        ZStack {
            colors.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: VersoSpacing.xl) {
                    header
                    DSSection("Color Tokens", colors: colors) { colorTokens }
                    DSSection("Status Colors", colors: colors) { statusColors }
                    DSSection("Typography — Body Scale", colors: colors) { bodyScale }
                    DSSection("Typography — Headings", colors: colors) { headings }
                    DSSection("Typography — UI", colors: colors) { uiTypography }
                    DSSection("Spacing Tokens", colors: colors) { spacingTokens }
                    DSSection("Typefaces", colors: colors) { typefaces }
                }
                .padding(20)
            }
        }
        .preferredColorScheme(selectedTheme.isDark ? .dark : .light)
        .animation(.easeInOut(duration: 0.25), value: selectedTheme)
    }

    // MARK: Header + Theme Picker

    private var header: some View {
        VStack(alignment: .leading, spacing: VersoSpacing.sm) {
            Text("Design System")
                .font(VersoTypography.UI.screenTitle)
                .foregroundColor(colors.textPrimary)

            Text("Verso iOS · FAB-92")
                .font(.system(size: 13))
                .foregroundColor(colors.textSecondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: VersoSpacing.xs) {
                    ForEach(VersoTheme.allCases) { theme in
                        Button {
                            selectedTheme = theme
                        } label: {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(ThemeColors.colors(for: theme).background)
                                    .frame(width: 10, height: 10)
                                    .overlay(Circle().stroke(ThemeColors.colors(for: theme).border, lineWidth: 1))
                                Text(theme.rawValue)
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .padding(.horizontal, VersoSpacing.md)
                            .padding(.vertical, VersoSpacing.xs)
                            .background(selectedTheme == theme ? colors.accent : colors.surface)
                            .foregroundColor(selectedTheme == theme ? .white : colors.textSecondary)
                            .cornerRadius(VersoRadius.pill)
                            .overlay(
                                RoundedRectangle(cornerRadius: VersoRadius.pill)
                                    .stroke(colors.border, lineWidth: selectedTheme == theme ? 0 : 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: Color Tokens

    private var colorTokens: some View {
        let tokens: [(label: String, color: Color, description: String)] = [
            ("background",    colors.background,    "Main screen and article background"),
            ("surface",       colors.surface,       "Cards, list rows, reading bar"),
            ("textPrimary",   colors.textPrimary,   "Body text, titles — WCAG AA ≥4.5:1"),
            ("textSecondary", colors.textSecondary, "Metadata, captions — WCAG AA ≥4.5:1"),
            ("accent",        colors.accent,        "Links, interactive elements"),
            ("accentPressed", colors.accentPressed, "Pressed and active states"),
            ("border",        colors.border,        "Dividers and separators"),
            ("placeholder",   colors.placeholder,   "Image placeholders, skeleton states"),
        ]

        return VStack(spacing: 10) {
            ForEach(tokens, id: \.label) { token in
                HStack(spacing: 14) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(token.color)
                        .frame(width: 44, height: 44)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(colors.border, lineWidth: 1))

                    VStack(alignment: .leading, spacing: 3) {
                        Text(token.label)
                            .font(.system(size: 13, weight: .semibold, design: .monospaced))
                            .foregroundColor(colors.textPrimary)
                        Text(token.description)
                            .font(.system(size: 12))
                            .foregroundColor(colors.textSecondary)
                    }

                    Spacer()
                }
            }
        }
    }

    // MARK: Status Colors

    private var statusColors: some View {
        HStack(spacing: 24) {
            ForEach(ArticleStatus.allCases, id: \.rawValue) { status in
                HStack(spacing: 8) {
                    Circle()
                        .fill(statusPalette.color(for: status))
                        .frame(width: 14, height: 14)
                    Text(status.rawValue)
                        .font(.system(size: 15))
                        .foregroundColor(colors.textPrimary)
                }
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: Body Scale

    private var bodyScale: some View {
        let scale: [(label: String, size: CGFloat, lineHeightMult: CGFloat, isDefault: Bool)] = [
            ("XXL  26pt", 26, 1.5,  false),
            ("XL   22pt", 22, 1.6,  false),
            ("L    20pt", 20, 1.75, false),
            ("M    18pt", 18, 1.75, true),
            ("S    16pt", 16, 1.75, false),
            ("XS   14pt", 14, 1.75, false),
        ]

        return VStack(alignment: .leading, spacing: 16) {
            ForEach(scale, id: \.label) { step in
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    HStack(spacing: 4) {
                        Text(step.label)
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundColor(colors.textSecondary)
                        if step.isDefault {
                            Text("default")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(colors.accent)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 1)
                                .background(colors.accent.opacity(0.12))
                                .cornerRadius(4)
                        }
                    }
                    .frame(width: 130, alignment: .leading)

                    Text("The verso is the second page you encounter.")
                        .font(.system(size: step.size))
                        .foregroundColor(colors.textPrimary)
                        .lineSpacing((step.lineHeightMult - 1) * step.size)
                }

                if step.label != "XS   14pt" {
                    Divider().background(colors.border)
                }
            }
        }
    }

    // MARK: Headings

    private var headings: some View {
        let levels: [(label: String, size: CGFloat, weight: Font.Weight, lineHeightMult: CGFloat)] = [
            ("H1  28pt  Bold",     28, .bold,     1.2),
            ("H2  24pt  Semibold", 24, .semibold, 1.25),
            ("H3  20pt  Semibold", 20, .semibold, 1.3),
            ("H4  18pt  Semibold", 18, .semibold, 1.35),
        ]

        return VStack(alignment: .leading, spacing: 16) {
            ForEach(levels, id: \.label) { level in
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    Text(level.label)
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(colors.textSecondary)
                        .frame(width: 130, alignment: .leading)

                    Text("Article Heading")
                        .font(.system(size: level.size, weight: level.weight))
                        .foregroundColor(colors.textPrimary)
                        .lineSpacing((level.lineHeightMult - 1) * level.size)
                }

                if level.label != "H4  18pt  Semibold" {
                    Divider().background(colors.border)
                }
            }
        }
    }

    // MARK: UI Typography

    private var uiTypography: some View {
        let styles: [(label: String, size: CGFloat, weight: Font.Weight, sample: String)] = [
            ("Screen Title  34pt", 34, .bold,     "Library"),
            ("List Title    17pt", 17, .semibold, "The Verge · Article Title"),
            ("List Subtitle 15pt", 15, .regular,  "5 min read · Saved today"),
            ("Button        17pt", 17, .semibold, "Save Article"),
            ("Caption       13pt", 13, .regular,  "April 2026"),
        ]

        return VStack(alignment: .leading, spacing: 16) {
            ForEach(styles, id: \.label) { style in
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    Text(style.label)
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(colors.textSecondary)
                        .frame(width: 130, alignment: .leading)

                    Text(style.sample)
                        .font(.system(size: style.size, weight: style.weight))
                        .foregroundColor(colors.textPrimary)
                }

                if style.label != "Caption       13pt" {
                    Divider().background(colors.border)
                }
            }
        }
    }

    // MARK: Spacing Tokens

    private var spacingTokens: some View {
        let tokens: [(name: String, value: CGFloat, usage: String)] = [
            ("xxs",  VersoSpacing.xxs,  "Inline gaps, icon + label"),
            ("xs",   VersoSpacing.xs,   "Filter chip gap, tight padding"),
            ("sm",   VersoSpacing.sm,   "Filter chip interior padding"),
            ("md",   VersoSpacing.md,   "Standard content padding"),
            ("lg",   VersoSpacing.lg,   "Section spacing, list row gap"),
            ("xl",   VersoSpacing.xl,   "Major section divisions"),
            ("xxl",  VersoSpacing.xxl,  "Screen-level vertical rhythm"),
            ("xxxl", VersoSpacing.xxxl, "Extra breathing room"),
        ]

        return VStack(alignment: .leading, spacing: 12) {
            ForEach(tokens, id: \.name) { token in
                HStack(spacing: 14) {
                    // Visual bar — capped at 80pt wide for display
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(colors.background)
                            .frame(width: 80, height: 16)
                        Capsule()
                            .fill(colors.accent.opacity(0.6))
                            .frame(width: min(token.value * 1.2, 80), height: 16)
                    }
                    .overlay(Capsule().stroke(colors.border, lineWidth: 1))
                    .frame(width: 80)

                    HStack(spacing: 6) {
                        Text(token.name)
                            .font(.system(size: 13, weight: .semibold, design: .monospaced))
                            .foregroundColor(colors.textPrimary)
                        Text("\(Int(token.value))pt")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(colors.textSecondary)
                        Text("·")
                            .foregroundColor(colors.border)
                        Text(token.usage)
                            .font(.system(size: 12))
                            .foregroundColor(colors.textSecondary)
                    }

                    Spacer()
                }
            }
        }
    }

    // MARK: Typefaces

    private var typefaces: some View {
        let faces: [(name: String, font: Font, note: String)] = [
            ("New York",      .custom("NewYork", size: 19),        "Default · Apple serif"),
            ("Georgia",       .custom("Georgia", size: 19),        "Classic serif"),
            ("San Francisco", .system(size: 19),                   "System sans-serif"),
            ("OpenDyslexic",  .custom("OpenDyslexic-Regular", size: 19), "Accessibility · bundled"),
        ]

        return VStack(alignment: .leading, spacing: 20) {
            ForEach(faces, id: \.name) { face in
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text(face.name)
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundColor(colors.textSecondary)
                        Text(face.note)
                            .font(.system(size: 11))
                            .foregroundColor(colors.textSecondary.opacity(0.7))
                    }

                    Text("The verso is the second page you encounter when you open a book.")
                        .font(face.font)
                        .foregroundColor(colors.textPrimary)
                        .lineSpacing(5)
                }

                if face.name != "OpenDyslexic" {
                    Divider().background(colors.border)
                }
            }
        }
    }
}

// MARK: - Section Wrapper

private struct DSSection<Content: View>: View {
    let title: String
    let colors: ThemeColors
    let content: Content

    init(_ title: String, colors: ThemeColors, @ViewBuilder content: () -> Content) {
        self.title = title
        self.colors = colors
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: VersoSpacing.sm) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(colors.textSecondary)
                .kerning(0.6)

            content
                .padding(VersoSpacing.md)
                .background(colors.surface)
                .cornerRadius(VersoRadius.md)
                .overlay(
                    RoundedRectangle(cornerRadius: VersoRadius.md)
                        .stroke(colors.border, lineWidth: 1)
                )
        }
    }
}

// MARK: - Preview

#Preview("Paper") {
    DesignSystemPreview()
}

#Preview("Sepia") {
    DesignSystemPreview()
        .onAppear { } // theme is set via the picker in-app
}
