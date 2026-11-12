import Foundation
import AppKit
import HEICConverterKit

@MainActor
final class ViewModel: ObservableObject {
    static let shared = ViewModel()
    @Published var results: [ConversionResult] = []
    @Published var overwrite = false
    @Published var busy = false

    func convert(_ urls: [URL]) {
        let overwrite = self.overwrite
        busy = true
        Task.detached {
            let r = BatchRunner.run(urls, overwrite: overwrite)
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
        p.allowedContentTypes = [.heic, .heif].compactMap { $0 }
        if p.runModal() == .OK { convert(p.urls) }
    }
}

import UniformTypeIdentifiers
private extension UTType {
    static let heif = UTType("public.heif")
}
