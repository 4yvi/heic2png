import Foundation

public struct ConversionResult: Identifiable, Equatable {
    public let id = UUID()
    public let input: URL
    public let output: URL?
    public let error: String?
    public var isSuccess: Bool { error == nil }
}

public enum BatchRunner {
    /// Конвертирует список файлов/папок. Не-HEIC и дубликаты отфильтровываются.
    public static func run(_ inputs: [URL], outputDir: URL? = nil, format: OutputFormat = .png,
                           quality: Double = Converter.defaultQuality, overwrite: Bool = false,
                           recursive: Bool = true) -> [ConversionResult] {
        FileScanner.scan(inputs, recursive: recursive).map { f in
            do {
                let out = try Converter.convert(input: f,
                                                output: Converter.outputURL(for: f, outputDir: outputDir, format: format),
                                                format: format, quality: quality, overwrite: overwrite)
                return ConversionResult(input: f, output: out, error: nil)
            } catch {
                return ConversionResult(input: f, output: nil, error: "\(error)")
            }
        }
    }
}
