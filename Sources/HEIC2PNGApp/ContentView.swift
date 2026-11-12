import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @EnvironmentObject var vm: ViewModel
    @State private var targeted = false

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [6]))
                    .foregroundColor(targeted ? .accentColor : .secondary)
                VStack(spacing: 8) {
                    Text(vm.busy ? "Конвертирую…" : "Перетащите HEIC сюда").font(.headline)
                    Button("Выбрать файлы…") { vm.pick() }
                }
            }
            .frame(height: 120)
            .onDrop(of: [UTType.fileURL], isTargeted: $targeted) { providers in
                var urls: [URL] = []
                let group = DispatchGroup()
                for p in providers {
                    group.enter()
                    _ = p.loadObject(ofClass: URL.self) { u, _ in
                        if let u = u { DispatchQueue.main.async { urls.append(u); group.leave() } } else { group.leave() }
                    }
                }
                group.notify(queue: .main) { vm.convert(urls) }
                return true
            }

            Toggle("Перезаписывать существующие", isOn: $vm.overwrite).font(.caption)

            List(vm.results) { r in
                HStack {
                    Image(systemName: r.isSuccess ? "checkmark.circle.fill" : "xmark.octagon.fill")
                        .foregroundColor(r.isSuccess ? .green : .red)
                    Text(r.input.lastPathComponent).lineLimit(1)
                    Spacer()
                    if let e = r.error { Text(e).font(.caption).foregroundColor(.secondary).lineLimit(1) }
                }
            }
            .listStyle(.plain)
        }
        .padding(16)
    }
}
