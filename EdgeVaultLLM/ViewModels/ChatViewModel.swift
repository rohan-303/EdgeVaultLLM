import Foundation

@MainActor
final class ChatViewModel: ObservableObject {
    @Published private(set) var messages: [ChatMessage] = []
    @Published var errorMessage: String?
    @Published var lastTokensPerSecond: Double?

    private let historyKey = "edgevault.chat.history"

    init() {
        load()
    }

    func generate(prompt: String, modelManager: ModelManagerViewModel, settings: AppSettings) async {
        guard !prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        messages.append(ChatMessage(role: .user, content: prompt))

        do {
            let out = try await modelManager.generate(prompt: prompt, settings: settings)
            messages.append(ChatMessage(role: .assistant, content: out.text))
            lastTokensPerSecond = out.tokensPerSecond
            errorMessage = nil
            save()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func stop(modelManager: ModelManagerViewModel) {
        modelManager.stopGeneration()
    }

    func clear() {
        messages.removeAll()
        UserDefaults.standard.removeObject(forKey: historyKey)
    }

    private func save() {
        if let data = try? JSONEncoder().encode(messages) {
            UserDefaults.standard.set(data, forKey: historyKey)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: historyKey),
              let decoded = try? JSONDecoder().decode([ChatMessage].self, from: data) else { return }
        messages = decoded
    }
}
