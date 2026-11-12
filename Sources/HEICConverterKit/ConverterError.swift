import Foundation

public enum ConverterError: Error, Equatable, CustomStringConvertible {
    case fileNotFound(String)
    case notAnImage(String)
    case outputExists(String)
    case writeFailed(String)

    public var description: String {
        switch self {
        case .fileNotFound(let p): return "файл не найден: \(p)"
        case .notAnImage(let p): return "не удалось прочитать изображение: \(p)"
        case .outputExists(let p): return "уже существует: \(p)"
        case .writeFailed(let p): return "не удалось записать: \(p)"
        }
    }
}
