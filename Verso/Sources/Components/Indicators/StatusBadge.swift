import SwiftUI

struct StatusBadge: View {
    let status: ArticleStatus

    private let badgeDiameter: CGFloat = 28

    var body: some View {
        ZStack {
            Circle()
                .fill(status.color)
                .frame(width: badgeDiameter, height: badgeDiameter)
            Image(systemName: status.icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
        }
        .accessibilityLabel(Text(status.rawValue))
    }
}

#Preview {
    HStack(spacing: 24) {
        StatusBadge(status: .unread)
        StatusBadge(status: .reading)
        StatusBadge(status: .read)
    }
    .padding()
}
