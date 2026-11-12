import XCTest
@testable import HEICConverterKit

final class FormatTests: XCTestCase {
    var dir: URL!
    var src: URL!
    override func setUp() {
        dir = TestSupport.tempDir()
        src = dir.appendingPathComponent("n.heic")
        TestSupport.makeHEIC(at: src, width: 256, height: 256, noise: true)
    }
    override func tearDown() { try? FileManager.default.removeItem(at: dir) }

    private func convert(_ f: OutputFormat, _ q: Double, name: String = "") throws -> Data {
        let out = dir.appendingPathComponent("o\(name)-\(f.rawValue)-\(q).\(f.fileExtension)")
        try Converter.convert(input: src, output: out, format: f, quality: q)
        return try Data(contentsOf: out)
    }

    func testSignatures() throws {
        XCTAssertEqual(Array(try convert(.png, 1).prefix(4)), [0x89, 0x50, 0x4E, 0x47])
        XCTAssertEqual(Array(try convert(.jpeg, 0.9).prefix(3)), [0xFF, 0xD8, 0xFF])
        let heic = try convert(.heic, 0.9)
        XCTAssertEqual(String(data: heic[4..<8], encoding: .ascii), "ftyp")
        XCTAssertTrue(["heic", "mif1", "heix"].contains(String(data: heic[8..<12], encoding: .ascii) ?? ""))
    }

    func testJPEGQualityAffectsSize() throws {
        XCTAssertLessThan(try convert(.jpeg, 0.1).count, try convert(.jpeg, 1.0).count)
    }

    func testHEICQualityAffectsSize() throws {
        XCTAssertLessThan(try convert(.heic, 0.1).count, try convert(.heic, 1.0).count)
    }

    func testPNGIgnoresQuality() throws {
        XCTAssertEqual(try convert(.png, 0.1), try convert(.png, 1.0))
    }

    func testQualityIsClamped() throws {
        XCTAssertNoThrow(try convert(.jpeg, 0, name: "a"))
        XCTAssertNoThrow(try convert(.jpeg, 5, name: "b"))
    }

    func testExtensions() {
        XCTAssertEqual(Converter.outputURL(for: src, format: .jpeg).lastPathComponent, "n.jpg")
        XCTAssertEqual(Converter.outputURL(for: src, format: .png).lastPathComponent, "n.png")
    }

    func testHEICToHEICDoesNotClobberSource() throws {
        let out = Converter.outputURL(for: src, format: .heic)
        XCTAssertEqual(out.lastPathComponent, "n-compressed.heic")
        XCTAssertThrowsError(try Converter.convert(input: src, output: src, format: .heic, overwrite: true))
    }

    func testBatchRunnerWritesJPG() {
        let r = BatchRunner.run([src], format: .jpeg, quality: 0.5)
        XCTAssertEqual(r.first?.output?.lastPathComponent, "n.jpg")
        XCTAssertTrue(r.first?.isSuccess ?? false)
    }
}
