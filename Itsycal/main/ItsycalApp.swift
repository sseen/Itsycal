import SwiftUI
import Cocoa

@main
struct ItsycalApp: App {

    @NSApplicationDelegateAdaptor(AppDelegateAdapter.self) private var appDelegate

    var body: some Scene {
        if #available(macOS 26.0, *) {
            MenuBarExtra("Itsycal", systemImage: "calendar") {
                ItsycalMenuView()
                    .environmentObject(ItsycalViewModel.shared)
            }
            .menuBarExtraStyle(.window)
        }

        Settings { EmptyView() }
    }
}

@objcMembers
final class AppDelegateAdapter: NSObject, NSApplicationDelegate {

    private let legacyDelegate = AppDelegate()

    func applicationDidFinishLaunching(_ notification: Notification) {
        if #available(macOS 26.0, *) {
            legacyDelegate.applicationDidFinishLaunching(notification)
            ItsycalViewModel.sharedInstance().updateBaseDate(Date() as NSDate)
            return;
        }
        legacyDelegate.applicationDidFinishLaunching(notification)
    }

    func applicationWillTerminate(_ notification: Notification) {
        legacyDelegate.applicationWillTerminate(notification)
    }
}
