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
                    .foregroundColor(colors.textSecondary)
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
                    .foregroundColor(colors.textSecondary)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .tint(.clear)

            Spacer()

            Button(action: tts.cycleSpeed) {
                Text(tts.speed.label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(colors.textSecondary)
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

struct ReadingTopBar: View {
    let title: String
    var onBack: () -> Void = {}
    var onOpenExternal: () -> Void = {}
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var isVisible: Bool
    private var colors: ThemeColors { themeManager.colors }

    var body: some View {
        HStack(spacing: 0) {
            Button(action: onBack) {
                Text("‹")
                    .font(.system(size: 22))
                    .foregroundColor(colors.accent)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)

            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(colors.textPrimary)
                .lineLimit(1)
                .frame(maxWidth: .infinity)

            Button(action: onOpenExternal) {
                Text("↗")
                    .font(.system(size: 20))
                    .foregroundColor(colors.textSecondary)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
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
                Button(action: onControls) {
                    Text("Aa")
                        .font(.system(size: 16))
                        .foregroundColor(colors.textSecondary)
                        .frame(width: 44, height: 56)
                }
                .buttonStyle(.plain)

                Spacer()

                ScrollProgress(progress: scrollProgress)
                    .frame(width: 160)
                    .environmentObject(themeManager)

                Spacer()

                Button(action: onToggleTTS) {
                    Image(systemName: "speaker.wave.2")
                        .font(.system(size: 16))
                        .foregroundColor(isTTSActive ? colors.accent : colors.textSecondary)
                        .frame(width: 44, height: 56)
                }
                .buttonStyle(.plain)
                .tint(.clear)

                Button(action: onTheme) {
                    Text("◑")
                        .font(.system(size: 20))
                        .foregroundColor(colors.textSecondary)
                        .frame(width: 44, height: 56)
                }
                .buttonStyle(.plain)
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
