import Foundation

struct SelectedModel: Codable {
    let fileName: String
    let fileSize: Int64
    let bookmarkCreatedAt: Date
    var lastOpenedAt: Date
    let displayPath: String
    let isExternal: Bool
    let isSecurityScoped: Bool
}
