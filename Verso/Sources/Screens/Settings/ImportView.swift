import SwiftUI
import UniformTypeIdentifiers
import CoreData

struct ImportView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var folderBookmarkService: FolderBookmarkService
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @StateObject private var orchestrator = ImportOrchestrator()
    @State private var showFilePicker = false

    private var colors: ThemeColors { themeManager.colors }

    var body: some View {
        NavigationView {
            ZStack {
                colors.background.ignoresSafeArea()
                content
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    VersoToolbarIconButton(
                        systemName: "xmark",
                        accent: colors.accent,
                        action: { dismiss() },
                        iconPointSize: 17,
                        labelWidth: 44,
                        labelHeight: 44,
                        accessibilityLabel: String(localized: "Close"),
                        accessibilityHint: String(localized: "Dismiss import sheet")
                    )
                }
            }
        }
        .sheet(isPresented: $showFilePicker) {
            ImportFilePicker { url in
                guard let folderURL = folderBookmarkService.folderURL else { return }
                Task {
                    await orchestrator.importFile(at: url, folderURL: folderURL, context: viewContext)
                }
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch orchestrator.state {
        case .idle:
            idleContent
        case .parsing:
            progressContent(message: "Reading file…", progress: nil)
        case .writing(let progress):
            progressContent(message: "Importing articles…", progress: progress)
        case .done(let imported, let skipped):
            doneContent(imported: imported, skipped: skipped)
        case .failed(let message):
            failedContent(message: message)
        }
    }

    private var idleContent: some View {
        VStack(spacing: VersoSpacing.lg) {
            Spacer()

            Image(systemName: "arrow.down.doc")
                .font(.system(size: 48, weight: .light))
                .foregroundColor(colors.textSecondary)

            VStack(spacing: VersoSpacing.xs) {
                Text("Import Articles")
                    .font(VersoTypography.UI.listTitle)
                    .foregroundColor(colors.textPrimary)

                Text("Import your reading list from GoodLinks, Instapaper, Pocket, Readwise Reader, or Matter.")
                    .font(VersoTypography.UI.listSubtitle)
                    .foregroundColor(colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, VersoSpacing.xl)
            }

            if folderBookmarkService.folderURL == nil {
                Text("Set your articles folder in Storage settings before importing.")
                    .font(VersoTypography.UI.caption)
                    .foregroundColor(colors.accent)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, VersoSpacing.xl)
            }

            Button {
                showFilePicker = true
            } label: {
                Text("Select Export File")
                    .font(VersoTypography.UI.button)
                    .foregroundColor(colors.background)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(colors.accent)
                    .cornerRadius(10)
                    .padding(.horizontal, VersoSpacing.xl)
            }
            .buttonStyle(.plain)
            .disabled(folderBookmarkService.folderURL == nil)
            .opacity(folderBookmarkService.folderURL == nil ? 0.4 : 1)

            Spacer()
        }
    }

    private func progressContent(message: String, progress: Double?) -> some View {
        VStack(spacing: VersoSpacing.lg) {
            Spacer()
            ProgressView()
                .progressViewStyle(.circular)
                .scaleEffect(1.5)
                .tint(colors.accent)
            Text(message)
                .font(VersoTypography.UI.listSubtitle)
                .foregroundColor(colors.textSecondary)
            if let progress {
                ProgressView(value: progress)
                    .tint(colors.accent)
                    .padding(.horizontal, VersoSpacing.xl)
            }
            Spacer()
        }
    }

    private func doneContent(imported: Int, skipped: Int) -> some View {
        VStack(spacing: VersoSpacing.lg) {
            Spacer()
            Image(systemName: "checkmark.circle")
                .font(.system(size: 48, weight: .light))
                .foregroundColor(colors.accent)

            VStack(spacing: VersoSpacing.xs) {
                Text("Import Complete")
                    .font(VersoTypography.UI.listTitle)
                    .foregroundColor(colors.textPrimary)

                Text("\(imported) article\(imported == 1 ? "" : "s") imported\(skipped > 0 ? ", \(skipped) skipped" : "").")
                    .font(VersoTypography.UI.listSubtitle)
                    .foregroundColor(colors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: VersoSpacing.sm) {
                Button {
                    dismiss()
                } label: {
                    Text("Done")
                        .font(VersoTypography.UI.button)
                        .foregroundColor(colors.background)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(colors.accent)
                        .cornerRadius(10)
                        .padding(.horizontal, VersoSpacing.xl)
                }
                .buttonStyle(.plain)

                Button {
                    orchestrator.reset()
                } label: {
                    Text("Import Another File")
                        .font(VersoTypography.UI.input)
                        .foregroundColor(colors.accent)
                }
                .buttonStyle(.plain)
            }

            Spacer()
        }
    }

    private func failedContent(message: String) -> some View {
        VStack(spacing: VersoSpacing.lg) {
            Spacer()
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48, weight: .light))
                .foregroundColor(colors.textSecondary)

            VStack(spacing: VersoSpacing.xs) {
                Text("Import Failed")
                    .font(VersoTypography.UI.listTitle)
                    .foregroundColor(colors.textPrimary)

                Text(message)
                    .font(VersoTypography.UI.listSubtitle)
                    .foregroundColor(colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, VersoSpacing.xl)
            }

            Button {
                orchestrator.reset()
            } label: {
                Text("Try Again")
                    .font(VersoTypography.UI.button)
                    .foregroundColor(colors.background)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(colors.accent)
                    .cornerRadius(10)
                    .padding(.horizontal, VersoSpacing.xl)
            }
            .buttonStyle(.plain)

            Spacer()
        }
    }
}

// MARK: - File Picker

private struct ImportFilePicker: UIViewControllerRepresentable {
    var onFilePicked: (URL) -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let types: [UTType] = [.json, .commaSeparatedText, .html]
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: types, asCopy: true)
        picker.delegate = context.coordinator
        picker.shouldShowFileExtensions = true
        picker.allowsMultipleSelection = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onFilePicked: onFilePicked)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onFilePicked: (URL) -> Void

        init(onFilePicked: @escaping (URL) -> Void) {
            self.onFilePicked = onFilePicked
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            onFilePicked(url)
        }
    }
}
