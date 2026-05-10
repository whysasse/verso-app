import SwiftUI

struct ScrollProgress: View {
    let progress: Double
    @EnvironmentObject var themeManager: ThemeManager
    private var colors: ThemeColors { themeManager.colors }

    var body: some View {
        GeometryReader { geo in
            let trackWidth = max(geo.size.width, 1)
            let trackHeight = max(geo.size.height, 1)
            let p = max(0, min(1, progress))
            let proportional = trackWidth * CGFloat(p)
            // Keep a visible accent segment whenever there is any progress (tiny fractions are otherwise invisible).
            let fillWidth: CGFloat = {
                guard p > 0 else { return 0 }
                return max(proportional, min(VersoSpacing.xs, trackWidth))
            }()

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(colors.border)
                    .frame(width: trackWidth, height: trackHeight)
                Capsule()
                    .fill(colors.accent)
                    .frame(width: fillWidth, height: trackHeight)
            }
            .clipShape(Capsule())
            .accessibilityLabel("Reading progress")
            .accessibilityValue("\(Int((p * 100).rounded())) percent")
        }
        .frame(height: 4)
    }
}

#Preview {
    VStack(spacing: 16) {
        ScrollProgress(progress: 0)
        ScrollProgress(progress: 0.35)
        ScrollProgress(progress: 0.7)
        ScrollProgress(progress: 1)
    }
    .padding()
    .environmentObject(ThemeManager())
}
