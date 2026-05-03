import XCTest
@testable import EdgeVaultLLM

final class ModelBookmarkStoreTests: XCTestCase {
    func testSaveAndLoadMetadata() throws {
        let suite = UserDefaults(suiteName: "ModelBookmarkStoreTests")!
        suite.removePersistentDomain(forName: "ModelBookmarkStoreTests")

        let store = ModelBookmarkStore(defaults: suite)
        let metadata = SelectedModel(
            fileName: "m.gguf",
            fileSize: 10,
            bookmarkCreatedAt: Date(),
            lastOpenedAt: Date(),
            displayPath: "/tmp/m.gguf",
            isExternal: true,
            isSecurityScoped: true
        )
        try store.save(bookmark: Data([1, 2]), metadata: metadata)

        XCTAssertNotNil(store.loadBookmark())
        XCTAssertEqual(store.loadMetadata()?.fileName, "m.gguf")
    }
}
