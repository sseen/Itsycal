import Foundation
import Combine

@available(macOS 26.0, *)
@objcMembers
final class ItsycalViewModel: NSObject, ObservableObject {

    struct CalendarDay: Identifiable, Hashable {
        let id: Date
        let label: String
        let isToday: Bool
        let isCurrentMonth: Bool
    }

    struct QuickModule: Identifiable, Hashable {
        let id = UUID()
        let systemImage: String
        let title: String
        var detail: String
        var isOn: Bool
    }

    struct NowPlaying: Hashable {
        let title: String
        let artist: String
        let artworkSystemImage: String
    }

    static let shared = ItsycalViewModel()

    @Published private(set) var baseDate: Date = Date()
    @Published private(set) var currentMonthTitle: String = ""
    @Published private(set) var weekdaySymbols: [String] = []
    @Published private(set) var weeks: [[CalendarDay]] = []
    @Published var selectedDate: Date? = nil
    @Published var quickModules: [QuickModule] = []
    @Published var nowPlaying: NowPlaying = NowPlaying(title: "", artist: "", artworkSystemImage: "music.note")
    @Published var agendaPreview: [String] = []

    private let calendar: Calendar
    private let monthFormatter: DateFormatter

    override private init() {
        var cal = Calendar.autoupdatingCurrent
        cal.firstWeekday = Calendar.autoupdatingCurrent.firstWeekday
        calendar = cal

        monthFormatter = DateFormatter()
        monthFormatter.calendar = cal
        monthFormatter.dateFormat = "LLLL yyyy"

        super.init()

        weekdaySymbols = monthFormatter.shortWeekdaySymbols
        regenerate(for: baseDate)
        seedMockData()
    }

    @objc class func sharedInstance() -> ItsycalViewModel {
        shared
    }

    @objc func updateBaseDate(_ date: NSDate) {
        baseDate = date as Date
        regenerate(for: baseDate)
    }

    func stepMonth(by offset: Int) {
        guard let next = calendar.date(byAdding: .month, value: offset, to: baseDate) else { return }
        updateBaseDate(next as NSDate)
    }

    func select(date: Date) {
        selectedDate = date
    }

    private func regenerate(for date: Date) {
        currentMonthTitle = monthFormatter.string(from: date)
        weekdaySymbols = reorderWeekdaySymbols()

        guard let range = calendar.range(of: .day, in: .month, for: date),
              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) else {
            weeks = []
            return
        }

        let today = Date()
        let weekday = calendar.component(.weekday, from: firstOfMonth)
        let offset = (weekday - calendar.firstWeekday + 7) % 7
        let gridStart = calendar.date(byAdding: .day, value: -offset, to: firstOfMonth) ?? firstOfMonth

        var days: [CalendarDay] = []
        days.reserveCapacity(42)

        for dayOffset in 0..<42 {
            guard let current = calendar.date(byAdding: .day, value: dayOffset, to: gridStart) else { continue }
            let day = calendar.component(.day, from: current)
            let isCurrentMonth = calendar.isDate(current, equalTo: date, toGranularity: .month)
            let isToday = calendar.isDate(current, inSameDayAs: today)
            let label = String(day)
            days.append(CalendarDay(id: current, label: label, isToday: isToday, isCurrentMonth: isCurrentMonth))
        }

        weeks = stride(from: 0, to: days.count, by: 7).map { index in
            Array(days[index..<min(index + 7, days.count)])
        }

        // Keep selection within visible month if possible
        if let sel = selectedDate, calendar.isDate(sel, equalTo: date, toGranularity: .month) {
            // keep
        } else {
            selectedDate = today
        }
    }

    func toggleModule(_ module: QuickModule) {
        guard let idx = quickModules.firstIndex(of: module) else { return }
        quickModules[idx].isOn.toggle()
        if quickModules[idx].title == "Wi‑Fi" {
            quickModules[idx].detail = quickModules[idx].isOn ? "30F772D9E2" : "关闭"
        } else if quickModules[idx].title == "蓝牙" {
            quickModules[idx].detail = quickModules[idx].isOn ? "已开启" : "关闭"
        }
    }

    private func reorderWeekdaySymbols() -> [String] {
        let symbols = monthFormatter.veryShortWeekdaySymbols ?? calendar.shortStandaloneWeekdaySymbols
        guard calendar.firstWeekday > 1 else { return symbols }
        let startIndex = calendar.firstWeekday - 1
        return Array(symbols[startIndex...] + symbols[..<startIndex])
    }

    private func seedMockData() {
        quickModules = [
            QuickModule(systemImage: "wifi", title: "Wi‑Fi", detail: "30F772D9E2", isOn: true),
            QuickModule(systemImage: "bolt.horizontal.circle", title: "蓝牙", detail: "已开启", isOn: true),
            QuickModule(systemImage: "moon.fill", title: "专注模式", detail: "关闭", isOn: false)
        ]

        nowPlaying = NowPlaying(title: "35 Track 35.mp3", artist: "Arukō – しごとの日本", artworkSystemImage: "music.note")

        agendaPreview = [
            "09:30 和设计评审", "14:00 开发同步", "19:30 健身房"
        ]
    }
}
