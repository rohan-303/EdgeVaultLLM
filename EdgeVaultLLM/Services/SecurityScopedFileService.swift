import Foundation

enum SecurityScopedFileError: LocalizedError {
    case invalidExtension
    case cannotAccessScope
    case unreadable
    case bookmarkCreationFailed
    case bookmarkResolveFailed

    var errorDescription: String? {
        switch self {
        case .invalidExtension: return "Selected file is not a .gguf model."
        case .cannotAccessScope: return "Could not start security-scoped access."
        case .unreadable: return "Model file is not readable. The SSD may be disconnected."
        case .bookmarkCreationFailed: return "Failed to create bookmark for selected model."
        case .bookmarkResolveFailed: return "Failed to resolve saved bookmark."
        }
    }
}

final class SecurityScopedFileService {
    func validateGGUF(url: URL) throws {
        guard url.pathExtension.lowercased() == "gguf" else { throw SecurityScopedFileError.invalidExtension }
    }

    func withSecurityScope<T>(url: URL, operation: () throws -> T) throws -> T {
        let granted = url.startAccessingSecurityScopedResource()
        guard granted else { throw SecurityScopedFileError.cannotAccessScope }
        defer { url.stopAccessingSecurityScopedResource() }
        return try operation()
    }

    func createBookmarkData(for url: URL) throws -> Data {
        let granted = url.startAccessingSecurityScopedResource()
        guard granted else { throw SecurityScopedFileError.cannotAccessScope }
        defer { url.stopAccessingSecurityScopedResource() }

        do {
            return try url.bookmarkData(options: .minimalBookmark, includingResourceValuesForKeys: nil, relativeTo: nil)
        } catch {
            throw SecurityScopedFileError.bookmarkCreationFailed
        }
    }

    func resolveBookmark(_ data: Data) throws -> (url: URL, stale: Bool) {
        var stale = false
        do {
            let url = try URL(resolvingBookmarkData: data, options: [.withoutUI, .withSecurityScope], relativeTo: nil, bookmarkDataIsStale: &stale)
            return (url, stale)
        } catch {
            throw SecurityScopedFileError.bookmarkResolveFailed
        }
    }

    func fileSize(url: URL) throws -> Int64 {
        try withSecurityScope(url: url) {
            let values = try url.resourceValues(forKeys: [.fileSizeKey])
            guard let size = values.fileSize else { throw SecurityScopedFileError.unreadable }
            return Int64(size)
        }
    }

    func ensureReadable(url: URL) throws {
        try withSecurityScope(url: url) {
            let readable = FileManager.default.isReadableFile(atPath: url.path)
            if !readable { throw SecurityScopedFileError.unreadable }
        }
    }
}
