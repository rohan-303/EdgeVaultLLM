import XCTest
@testable import EdgeVaultLLM

final class BenchmarkServiceTests: XCTestCase {
    func testLoadResultsWhenMissingFile() {
        let service = BenchmarkService()
        let results = service.loadResults()
        XCTAssertNotNil(results)
    }
}
