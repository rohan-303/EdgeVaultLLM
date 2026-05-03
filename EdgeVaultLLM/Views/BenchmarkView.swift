import SwiftUI

struct BenchmarkView: View {
    @EnvironmentObject private var modelManager: ModelManagerViewModel
    @EnvironmentObject private var settings: SettingsViewModel
    @StateObject private var vm = BenchmarkViewModel()

    var body: some View {
        List {
            Section {
                Button(vm.running ? "Running..." : "Run Benchmark") {
                    Task { await vm.run(modelManager: modelManager, settings: settings.settings) }
                }
                .disabled(vm.running)
            }

            Section("Results") {
                ForEach(vm.results) { result in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(result.timestamp.formatted(date: .abbreviated, time: .shortened))
                            .font(.headline)
                        Text("Load: \(String(format: "%.2f", result.modelLoadTimeMs)) ms")
                        Text("First token: \(String(format: "%.2f", result.firstTokenLatencyMs)) ms")
                        Text("Total: \(String(format: "%.2f", result.totalGenerationTimeMs)) ms")
                        Text("TPS: \(String(format: "%.2f", result.tokensPerSecond))")
                        Text("Tokens: \(result.tokensGenerated)")
                        Text("Source: \(result.modelSourceMode)")
                        if let err = result.errorStatus {
                            Text("Error: \(err)").foregroundStyle(.red)
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
        }
        .navigationTitle("Benchmarks")
        .task { vm.loadExisting() }
    }
}
