import SwiftUI

struct LoadingState: View {
    @State private var shimmerOffset: CGFloat = -1
    @EnvironmentObject var themeManager: ThemeManager
    private var colors: ThemeColors { themeManager.colors }

    var body: some View {
        LazyVStack(spacing: 12) {
            ForEach(0..<5, id: \.self) { _ in
                SkeletonCard(shimmerOffset: shimmerOffset, colors: colors)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                shimmerOffset = 1
            }
        }
    }
}

private struct SkeletonCard: View {
    let shimmerOffset: CGFloat
    let colors: ThemeColors

    var body: some View {
        VStack(alignment: .leading, spacing: VersoSpacing.xs) {
            skeletonBar(widthFraction: 0.75)
            skeletonBar(widthFraction: 0.40)
            skeletonBar(widthFraction: 0.25)
        }
        .padding(VersoSpacing.md)
        .background(colors.surface)
        .cornerRadius(VersoRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: VersoRadius.md)
                .stroke(colors.border, lineWidth: 1)
        )
    }

    private func skeletonBar(widthFraction: CGFloat) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(colors.placeholder)
                    .frame(width: geo.size.width * widthFraction, height: 14)

                LinearGradient(
                    colors: [
                        Color.clear,
                        colors.textSecondary.opacity(0.3),
                        Color.clear,
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: geo.size.width * widthFraction * 0.5, height: 14)
                .offset(x: geo.size.width * widthFraction * shimmerOffset)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 4))
            }
        }
        .frame(height: 14)
    }
}

#Preview {
    LoadingState()
        .padding()
        .environmentObject(ThemeManager())
}
