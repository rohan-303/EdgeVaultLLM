import Foundation

struct RuntimeInfo {
    enum Backend: String {
        case cpu
        case metal
        case unknown
    }

    var backend: Backend
    var mmapEnabled: Bool
    var loaded: Bool
}

struct GenerationSettings {
    let contextLength: Int32
    let maxTokens: Int32
    let temperature: Float
    let topP: Float
}

enum LlamaRuntimeError: LocalizedError {
    case noModelSelected
    case loadFailed(String)
    case generationFailed(String)

    var errorDescription: String? {
        switch self {
        case .noModelSelected: return "No model selected."
        case .loadFailed(let msg): return "Model load failed: \(msg)"
        case .generationFailed(let msg): return "Generation failed: \(msg)"
        }
    }
}

final class LlamaRuntimeService {
    private let bridge = LlamaBridge()
    private(set) var info = RuntimeInfo(backend: .unknown, mmapEnabled: true, loaded: false)

    func loadModel(url: URL, mmapEnabled: Bool) throws {
        var nsError: NSError?
        let ok = bridge.loadModel(atPath: url.path, mmapEnabled: mmapEnabled, error: &nsError)
        guard ok else { throw LlamaRuntimeError.loadFailed(nsError?.localizedDescription ?? "unknown") }
        info.mmapEnabled = mmapEnabled
        info.loaded = true
        info.backend = bridge.runtimeBackend() == "metal" ? .metal : .cpu
    }

    func unloadModel() {
        bridge.unloadModel()
        info.loaded = false
    }

    func generate(prompt: String, settings: GenerationSettings, onToken: @escaping (String) -> Void) throws -> (text: String, tokens: Int, durationMs: Double, firstTokenMs: Double) {
        var nsError: NSError?
        let result = bridge.generate(
            prompt,
            contextLength: settings.contextLength,
            maxTokens: settings.maxTokens,
            temperature: settings.temperature,
            topP: settings.topP,
            onToken: onToken,
            error: &nsError
        )
        guard let result else {
            throw LlamaRuntimeError.generationFailed(nsError?.localizedDescription ?? "unknown")
        }
        return (result.text, Int(result.tokens), result.durationMs, result.firstTokenMs)
    }

    func stopGeneration() { bridge.stopGeneration() }

    func getRuntimeInfo() -> RuntimeInfo { info }
}
