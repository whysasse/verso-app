import SwiftUI

struct ImmersiveHintPill: View {
    @Binding var isVisible: Bool

    var body: some View {
        if isVisible {
            Text("Tap anywhere to reveal")
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

#Preview {
    @Previewable @State var visible = true

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
