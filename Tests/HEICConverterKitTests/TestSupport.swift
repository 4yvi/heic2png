import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

enum TestSupport {
    static func tempDir() -> URL {
        let d = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try! FileManager.default.createDirectory(at: d, withIntermediateDirectories: true)
        return d
    }

    /// Создаёт реальный HEIC-файл заданного размера.
    static func makeHEIC(at url: URL, width: Int = 64, height: Int = 48, noise: Bool = false) {
        let cs = CGColorSpaceCreateDeviceRGB()
        let ctx = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0,
                            space: cs, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        ctx.setFillColor(CGColor(red: 0.9, green: 0.2, blue: 0.1, alpha: 1))
        ctx.fill(CGRect(x: 0, y: 0, width: width, height: height))
        if noise, let d = ctx.data?.assumingMemoryBound(to: UInt8.self) {
            var x: UInt32 = 12345   // детерминированный шум
            for i in 0..<(ctx.bytesPerRow * height) {
                x = x &* 1664525 &+ 1013904223
                d[i] = (i % 4 == 3) ? 255 : UInt8(truncatingIfNeeded: x >> 24)
            }
        }
        let img = ctx.makeImage()!
        try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        let dest = CGImageDestinationCreateWithURL(url as CFURL, UTType.heic.identifier as CFString, 1, nil)!
        CGImageDestinationAddImage(dest, img, nil)
        precondition(CGImageDestinationFinalize(dest), "не удалось создать HEIC")
    }

    static func size(of url: URL) -> (Int, Int)? {
        guard let s = CGImageSourceCreateWithURL(url as CFURL, nil),
              let p = CGImageSourceCopyPropertiesAtIndex(s, 0, nil) as? [CFString: Any] else { return nil }
        return (p[kCGImagePropertyPixelWidth] as! Int, p[kCGImagePropertyPixelHeight] as! Int)
    }
}
