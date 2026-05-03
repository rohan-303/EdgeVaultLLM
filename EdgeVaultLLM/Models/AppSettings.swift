import Foundation

struct AppSettings: Codable {
    var contextLength: Int = 2048
    var maxTokens: Int = 256
    var temperature: Double = 0.7
    var topP: Double = 0.9
    var mmapEnabled: Bool = true
    var allowFallbackCopyMode: Bool = false
}
