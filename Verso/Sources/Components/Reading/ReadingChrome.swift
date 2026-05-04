import SwiftUI

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
                Image(systemName: "chevron.left")
                    .font(.system(size: 24))
                    .foregroundColor(colors.accent)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)

            Spacer()

            Text(title)
                .font(VersoTypography.UI.listSubtitle)
                .foregroundColor(colors.textSecondary)
                .lineLimit(1)
                .frame(maxWidth: .infinity)

            Spacer()

            Button(action: onOpenExternal) {
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 24))
                    .foregroundColor(colors.accent)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
        }
        .frame(height: 44)
        .background(colors.surface.opacity(0.95))
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
    var onFontDecrease: () -> Void = {}
    var onFontIncrease: () -> Void = {}
    var onLineSpacing: () -> Void = {}
    var onMargins: () -> Void = {}
    var onTheme: () -> Void = {}
    var onMarkRead: () -> Void = {}
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var isVisible: Bool
    private var colors: ThemeColors { themeManager.colors }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(actions, id: \.icon) { action in
                Button(action: action.handler) {
                    Image(systemName: action.icon)
                        .font(.system(size: 22))
                        .foregroundColor(colors.accent)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                }
                .buttonStyle(.plain)
            }
        }
        .background(colors.surface.opacity(0.95))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(colors.border),
            alignment: .top
        )
        .opacity(isVisible ? 1 : 0)
        .animation(.easeOut(duration: 0.3), value: isVisible)
    }

    private var actions: [(icon: String, handler: () -> Void)] {
        [
            ("minus", onFontDecrease),
            ("plus", onFontIncrease),
            ("text.alignleft", onLineSpacing),
            ("arrow.left.and.right.righttriangle.left.righttriangle.right", onMargins),
            ("circle.lefthalf.filled", onTheme),
            ("checkmark.circle", onMarkRead),
        ]
    }
}

#Preview {
    @Previewable @State var visible = true

    VStack {
        ReadingTopBar(title: "The Future of Reading", isVisible: $visible)
        Spacer()
        ReadingBottomBar(isVisible: $visible)
    }
    .environmentObject(ThemeManager())
}
