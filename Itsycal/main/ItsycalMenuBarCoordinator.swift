import AppKit
import SwiftUI

@available(macOS 26.0, *)
@objcMembers
final class ItsycalMenuBarCoordinator: NSObject {

    private var menuBarExtra: NSMenuBarExtra?
    private var hostingController: NSHostingController<ItsycalMenuView>?
    private let viewModel = ItsycalViewModel()

    func start() {
        guard menuBarExtra == nil else { return }

        let extra = NSMenuBarExtra(title: "", image: NSImage(systemSymbolName: "calendar", accessibilityDescription: "Itsycal")!)
        extra.isVisible = true

        let hosting = NSHostingController(rootView: ItsycalMenuView().environmentObject(viewModel))
        extra.menuBarExtraWindow?.contentViewController = hosting
        extra.behavior = [.remembersLastClosedState]

        menuBarExtra = extra
        hostingController = hosting
    }
}

