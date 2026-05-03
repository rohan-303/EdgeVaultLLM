import Foundation

final class ModelBookmarkStore {
    private enum Keys {
        static let bookmarkData = "edgevault.model.bookmark"
        static let metadata = "edgevault.model.metadata"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func save(bookmark: Data, metadata: SelectedModel) throws {
        defaults.set(bookmark, forKey: Keys.bookmarkData)
        let encoded = try JSONEncoder().encode(metadata)
        defaults.set(encoded, forKey: Keys.metadata)
    }

    func loadBookmark() -> Data? { defaults.data(forKey: Keys.bookmarkData) }

    func loadMetadata() -> SelectedModel? {
        guard let data = defaults.data(forKey: Keys.metadata) else { return nil }
        return try? JSONDecoder().decode(SelectedModel.self, from: data)
    }

    func clear() {
        defaults.removeObject(forKey: Keys.bookmarkData)
        defaults.removeObject(forKey: Keys.metadata)
    }
}
