import SwiftUI

struct LaunchView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        themeManager.colors.background
            .ignoresSafeArea()
            .overlay {
                VStack(spacing: 24) {
                    Image("VersoIcon")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(themeManager.colors.accent)
                        .frame(width: 64, height: 64)

                    Text("Verso")
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .foregroundColor(themeManager.colors.accent)
                }
            }
    }
}
