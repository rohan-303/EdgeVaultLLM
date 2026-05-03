import Foundation

@MainActor
final class ModelManagerViewModel: ObservableObject {
    @Published var selectedModel: SelectedModel?
    @Published var warningMessage: String?
    @Published var errorMessage: String?
    @Published var isModelLoaded = false
    @Published var runtimeInfo = RuntimeInfo(backend: .unknown, mmapEnabled: true, loaded: false)
    @Published var storageAudit: StorageAuditReport?

    private(set) var selectedModelURL: URL?

    private let settings: SettingsViewModel
    private let securityService = SecurityScopedFileService()
    private let bookmarkStore = ModelBookmarkStore()
    private let runtime = LlamaRuntimeService()
    private let auditService = StorageAuditService()

    private let chatHistoryKey = "edgevault.chat.history"

    init(settings: SettingsViewModel) {
        self.settings = settings
        self.selectedModel = bookmarkStore.loadMetadata()
    }

    var bookmarkStatus: String {
        bookmarkStore.loadBookmark() == nil ? "Not set" : "Stored"
    }

    var estimatedMemoryWarning: String {
        guard let model = selectedModel else { return "No model" }
        return model.fileSize > 3_000_000_000 ? "High risk for iPhone 15 Plus" : "Within small-model target"
    }

    var sourceMode: String {
        settings.settings.allowFallbackCopyMode ? "copied_or_external" : "external"
    }

    func selectModel(url: URL) async {
        do {
            try securityService.validateGGUF(url: url)
            try securityService.ensureReadable(url: url)

            let size = try securityService.fileSize(url: url)
            let bookmark = try securityService.createBookmarkData(for: url)

            let model = SelectedModel(
                fileName: url.lastPathComponent,
                fileSize: size,
                bookmarkCreatedAt: Date(),
                lastOpenedAt: Date(),
                displayPath: url.path,
                isExternal: !url.path.hasPrefix(NSHomeDirectory()),
                isSecurityScoped: true
            )

            try bookmarkStore.save(bookmark: bookmark, metadata: model)
            self.selectedModel = model
            self.selectedModelURL = url
            self.warningMessage = model.isExternal ? "Model selected from external location." : "Selected model appears inside app container."
            self.errorMessage = nil
            refreshAudit()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    func restoreBookmarkIfNeeded() async {
        guard let data = bookmarkStore.loadBookmark() else { return }
        do {
            var bookmarkToPersist = data
            var resolved = try securityService.resolveBookmark(data)
            if resolved.stale {
                let newData = try securityService.createBookmarkData(for: resolved.url)
                if let metadata = bookmarkStore.loadMetadata() {
                    try bookmarkStore.save(bookmark: newData, metadata: metadata)
                }
                bookmarkToPersist = newData
                resolved = try securityService.resolveBookmark(newData)
            }
            try securityService.ensureReadable(url: resolved.url)
            selectedModelURL = resolved.url
            if var metadata = bookmarkStore.loadMetadata() {
                metadata.lastOpenedAt = Date()
                try bookmarkStore.save(bookmark: bookmarkToPersist, metadata: metadata)
                selectedModel = metadata
            }
            warningMessage = nil
            errorMessage = nil
            refreshAudit()
        } catch {
            errorMessage = "Bookmark restore failed: \(error.localizedDescription)"
        }
    }

    func clearBookmark() {
        bookmarkStore.clear()
        selectedModel = nil
        selectedModelURL = nil
        isModelLoaded = false
        runtime.unloadModel()
        runtimeInfo = runtime.getRuntimeInfo()
        refreshAudit()
    }

    func clearChatHistory() {
        UserDefaults.standard.removeObject(forKey: chatHistoryKey)
    }

    func ensureModelLoaded() async throws {
        if isModelLoaded { return }
        guard let url = selectedModelURL else { throw LlamaRuntimeError.noModelSelected }
        try runtime.loadModel(url: url, mmapEnabled: settings.settings.mmapEnabled)
        runtimeInfo = runtime.getRuntimeInfo()
        isModelLoaded = runtimeInfo.loaded
    }

    func unloadModel() {
        runtime.unloadModel()
        runtimeInfo = runtime.getRuntimeInfo()
        isModelLoaded = false
    }

    func generate(prompt: String, settings: AppSettings) async throws -> (text: String, tokens: Int, durationMs: Double, firstTokenMs: Double, tokensPerSecond: Double) {
        try await ensureModelLoaded()

        let s = GenerationSettings(
            contextLength: Int32(settings.contextLength),
            maxTokens: Int32(settings.maxTokens),
            temperature: Float(settings.temperature),
            topP: Float(settings.topP)
        )

        let out = try runtime.generate(prompt: prompt, settings: s) { _ in }
        let sec = max(out.durationMs / 1000.0, 0.001)
        return (out.text, out.tokens, out.durationMs, out.firstTokenMs, Double(out.tokens) / sec)
    }

    func stopGeneration() {
        runtime.stopGeneration()
    }

    func refreshStatus() async {
        runtimeInfo = runtime.getRuntimeInfo()
        refreshAudit()
    }

    private func refreshAudit() {
        storageAudit = auditService.audit(selectedModelURL: selectedModelURL)
    }
}
