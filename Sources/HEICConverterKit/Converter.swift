import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

public enum Converter {
    public static let defaultQuality = 0.9

    /// Конвертирует изображение в выбранный формат. Ориентация EXIF применяется к пикселям.
    /// `quality` (0.01...1.0) учитывается только для форматов с потерями (JPEG, HEIC).
    @discardableResult
    public static func convert(input: URL, output: URL, format: OutputFormat = .png,
                               quality: Double = defaultQuality, overwrite: Bool = false) throws -> URL {
        let fm = FileManager.default
        guard fm.fileExists(atPath: input.path) else { throw ConverterError.fileNotFound(input.path) }
        if input.standardizedFileURL.path == output.standardizedFileURL.path {
            throw ConverterError.outputExists(output.path)   // никогда не затираем исходник
        }
        if fm.fileExists(atPath: output.path) && !overwrite { throw ConverterError.outputExists(output.path) }

        guard let source = CGImageSourceCreateWithURL(input as CFURL, nil),
              CGImageSourceGetCount(source) > 0 else { throw ConverterError.notAnImage(input.path) }

        let opts: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,   // применить ориентацию
            kCGImageSourceThumbnailMaxPixelSize: Self.maxPixelSize(source),
        ]
        guard let image = CGImageSourceCreateThumbnailAtIndex(source, 0, opts as CFDictionary)
        else { throw ConverterError.notAnImage(input.path) }

        try fm.createDirectory(at: output.deletingLastPathComponent(), withIntermediateDirectories: true)
        guard let dest = CGImageDestinationCreateWithURL(output as CFURL, format.utType.identifier as CFString, 1, nil)
        else { throw ConverterError.writeFailed(output.path) }

        var props: [CFString: Any] = [:]
        if format.supportsQuality {
            props[kCGImageDestinationLossyCompressionQuality] = min(1.0, max(0.01, quality))
        }
        if format == .jpeg {   // JPEG без прозрачности — подкладываем белый фон
            props[kCGImageDestinationBackgroundColor] = CGColor(gray: 1, alpha: 1)
        }
        CGImageDestinationAddImage(dest, image, props as CFDictionary)
        guard CGImageDestinationFinalize(dest) else { throw ConverterError.writeFailed(output.path) }
        return output
    }

    /// Путь результата: расширение по формату, в `outputDir` или рядом с исходником.
    /// Если путь совпал бы с исходником (HEIC → HEIC), добавляется суффикс `-compressed`.
    public static func outputURL(for input: URL, outputDir: URL? = nil, format: OutputFormat = .png) -> URL {
        let dir = outputDir ?? input.deletingLastPathComponent()
        let base = input.deletingPathExtension().lastPathComponent
        var url = dir.appendingPathComponent(base).appendingPathExtension(format.fileExtension)
        if url.standardizedFileURL.path == input.standardizedFileURL.path {
            url = dir.appendingPathComponent(base + "-compressed").appendingPathExtension(format.fileExtension)
        }
        return url
    }

    private static func maxPixelSize(_ source: CGImageSource) -> Int {
        guard let props = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
              let w = props[kCGImagePropertyPixelWidth] as? Int,
              let h = props[kCGImagePropertyPixelHeight] as? Int else { return 16384 }
        return max(w, h)
    }
}
