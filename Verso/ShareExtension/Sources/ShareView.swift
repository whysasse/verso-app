import SwiftUI

// Hardcoded Paper theme values — avoids importing the full design system in the extension.
private enum PaperTheme {
    static let background = Color(red: 0.973, green: 0.965, blue: 0.949)
    static let textPrimary = Color(red: 0.149, green: 0.137, blue: 0.122)
    static let textSecondary = Color(red: 0.431, green: 0.408, blue: 0.376)
    static let accent = Color(red: 0.290, green: 0.216, blue: 0.149)
    static let border = Color(red: 0.827, green: 0.808, blue: 0.784)
}

struct ShareView: View {
    @ObservedObject var viewModel: ShareViewModel
    let extensionContext: NSExtensionContext?

    var body: some View {
        ZStack {
            PaperTheme.background.ignoresSafeArea()

            VStack(spacing: 16) {
                switch viewModel.state {
                case .idle, .saving:
                    savingView

                case .duplicatePrompt(let pending, let existingPath, let existingTitle):
                    duplicatePromptView(
                        pending: pending,
                        existingTitle: existingTitle,
                        existingPath: existingPath
                    )

                case .success(let title, let isUpdate):
                    successView(title: title, isUpdate: isUpdate)
                        .task {
                            try? await Task.sleep(nanoseconds: 1_500_000_000)
                            extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
                        }

                case .failure(let url):
                    failureView(url: url)
                }
            }
            .padding(24)
            .frame(maxWidth: 480)
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - State views

    private var savingView: some View {
        VStack(spacing: 12) {
            ProgressView()
                .tint(PaperTheme.accent)
                .scaleEffect(1.2)
            Text("Saving…")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(PaperTheme.textSecondary)
        }
        .frame(minHeight: 80)
    }

    private func duplicatePromptView(pending: PendingArticle, existingTitle: String, existingPath: String) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Article already saved")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(PaperTheme.textPrimary)

            Text("This link is already in your library as “\(existingTitle)”.")
                .font(.system(size: 15))
                .foregroundStyle(PaperTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 10) {
                Button {
                    viewModel.chooseUpdateExisting(pending: pending, existingPath: existingPath)
                } label: {
                    Text("Update existing")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(PaperTheme.accent)
                        .foregroundStyle(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .buttonStyle(.plain)

                Button {
                    viewModel.chooseSaveCopy(pending: pending)
                } label: {
                    Text("Save as copy")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(PaperTheme.surfaceFill)
                        .foregroundStyle(PaperTheme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(PaperTheme.border, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)

                Button("Cancel") {
                    extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
                }
                .font(.system(size: 15))
                .foregroundStyle(PaperTheme.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.top, 4)
            }
        }
        .frame(minHeight: 120)
    }

    private func successView(title: String, isUpdate: Bool) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 36))
                .foregroundStyle(Color(red: 0.353, green: 0.686, blue: 0.478)) // Read green
            Text(isUpdate ? "Updated" : "Saved")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(PaperTheme.textPrimary)
            Text(title)
                .font(.system(size: 13))
                .foregroundStyle(PaperTheme.textSecondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .truncationMode(.tail)
        }
        .frame(minHeight: 80)
    }

    private func failureView(url: URL) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.circle")
                .font(.system(size: 36))
                .foregroundStyle(PaperTheme.textSecondary)
            Text("Couldn't save article")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(PaperTheme.textPrimary)
            HStack(spacing: 16) {
                Button("Dismiss") {
                    extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
                }
                .font(.system(size: 15))
                .foregroundStyle(PaperTheme.textSecondary)

                Link("Open in Safari", destination: url)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(PaperTheme.accent)
            }
        }
        .frame(minHeight: 80)
    }
}

private extension PaperTheme {
    /// Slightly elevated control surface on Paper background.
    static let surfaceFill = Color(red: 0.99, green: 0.985, blue: 0.975)
}
