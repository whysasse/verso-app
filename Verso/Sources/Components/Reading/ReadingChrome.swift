import SwiftUI

// MARK: - TTS Controls Row

struct TTSControlsRow: View {
    @ObservedObject var tts: TTSService
    @EnvironmentObject var themeManager: ThemeManager
    private var colors: ThemeColors { themeManager.colors }

    var body: some View {
        HStack(spacing: 0) {
            Button(action: tts.skipBack) {
                Image(systemName: "backward.end.fill")
                    .font(.system(size: 16))
                    .foregroundColor(colors.accent)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .tint(.clear)

            Button(action: { tts.isPlaying ? tts.pause() : tts.resume() }) {
                Image(systemName: tts.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 18))
                    .foregroundColor(colors.accent)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .tint(.clear)

            Button(action: tts.skipForward) {
                Image(systemName: "forward.end.fill")
                    .font(.system(size: 16))
                    .foregroundColor(colors.accent)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .tint(.clear)

            Spacer()

            Button(action: tts.cycleSpeed) {
                Text(tts.speed.label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(colors.accent)
                    .frame(width: 54, height: 44)
            }
            .buttonStyle(.plain)
            .tint(.clear)
        }
        .padding(.horizontal, VersoSpacing.md)
        .frame(height: 44)
        .background(colors.background)
    }
}

// MARK: - Top Bar

private let readingChromeIconSize: CGFloat = 20

struct ReadingTopBar: View {
    let title: String
    var onBack: () -> Void = {}
    var onOpenExternal: () -> Void = {}
    var onEditTags: (() -> Void)? = nil
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var isVisible: Bool
    private var colors: ThemeColors { themeManager.colors }

    var body: some View {
        HStack(spacing: 0) {
            VersoToolbarIconButton(
                systemName: "chevron.left",
                accent: colors.accent,
                action: onBack,
                iconPointSize: readingChromeIconSize,
                labelWidth: 44,
                labelHeight: 44,
                accessibilityLabel: "Back",
                accessibilityHint: "Returns to the article list"
            )

            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(colors.textPrimary)
                .lineLimit(1)
                .frame(maxWidth: .infinity)

            if let onEditTags {
                VersoToolbarIconButton(
                    systemName: "tag",
                    accent: colors.accent,
                    action: onEditTags,
                    iconPointSize: readingChromeIconSize,
                    labelWidth: 44,
                    labelHeight: 44,
                    accessibilityLabel: "Tags",
                    accessibilityHint: "Edit tags for this article"
                )
            }

            VersoToolbarIconButton(
                systemName: "arrow.up.right",
                accent: colors.accent,
                action: onOpenExternal,
                iconPointSize: readingChromeIconSize,
                labelWidth: 44,
                labelHeight: 44,
                accessibilityLabel: "Open in browser",
                accessibilityHint: "Opens the original article in your web browser"
            )
        }
        .frame(height: 44)
        .background(colors.background)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(colors.border),
            alignment: .bottom
        )
        .opacity(isVisible ? 1 : 0)
        .animation(.easeOut(duration: 0.3), value: isVisible)
    }
}

struct ReadingBottomBar: View {
    let scrollProgress: Double
    var onControls: () -> Void = {}
    var onTheme: () -> Void = {}
    var tts: TTSService? = nil
    var isTTSActive: Bool = false
    var onToggleTTS: () -> Void = {}
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var isVisible: Bool
    private var colors: ThemeColors { themeManager.colors }

    private var ttsIconName: String {
        isTTSActive ? "speaker.wave.2.fill" : "speaker.wave.2"
    }

    var body: some View {
        VStack(spacing: 0) {
            if isTTSActive, let tts = tts {
                Rectangle()
                    .fill(colors.border)
                    .frame(height: 1)
                TTSControlsRow(tts: tts)
                    .environmentObject(themeManager)
            }

            HStack(spacing: 0) {
                VersoToolbarIconButton(
                    systemName: "textformat.size",
                    accent: colors.accent,
                    action: onControls,
                    iconPointSize: readingChromeIconSize,
                    labelWidth: 44,
                    labelHeight: 56,
                    accessibilityLabel: "Font and spacing",
                    accessibilityHint: "Adjust reading font size and line spacing"
                )

                Spacer()

                ScrollProgress(progress: scrollProgress)
                    .frame(width: 160)
                    .environmentObject(themeManager)

                Spacer()

                VersoToolbarIconButton(
                    systemName: ttsIconName,
                    accent: colors.accent,
                    action: onToggleTTS,
                    iconPointSize: readingChromeIconSize,
                    labelWidth: 44,
                    labelHeight: 56,
                    accessibilityLabel: isTTSActive ? "Stop listening" : "Listen to article",
                    accessibilityHint: "Reads the article aloud"
                )

                VersoToolbarIconButton(
                    systemName: "circle.lefthalf.filled",
                    accent: colors.accent,
                    action: onTheme,
                    iconPointSize: readingChromeIconSize,
                    labelWidth: 44,
                    labelHeight: 56,
                    accessibilityLabel: "Reading theme",
                    accessibilityHint: "Change paper, sepia, night, or ink theme"
                )
            }
            .padding(.horizontal, VersoSpacing.md)
            .frame(height: 56)
            .background(colors.background)
        }
        .background(colors.background)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(colors.border),
            alignment: .top
        )
        .opacity(isVisible ? 1 : 0)
        .animation(.easeOut(duration: 0.3), value: isVisible)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var visible = true
        var body: some View {
            VStack {
                ReadingTopBar(title: "The Future of Reading", isVisible: $visible)
                Spacer()
                ReadingBottomBar(scrollProgress: 0.4, isVisible: $visible)
            }
            .environmentObject(ThemeManager())
        }
    }
    return PreviewWrapper()
}
