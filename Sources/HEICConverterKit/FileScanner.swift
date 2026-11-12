import Foundation

public enum FileScanner {
    public static let extensions: Set<String> = ["heic", "heif"]

    public static func isHEIC(_ url: URL) -> Bool {
        extensions.contains(url.pathExtension.lowercased())
    }

    /// Разворачивает файлы и папки в список HEIC-файлов без дубликатов (порядок сохраняется).
    public static func scan(_ inputs: [URL], recursive: Bool = false) -> [URL] {
        var result: [URL] = []
        var seen = Set<String>()
        func add(_ u: URL) { if seen.insert(u.standardizedFileURL.path).inserted { result.append(u) } }

        for url in inputs {
            var isDir: ObjCBool = false
            guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir) else { continue }
            if !isDir.boolValue {
                if isHEIC(url) { add(url) }
                continue
            }
            let fm = FileManager.default
            if recursive {
                let en = fm.enumerator(at: url, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
                let files = (en?.allObjects as? [URL] ?? []).filter(isHEIC).sorted { $0.path < $1.path }
                files.forEach(add)
            } else {
                let files = ((try? fm.contentsOfDirectory(at: url, includingPropertiesForKeys: nil,
                                                          options: [.skipsHiddenFiles])) ?? [])
                    .filter(isHEIC).sorted { $0.path < $1.path }
                files.forEach(add)
            }
        }
        return result
    }
}
