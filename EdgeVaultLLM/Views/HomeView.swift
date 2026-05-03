import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var modelManager: ModelManagerViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    headerCard
                    NavigationLink("Select Model from External SSD") {
                        ModelPickerView()
                    }
                    .buttonStyle(.borderedProminent)

                    NavigationLink("Open Chat") {
                        ChatView()
                    }
                    .buttonStyle(.bordered)

                    NavigationLink("Benchmarks") {
                        BenchmarkView()
                    }
                    .buttonStyle(.bordered)

                    NavigationLink("Settings") {
                        SettingsView()
                    }
                    .buttonStyle(.bordered)

                    NavigationLink("Model Status") {
                        ModelStatusView()
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
            }
            .navigationTitle("EdgeVault LLM")
            .task {
                await modelManager.restoreBookmarkIfNeeded()
            }
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("EdgeVault LLM")
                .font(.title2.bold())
            Text("Run GGUF models from external storage on iPhone.")
                .foregroundStyle(.secondary)
            if let selected = modelManager.selectedModel {
                Text("Model: \(selected.fileName)")
                    .font(.subheadline)
            } else {
                Text("No model selected yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
