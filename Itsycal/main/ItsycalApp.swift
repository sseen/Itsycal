import SwiftUI

@main
struct ItsycalApp: App {

    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        if #available(macOS 26.0, *) {
            MenuBarExtra("Itsycal", systemImage: "calendar") {
                ItsycalMenuView()
                    .environmentObject(ItsycalViewModel.shared)
            }
            .menuBarExtraStyle(.window)
        }
        // Legacy fallback scene to satisfy App protocol while AppDelegate drives AppKit UI.
        Settings {
            Text("")
        }
    }
}

