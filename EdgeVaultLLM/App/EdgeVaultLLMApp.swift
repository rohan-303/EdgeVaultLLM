import SwiftUI

@main
struct EdgeVaultLLMApp: App {
    @StateObject private var settingsViewModel = SettingsViewModel()
    @StateObject private var modelManager: ModelManagerViewModel

    init() {
        let settings = SettingsViewModel()
        let modelManager = ModelManagerViewModel(settings: settings)
        _settingsViewModel = StateObject(wrappedValue: settings)
        _modelManager = StateObject(wrappedValue: modelManager)
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(settingsViewModel)
                .environmentObject(modelManager)
        }
    }
}
