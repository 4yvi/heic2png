import XCTest
@testable import HEICConverterKit

final class FileScannerTests: XCTestCase {
    var dir: URL!
    override func setUp() {
        dir = TestSupport.tempDir()
        for n in ["a.heic", "b.HEIC", "c.heif", "sub/d.heic"] { TestSupport.makeHEIC(at: dir.appendingPathComponent(n), width: 8, height: 8) }
        try! "x".write(to: dir.appendingPathComponent("e.jpg"), atomically: true, encoding: .utf8)
    }
    override func tearDown() { try? FileManager.default.removeItem(at: dir) }

    func testFlatScan() {
        XCTAssertEqual(FileScanner.scan([dir]).map(\.lastPathComponent), ["a.heic", "b.HEIC", "c.heif"])
    }
    func testRecursiveScan() {
        XCTAssertEqual(FileScanner.scan([dir], recursive: true).count, 4)
    }
    func testSingleFileAndNonHEICIgnored() {
        XCTAssertEqual(FileScanner.scan([dir.appendingPathComponent("a.heic")]).count, 1)
        XCTAssertEqual(FileScanner.scan([dir.appendingPathComponent("e.jpg")]).count, 0)
    }
    func testDuplicatesRemoved() {
        let f = dir.appendingPathComponent("a.heic")
        XCTAssertEqual(FileScanner.scan([f, f, dir]).count, 3)
    }
}

final class BatchRunnerTests: XCTestCase {
    func testBatchStatuses() throws {
        let dir = TestSupport.tempDir(); defer { try? FileManager.default.removeItem(at: dir) }
        TestSupport.makeHEIC(at: dir.appendingPathComponent("ok.heic"), width: 8, height: 8)
        try "bad".write(to: dir.appendingPathComponent("bad.heic"), atomically: true, encoding: .utf8)
        let r = BatchRunner.run([dir])
        XCTAssertEqual(r.count, 2)
        XCTAssertEqual(r.filter(\.isSuccess).count, 1)
        XCTAssertEqual(r.filter { !$0.isSuccess }.count, 1)
    }
}
