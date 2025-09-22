import Foundation
import Combine

@available(macOS 26.0, *)
@objcMembers
final class ItsycalViewModel: NSObject, ObservableObject {

    @Published var today: Date = Date()

    override init() {
        super.init()
    }
}

