import Foundation
import Combine

@available(macOS 26.0, *)
@objcMembers
final class ItsycalViewModel: NSObject, ObservableObject {

    static let shared = ItsycalViewModel()

    @Published var today: Date = Date()

    override private init() {
        super.init()
    }
}
