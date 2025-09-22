import SwiftUI

@available(macOS 26.0, *)
struct ItsycalMenuView: View {
    @EnvironmentObject var viewModel: ItsycalViewModel

    var body: some View {
        VStack(spacing: 16) {
            Text(DateFormatter.localizedString(from: viewModel.today, dateStyle: .full, timeStyle: .none))
                .font(.headline)
        }
        .padding(24)
        .frame(minWidth: 280)
    }
}

