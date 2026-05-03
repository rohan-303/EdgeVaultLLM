import Foundation
import SwiftUI

@MainActor
final class BenchmarkViewModel: ObservableObject {
    @Published var results: [BenchmarkResult] = []
    @Published var running = false

    private let service = BenchmarkService()

    func loadExisting() {
        results = service.loadResults()
    }

    func run(modelManager: ModelManagerViewModel, settings: AppSettings) async {
        running = true
        defer { running = false }

        let result = await service.benchmark(
            modelManager: modelManager,
            settings: settings,
            prompt: "Explain what local AI inference means in simple terms."
        )
        service.save(result: result)
        loadExisting()
    }

    func export() {
        let url = service.exportURL()
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = scene.windows.first?.rootViewController {
            root.present(vc, animated: true)
        }
    }
}
