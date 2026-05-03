import XCTest
@testable import EdgeVaultLLM

final class SecurityScopedFileServiceTests: XCTestCase {
    func testRejectsNonGGUFExtension() {
        let service = SecurityScopedFileService()
        XCTAssertThrowsError(try service.validateGGUF(url: URL(fileURLWithPath: "/tmp/model.bin")))
    }

    func testAcceptsGGUFExtension() {
        let service = SecurityScopedFileService()
        XCTAssertNoThrow(try service.validateGGUF(url: URL(fileURLWithPath: "/tmp/model.gguf")))
    }
}
