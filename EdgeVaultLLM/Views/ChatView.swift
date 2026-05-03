import SwiftUI

struct ChatView: View {
    @EnvironmentObject private var modelManager: ModelManagerViewModel
    @EnvironmentObject private var settings: SettingsViewModel
    @StateObject private var chatVM = ChatViewModel()
    @State private var prompt = ""

    var body: some View {
        VStack {
            List(chatVM.messages) { msg in
                VStack(alignment: .leading, spacing: 6) {
                    Text(msg.role.rawValue.capitalized).font(.caption).foregroundStyle(.secondary)
                    Text(msg.content)
                }
                .padding(.vertical, 4)
            }

            VStack(spacing: 8) {
                TextField("Prompt", text: $prompt, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                HStack {
                    Button("Generate") {
                        Task {
                            await chatVM.generate(
                                prompt: prompt,
                                modelManager: modelManager,
                                settings: settings.settings
                            )
                        }
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Stop") { chatVM.stop(modelManager: modelManager) }
                        .buttonStyle(.bordered)

                    Button("Clear Chat") { chatVM.clear() }
                        .buttonStyle(.bordered)
                }

                if let tps = chatVM.lastTokensPerSecond {
                    Text(String(format: "%.2f tokens/sec", tps))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                if let error = chatVM.errorMessage {
                    Text(error).foregroundStyle(.red)
                }
            }
            .padding()
        }
        .navigationTitle(modelManager.selectedModel?.fileName ?? "Chat")
    }
}
