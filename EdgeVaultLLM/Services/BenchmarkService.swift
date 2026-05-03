import Foundation
import UIKit

final class BenchmarkService {
    private let fileName = "benchmarks.json"

    func benchmark(
        modelManager: ModelManagerViewModel,
        settings: AppSettings,
        prompt: String
    ) async -> BenchmarkResult {
        let start = Date()
        var loadMs = 0.0
        var firstMs = 0.0
        var totalMs = 0.0
        var tokens = 0
        var tps = 0.0
        var errorStatus: String?

        do {
            let loadStart = Date()
            try await modelManager.ensureModelLoaded()
            loadMs = Date().timeIntervalSince(loadStart) * 1000

            let out = try await modelManager.generate(prompt: prompt, settings: settings)
            firstMs = out.firstTokenMs
            totalMs = out.durationMs
            tokens = out.tokens
            tps = out.tokensPerSecond
        } catch {
            errorStatus = error.localizedDescription
        }

        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"

        return BenchmarkResult(
            timestamp: start,
            modelLoadTimeMs: loadMs,
            firstTokenLatencyMs: firstMs,
            totalGenerationTimeMs: totalMs,
            tokensGenerated: tokens,
            tokensPerSecond: tps,
            errorStatus: errorStatus,
            modelSourceMode: modelManager.sourceMode,
            deviceName: UIDevice.current.name,
            appVersion: version
        )
    }

    func loadResults() -> [BenchmarkResult] {
        guard let data = try? Data(contentsOf: fileURL()) else { return [] }
        return (try? JSONDecoder().decode([BenchmarkResult].self, from: data)) ?? []
    }

    func save(result: BenchmarkResult) {
        var all = loadResults()
        all.insert(result, at: 0)
        if let data = try? JSONEncoder().encode(all) {
            try? data.write(to: fileURL(), options: .atomic)
        }
    }

    func exportURL() -> URL { fileURL() }

    private func fileURL() -> URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docs.appendingPathComponent(fileName)
    }
}
