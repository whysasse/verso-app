import SwiftUI

struct ImmersiveHintPill: View {
    @Binding var isVisible: Bool

    var body: some View {
        if isVisible {
            Text(L10n.Reading.immersiveHint)
                .font(.system(size: 13))
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.7))
                .clipShape(Capsule())
                .onTapGesture {
                    isVisible = false
                }
                .transition(.opacity.animation(VersoAnimation.normal))
        }
    }
}

struct ImmersiveHintPill_Preview: View {
    @State private var visible = true
    var body: some View {
        ZStack {
            Color.gray.opacity(0.3)
            VStack {
                Spacer()
                ImmersiveHintPill(isVisible: $visible)
                    .padding(.bottom, 100)
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ImmersiveHintPill_Preview()
}
