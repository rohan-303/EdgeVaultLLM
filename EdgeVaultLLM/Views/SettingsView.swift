import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var settingsVM: SettingsViewModel
    @EnvironmentObject private var modelManager: ModelManagerViewModel
    @StateObject private var benchmarkVM = BenchmarkViewModel()

    var body: some View {
        Form {
            Section("Generation") {
                Stepper("Context Length: \(settingsVM.settings.contextLength)", value: $settingsVM.settings.contextLength, in: 512...4096, step: 256)
                Stepper("Max Tokens: \(settingsVM.settings.maxTokens)", value: $settingsVM.settings.maxTokens, in: 16...1024, step: 16)
                Slider(value: $settingsVM.settings.temperature, in: 0...1.5)
                Text("Temperature: \(String(format: "%.2f", settingsVM.settings.temperature))")
                Slider(value: $settingsVM.settings.topP, in: 0.1...1)
                Text("Top-p: \(String(format: "%.2f", settingsVM.settings.topP))")
            }

            Section("Runtime") {
                Toggle("Enable mmap", isOn: $settingsVM.settings.mmapEnabled)
                LabeledContent("Metal status", value: modelManager.runtimeInfo.backend == .metal ? "Available" : "Not active")
            }

            Section("Storage") {
                Toggle("Copy model into iPhone storage", isOn: $settingsVM.settings.allowFallbackCopyMode)
                Text("Default OFF. Enabling may consume internal storage.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Button("Clear bookmarks") { modelManager.clearBookmark() }
                Button("Clear chat history") { modelManager.clearChatHistory() }
                Button("Export benchmark JSON") { benchmarkVM.export() }
            }
        }
        .navigationTitle("Settings")
        .onDisappear { settingsVM.save() }
    }
}
