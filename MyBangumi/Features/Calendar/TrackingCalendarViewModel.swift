import Foundation
import Observation

@Observable
@MainActor
final class TrackingCalendarViewModel {
    enum State: Equatable {
        case idle
        case loading
        case loaded
        case failed(String)
    }

    let api: any BangumiAPI
    private let calendar: Calendar
    private let now: () -> Date

    var days: [AiringCalendarDay] = []
    var state: State = .idle
    var selectedDayID: Int?

    var selectedDay: AiringCalendarDay? {
        guard let selectedDayID else {
            return days.first
        }
        return days.first { $0.id == selectedDayID } ?? days.first
    }

    init(
        api: any BangumiAPI,
        calendar: Calendar = .current,
        now: @escaping () -> Date = { Date() }
    ) {
        self.api = api
        self.calendar = calendar
        self.now = now
    }

    /// Bangumi weekday ids are Monday=1 ... Sunday=7.
    nonisolated static func bangumiWeekdayID(for date: Date, calendar: Calendar = .current) -> Int {
        let appleWeekday = calendar.component(.weekday, from: date)
        return appleWeekday == 1 ? 7 : appleWeekday - 1
    }

    func load() async {
        state = .loading
        do {
            days = try await api.airingCalendar().sorted { $0.id < $1.id }
            if selectedDayID == nil || days.contains(where: { $0.id == selectedDayID }) == false {
                let todayID = Self.bangumiWeekdayID(for: now(), calendar: calendar)
                selectedDayID = days.first(where: { $0.id == todayID })?.id ?? days.first?.id
            }
            state = .loaded
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func select(dayID: Int) {
        selectedDayID = dayID
    }
}
