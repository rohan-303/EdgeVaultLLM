import SwiftUI
import UniformTypeIdentifiers

struct ModelPickerView: View {
    @EnvironmentObject private var modelManager: ModelManagerViewModel
    @State private var showPicker = false

    var body: some View {
        Form {
            Section("Model File") {
                if let selected = modelManager.selectedModel {
                    LabeledContent("Name", value: selected.fileName)
                    LabeledContent("Size", value: FileSizeFormatter.format(bytes: selected.fileSize))
                    LabeledContent("External", value: selected.isExternal ? "Yes" : "No")
                    LabeledContent("Scoped", value: selected.isSecurityScoped ? "Yes" : "No")
                } else {
                    Text("No model selected")
                        .foregroundStyle(.secondary)
                }

                Button("Select .gguf from External SSD") {
                    showPicker = true
                }
            }

            if let warning = modelManager.warningMessage {
                Section("Warning") {
                    Text(warning)
                        .foregroundStyle(.orange)
                }
            }

            if let error = modelManager.errorMessage {
                Section("Error") {
                    Text(error)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("Model Selection")
        .sheet(isPresented: $showPicker) {
            GGUFDocumentPicker { url in
                Task { await modelManager.selectModel(url: url) }
            }
        }
    }
}

struct GGUFDocumentPicker: UIViewControllerRepresentable {
    let onPick: (URL) -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.data], asCopy: false)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(onPick: onPick) }

    final class Coordinator: NSObject, UIDocumentPickerDelegate {
        private let onPick: (URL) -> Void

        init(onPick: @escaping (URL) -> Void) {
            self.onPick = onPick
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            onPick(url)
        }
    }
}
