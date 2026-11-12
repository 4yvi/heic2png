import Foundation
import UniformTypeIdentifiers

public enum OutputFormat: String, CaseIterable, Identifiable {
    case png, jpeg, heic

    public var id: String { rawValue }

    public var utType: UTType {
        switch self {
        case .png: return .png
        case .jpeg: return .jpeg
        case .heic: return .heic
        }
    }

    public var fileExtension: String { self == .jpeg ? "jpg" : rawValue }

    /// PNG сжимается без потерь, параметра качества у него нет.
    public var supportsQuality: Bool { self != .png }

    public var title: String { rawValue.uppercased() }
}
