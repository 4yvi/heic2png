import Foundation
import HEICConverterKit

let usage = """
Использование: heic2png <файл|папка>... [-o <папка>] [-r] [--overwrite] [-h]
  -o, --output <папка>  куда класть PNG (по умолчанию рядом с исходником)
  -r, --recursive       обходить папки рекурсивно
      --overwrite       перезаписывать существующие PNG
  -h, --help            помощь
"""

var inputs: [URL] = []
var outputDir: URL?
var recursive = false
var overwrite = false

var args = Array(CommandLine.arguments.dropFirst())[...]
while let a = args.popFirst() {
    switch a {
    case "-h", "--help": print(usage); exit(0)
    case "-r", "--recursive": recursive = true
    case "--overwrite": overwrite = true
    case "-o", "--output":
        guard let v = args.popFirst() else { FileHandle.standardError.write(Data((usage + "\n").utf8)); exit(2) }
        outputDir = URL(fileURLWithPath: v)
    default:
        if a.hasPrefix("-") { FileHandle.standardError.write(Data("неизвестный флаг \(a)\n\(usage)\n".utf8)); exit(2) }
        inputs.append(URL(fileURLWithPath: a))
    }
}
if inputs.isEmpty { FileHandle.standardError.write(Data((usage + "\n").utf8)); exit(2) }

let files = FileScanner.scan(inputs, recursive: recursive)
if files.isEmpty { print("HEIC-файлы не найдены"); exit(1) }

var failures = 0
for f in files {
    do {
        let out = try Converter.convert(input: f, output: Converter.outputURL(for: f, outputDir: outputDir), overwrite: overwrite)
        print("✓ \(f.lastPathComponent) → \(out.path)")
    } catch {
        failures += 1
        FileHandle.standardError.write(Data("✗ \(f.lastPathComponent): \(error)\n".utf8))
    }
}
exit(failures == 0 ? 0 : 1)
