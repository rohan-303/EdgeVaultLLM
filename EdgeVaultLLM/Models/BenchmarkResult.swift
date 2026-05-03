import Foundation

struct BenchmarkResult: Codable, Identifiable {
    let id: UUID
    let timestamp: Date
    let modelLoadTimeMs: Double
    let firstTokenLatencyMs: Double
    let totalGenerationTimeMs: Double
    let tokensGenerated: Int
    let tokensPerSecond: Double
    let errorStatus: String?
    let modelSourceMode: String
    let deviceName: String
    let appVersion: String

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        modelLoadTimeMs: Double,
        firstTokenLatencyMs: Double,
        totalGenerationTimeMs: Double,
        tokensGenerated: Int,
        tokensPerSecond: Double,
        errorStatus: String?,
        modelSourceMode: String,
        deviceName: String,
        appVersion: String
    ) {
        self.id = id
        self.timestamp = timestamp
        self.modelLoadTimeMs = modelLoadTimeMs
        self.firstTokenLatencyMs = firstTokenLatencyMs
        self.totalGenerationTimeMs = totalGenerationTimeMs
        self.tokensGenerated = tokensGenerated
        self.tokensPerSecond = tokensPerSecond
        self.errorStatus = errorStatus
        self.modelSourceMode = modelSourceMode
        self.deviceName = deviceName
        self.appVersion = appVersion
    }
}
