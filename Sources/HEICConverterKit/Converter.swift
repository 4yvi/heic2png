import Foundation
import ImageIO
import UniformTypeIdentifiers

public enum Converter {
    /// Конвертирует изображение в PNG. Ориентация EXIF применяется к пикселям.
    @discardableResult
    public static func convert(input: URL, output: URL, overwrite: Bool = false) throws -> URL {
        let fm = FileManager.default
        guard fm.fileExists(atPath: input.path) else { throw ConverterError.fileNotFound(input.path) }
        if fm.fileExists(atPath: output.path) && !overwrite { throw ConverterError.outputExists(output.path) }

        guard let source = CGImageSourceCreateWithURL(input as CFURL, nil),
              CGImageSourceGetCount(source) > 0 else { throw ConverterError.notAnImage(input.path) }

        let maxSide = Self.maxPixelSize(source)
        let opts: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,   // применить ориентацию
            kCGImageSourceThumbnailMaxPixelSize: maxSide,
        ]
        guard let image = CGImageSourceCreateThumbnailAtIndex(source, 0, opts as CFDictionary)
        else { throw ConverterError.notAnImage(input.path) }

        try fm.createDirectory(at: output.deletingLastPathComponent(), withIntermediateDirectories: true)
        guard let dest = CGImageDestinationCreateWithURL(output as CFURL, UTType.png.identifier as CFString, 1, nil)
        else { throw ConverterError.writeFailed(output.path) }
        CGImageDestinationAddImage(dest, image, nil)
        guard CGImageDestinationFinalize(dest) else { throw ConverterError.writeFailed(output.path) }
        return output
    }

    /// Путь результата: заменяет расширение на .png, в `outputDir` или рядом с исходником.
    public static func outputURL(for input: URL, outputDir: URL? = nil) -> URL {
        let name = input.deletingPathExtension().lastPathComponent + ".png"
        return (outputDir ?? input.deletingLastPathComponent()).appendingPathComponent(name)
    }

    private static func maxPixelSize(_ source: CGImageSource) -> Int {
        guard let props = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
              let w = props[kCGImagePropertyPixelWidth] as? Int,
              let h = props[kCGImagePropertyPixelHeight] as? Int else { return 16384 }
        return max(w, h)
    }
}
