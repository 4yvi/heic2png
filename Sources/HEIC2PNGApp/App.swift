import SwiftUI
import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ n: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }
    func applicationShouldTerminateAfterLastWindowClosed(_ app: NSApplication) -> Bool { true }
    // Файлы, брошенные на иконку приложения / «Открыть с помощью»
    func application(_ app: NSApplication, open urls: [URL]) {
        ViewModel.shared.convert(urls)
    }
}

@main
struct HEICApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(ViewModel.shared)
                .frame(width: 360, height: 320)
        }
        .windowResizability(.contentSize)
    }
}
