import Foundation

struct StorageAuditReport {
    let appStorageBytes: Int64
    let modelInsideContainer: Bool
}

final class StorageAuditService {
    func audit(selectedModelURL: URL?) -> StorageAuditReport {
        let appPath = NSHomeDirectory()
        let appStorageBytes = folderSize(path: appPath)
        let modelInside = selectedModelURL?.path.hasPrefix(appPath) ?? false
        return StorageAuditReport(appStorageBytes: appStorageBytes, modelInsideContainer: modelInside)
    }

    private func folderSize(path: String) -> Int64 {
        var total: Int64 = 0
        let fm = FileManager.default
        if let e = fm.enumerator(atPath: path) {
            for case let file as String in e {
                let full = (path as NSString).appendingPathComponent(file)
                let attrs = try? fm.attributesOfItem(atPath: full)
                total += (attrs?[.size] as? Int64) ?? 0
            }
        }
        return total
    }
}
