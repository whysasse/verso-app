import SwiftUI

// MARK: - TTS Controls Row

struct TTSControlsRow: View {
    @ObservedObject var tts: TTSService
    @EnvironmentObject var themeManager: ThemeManager
    private var colors: ThemeColors { themeManager.colors }

    /// Matches the speed button's own width below, so reserving it on the leading edge
    /// balances that trailing button and the transport trio in between ends up visually
    /// centered -- same technique the main bar (below) uses to center its progress
    /// indicator between edge-anchored icons. FAB-318: previously a bare `HStack` with
    /// the three transport buttons hard-left, a `Spacer()`, then speed hard-right --
    /// a dead gap rather than a deliberate layout.
    private let speedButtonWidth: CGFloat = 54

    var body: some View {
        HStack(spacing: 0) {
            Spacer()
                .frame(width: speedButtonWidth)

            Spacer()

            Button(action: tts.skipBack) {
                Image(systemName: "backward.end.fill")
                    .font(.system(size: readingChromeIconSize))
                    .foregroundColor(colors.accent)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .tint(.clear)

            Button(action: { tts.isPlaying ? tts.pause() : tts.resume() }) {
                Image(systemName: tts.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: readingChromeIconSize))
                    .foregroundColor(colors.accent)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .tint(.clear)

            Button(action: tts.skipForward) {
                Image(systemName: "forward.end.fill")
                    .font(.system(size: readingChromeIconSize))
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
                    .frame(width: speedButtonWidth, height: 44)
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

struct ReadingTopBar<MenuContent: View>: View {
    let title: String
    var onBack: () -> Void
    /// FAB-299: the menu's items -- `ArticleReaderView` (the only caller) owns every action, so
    /// this view stays presentational, matching how the bottom bar's buttons take plain closures.
    @ViewBuilder var menuContent: () -> MenuContent
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var isVisible: Bool
    private var colors: ThemeColors { themeManager.colors }

    /// Explicit init so `menuContent` -- not `isVisible` -- is the trailing parameter: the
    /// synthesized memberwise init would put `isVisible` last (declaration order), which breaks
    /// trailing-closure call sites like `ReadingTopBar(title:isVisible:) { ... }`.
    init(
        title: String,
        onBack: @escaping () -> Void = {},
        isVisible: Binding<Bool>,
        @ViewBuilder menuContent: @escaping () -> MenuContent
    ) {
        self.title = title
        self.onBack = onBack
        self._isVisible = isVisible
        self.menuContent = menuContent
    }

    var body: some View {
        HStack(spacing: 0) {
            VersoToolbarIconButton(
                systemName: "chevron.left",
                accent: colors.accent,
                action: onBack,
                iconPointSize: readingChromeIconSize,
                labelWidth: 44,
                labelHeight: 44,
                accessibilityLabel: L10n.Reading.backAccessibilityLabel
            )

            Text(title)
                .font(VersoTypography.UI.listTitle)
                .foregroundColor(colors.textPrimary)
                .lineLimit(1)
                .frame(maxWidth: .infinity)

            // Not `VersoToolbarIconButton` here -- that view wraps its content in its own
            // `Button`, which doesn't compose cleanly as a `Menu` label. Same visual metrics
            // (44x44 hit target, readingChromeIconSize) so the bar's rhythm doesn't shift.
            Menu {
                menuContent()
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: readingChromeIconSize))
                    .foregroundColor(colors.accent)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel(L10n.Reading.topBarMoreActions)
            .accessibilityHint(L10n.Reading.topBarMoreActionsHint)
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
        // FAB-307: `.opacity()` alone doesn't disable hit-testing -- an invisible top bar was
        // still catching taps meant for the reveal gesture beneath it (its Back button most of
        // all, since that's a 44x44pt corner a reveal-tap is likely to land in).
        .allowsHitTesting(isVisible)
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
                    accessibilityLabel: L10n.Reading.controlsFontAndSpacing,
                    accessibilityHint: L10n.Reading.controlsFontAndSpacingHint
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
                    accessibilityLabel: isTTSActive ? L10n.Reading.controlsTtsStopListening : L10n.Reading.controlsTtsListen,
                    accessibilityHint: L10n.Reading.controlsTtsHint
                )

                VersoToolbarIconButton(
                    systemName: "circle.lefthalf.filled",
                    accent: colors.accent,
                    action: onTheme,
                    iconPointSize: readingChromeIconSize,
                    labelWidth: 44,
                    labelHeight: 56,
                    accessibilityLabel: L10n.Reading.controlsReadingTheme,
                    accessibilityHint: L10n.Reading.controlsReadingThemeHint
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
        // FAB-307: same `.opacity()`-doesn't-disable-hit-testing gap as the top bar. The call
        // site also collapses this view's outer frame to `height: 0` when hidden, which limits
        // exposure but doesn't guarantee it -- belt and suspenders.
        .allowsHitTesting(isVisible)
        .animation(.easeOut(duration: 0.3), value: isVisible)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var visible = true
        var body: some View {
            VStack {
                ReadingTopBar(title: "The Future of Reading", isVisible: $visible) {
                    Button("Mark as read") {}
                    Button("Tags") {}
                    Button("Open in browser") {}
                }
                Spacer()
                ReadingBottomBar(scrollProgress: 0.4, isVisible: $visible)
            }
            .environmentObject(ThemeManager())
        }
    }
    return PreviewWrapper()
}
