import Foundation
import AppKit
import SwiftUI
import UniformTypeIdentifiers
import HEICConverterKit

@MainActor
final class ViewModel: ObservableObject {
    static let shared = ViewModel()
    @Published var results: [ConversionResult] = []
    @Published var busy = false
    @AppStorage("overwrite") var overwrite = false
    @AppStorage("format") var formatRaw = OutputFormat.png.rawValue
    @AppStorage("quality") var qualityPercent = 90

    var format: OutputFormat { OutputFormat(rawValue: formatRaw) ?? .png }

    func convert(_ urls: [URL]) {
        let (overwrite, format, quality) = (self.overwrite, self.format, Double(qualityPercent) / 100)
        busy = true
        Task.detached {
            let r = BatchRunner.run(urls, format: format, quality: quality, overwrite: overwrite)
            await MainActor.run {
                self.results = r + self.results
                self.busy = false
            }
        }
    }

    func pick() {
        let p = NSOpenPanel()
        p.allowsMultipleSelection = true
        p.canChooseDirectories = true
        p.allowedContentTypes = [UTType.heic, UTType("public.heif")].compactMap { $0 }
        if p.runModal() == .OK { convert(p.urls) }
    }
}
