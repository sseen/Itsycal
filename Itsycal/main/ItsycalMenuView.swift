import SwiftUI

@available(macOS 26.0, *)
struct ItsycalMenuView: View {
    @EnvironmentObject var viewModel: ItsycalViewModel

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)

    var body: some View {
        LiquidGlassBackdrop {
            GlassCard {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    weekdayRow
                    calendarGrid
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .frame(minWidth: 360, idealWidth: 380, maxWidth: 420)
        .animation(.smooth(duration: 0.24, extraBounce: 0), value: viewModel.baseDate)
    }

    private var header: some View {
        HStack(spacing: 14) {
            NavigationButton(systemName: "chevron.left") {
                viewModel.stepMonth(by: -1)
            }

            Spacer(minLength: 12)

            Text(viewModel.currentMonthTitle.uppercased())
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .tracking(0.6)
                .foregroundStyle(.primary)

            Spacer(minLength: 12)

            NavigationButton(systemName: "chevron.right") {
                viewModel.stepMonth(by: 1)
            }
        }
    }

    private var weekdayRow: some View {
        HStack(spacing: 8) {
            ForEach(viewModel.weekdaySymbols, id: \.self) { symbol in
                Text(symbol.uppercased())
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var calendarGrid: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(Array(viewModel.weeks.enumerated()), id: \.offset) { _, week in
                ForEach(week) { day in
                    Button {
                        viewModel.select(date: day.id)
                    } label: {
                        Text(day.label)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .frame(maxWidth: .infinity, minHeight: 34)
                            .contentShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .background(dayHighlight(for: day))
                    .clipShape(Circle())
                    .foregroundStyle(day.isCurrentMonth ? Color.primary : Color.secondary)
                    .opacity(day.isCurrentMonth ? 1 : 0.35)
                }
            }
        }
        .animation(.smooth(duration: 0.22, extraBounce: 0), value: viewModel.baseDate)
    }

    private func dayHighlight(for day: ItsycalViewModel.CalendarDay) -> some View {
        let isSelected = viewModel.selectedDate.map { Calendar.current.isDate($0, inSameDayAs: day.id) } ?? false
        let isSpecial = day.isToday || isSelected

        return Group {
            if isSpecial {
                Circle()
                    .fill(Color.accentColor.opacity(isSelected ? 0.34 : 0.24))
                    .overlay(
                        Circle().stroke(Color.white.opacity(0.2), lineWidth: 0.6)
                    )
                    .shadow(color: Color.black.opacity(0.12), radius: 6, y: 2)
            } else {
                Circle().fill(Color.clear)
            }
        }
    }

    private struct NavigationButton: View {
        let systemName: String
        let action: () -> Void

        init(systemName: String, action: @escaping () -> Void) {
            self.systemName = systemName
            self.action = action
        }

        var body: some View {
            Button(action: action) {
                Image(systemName: systemName)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .frame(width: 32, height: 32)
            }
#if canImport(Glass)
            .buttonStyle(.glass)
#else
            .buttonStyle(.borderedProminent)
            .tint(Color.accentColor)
#endif
        }
    }
}

@available(macOS 26.0, *)
private struct GlassCard<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        Group {
#if canImport(Glass)
            GlassEffectContainer {
                content
                    .glassEffect(.group)
            }
            .glassBackground(material: .thin, blurRadius: 22)
#else
            content
                .background(.ultraThinMaterial)
#endif
        }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}
