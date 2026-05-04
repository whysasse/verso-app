import SwiftUI

struct ScrollProgress: View {
    let progress: Double
    @EnvironmentObject var themeManager: ThemeManager
    private var colors: ThemeColors { themeManager.colors }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(colors.border)
                Rectangle()
                    .fill(colors.accent)
                    .frame(width: geo.size.width * max(0, min(1, progress)))
            }
        }
        .frame(height: 3)
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
