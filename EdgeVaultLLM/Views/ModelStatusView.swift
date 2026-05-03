import SwiftUI

struct ModelStatusView: View {
    @EnvironmentObject private var modelManager: ModelManagerViewModel

    var body: some View {
        Form {
            Section("Model") {
                LabeledContent("Filename", value: modelManager.selectedModel?.fileName ?? "None")
                LabeledContent("File Size", value: modelManager.selectedModel.map { FileSizeFormatter.format(bytes: $0.fileSize) } ?? "-")
                LabeledContent("Loaded", value: modelManager.isModelLoaded ? "Yes" : "No")
                LabeledContent("External URL", value: modelManager.selectedModel?.isExternal == true ? "Available" : "Unknown")
                LabeledContent("Bookmark", value: modelManager.bookmarkStatus)
            }

            Section("Runtime") {
                LabeledContent("Backend", value: modelManager.runtimeInfo.backend.rawValue)
                LabeledContent("mmap", value: modelManager.runtimeInfo.mmapEnabled ? "Enabled" : "Disabled")
                LabeledContent("Est. Memory", value: modelManager.estimatedMemoryWarning)
            }

            if let audit = modelManager.storageAudit {
                Section("Storage Audit") {
                    LabeledContent("App Storage", value: FileSizeFormatter.format(bytes: audit.appStorageBytes))
                    LabeledContent("Model in App Container", value: audit.modelInsideContainer ? "Yes" : "No")
                }
            }
        }
        .navigationTitle("Model Status")
        .task {
            await modelManager.refreshStatus()
        }
    }
}
