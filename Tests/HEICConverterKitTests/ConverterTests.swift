import XCTest
@testable import HEICConverterKit

final class ConverterTests: XCTestCase {
    var dir: URL!
    override func setUp() { dir = TestSupport.tempDir() }
    override func tearDown() { try? FileManager.default.removeItem(at: dir) }

    func testConvertsHEICToPNG() throws {
        let src = dir.appendingPathComponent("a.heic")
        TestSupport.makeHEIC(at: src, width: 64, height: 48)
        let out = try Converter.convert(input: src, output: Converter.outputURL(for: src))
        XCTAssertEqual(out.lastPathComponent, "a.png")
        let data = try Data(contentsOf: out)
        XCTAssertEqual(Array(data.prefix(8)), [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])
        let s = TestSupport.size(of: out)
        XCTAssertEqual(s?.0, 64); XCTAssertEqual(s?.1, 48)
    }

    func testMissingFile() {
        let src = dir.appendingPathComponent("nope.heic")
        XCTAssertThrowsError(try Converter.convert(input: src, output: dir.appendingPathComponent("x.png"))) {
            XCTAssertEqual($0 as? ConverterError, .fileNotFound(src.path))
        }
    }

    func testNotAnImage() throws {
        let src = dir.appendingPathComponent("fake.heic")
        try "hello".write(to: src, atomically: true, encoding: .utf8)
        XCTAssertThrowsError(try Converter.convert(input: src, output: dir.appendingPathComponent("fake.png"))) {
            XCTAssertEqual($0 as? ConverterError, .notAnImage(src.path))
        }
    }

    func testNoOverwriteByDefault() throws {
        let src = dir.appendingPathComponent("a.heic")
        TestSupport.makeHEIC(at: src)
        let out = Converter.outputURL(for: src)
        try Converter.convert(input: src, output: out)
        XCTAssertThrowsError(try Converter.convert(input: src, output: out)) {
            XCTAssertEqual($0 as? ConverterError, .outputExists(out.path))
        }
        XCTAssertNoThrow(try Converter.convert(input: src, output: out, overwrite: true))
    }

    func testCreatesOutputDirectory() throws {
        let src = dir.appendingPathComponent("a.heic")
        TestSupport.makeHEIC(at: src)
        let outDir = dir.appendingPathComponent("new/sub")
        let out = try Converter.convert(input: src, output: Converter.outputURL(for: src, outputDir: outDir))
        XCTAssertTrue(FileManager.default.fileExists(atPath: out.path))
    }
}
