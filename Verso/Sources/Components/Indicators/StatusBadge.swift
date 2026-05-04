import SwiftUI

struct StatusBadge: View {
    let status: ArticleStatus

    var body: some View {
        switch status {
        case .unread:
            Circle()
                .fill(status.color)
                .frame(width: 12, height: 12)
        case .reading, .read:
            Text(status.rawValue)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, VersoSpacing.xs)
                .padding(.vertical, VersoSpacing.xxs)
                .background(status.color)
                .clipShape(Capsule())
        }
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
