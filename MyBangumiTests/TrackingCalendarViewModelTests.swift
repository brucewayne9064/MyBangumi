import Foundation
import Testing
@testable import MyBangumi

struct TrackingCalendarViewModelTests {
    @Test @MainActor func calendarLoadsPublicAiringDays() async {
        let subject = AnimeSubject.preview
        let calendarDay = AiringCalendarDay(id: 1, title: "星期一", items: [subject])
        let viewModel = TrackingCalendarViewModel(
            api: MockBangumiAPI(airingCalendar: [calendarDay])
        )

        await viewModel.load()

        #expect(viewModel.days == [calendarDay])
    }

    @Test @MainActor func calendarDefaultsToTodayAndAllowsChangingDay() async {
        let monday = AiringCalendarDay(id: 1, title: "星期一", items: [.preview])
        let wednesday = AiringCalendarDay(id: 3, title: "星期三", items: [])
        let sunday = AiringCalendarDay(id: 7, title: "星期日", items: [])

        // 2026-07-29 is Wednesday → Bangumi weekday id 3
        let viewModel = TrackingCalendarViewModel(
            api: MockBangumiAPI(airingCalendar: [sunday, wednesday, monday]),
            calendar: Calendar(identifier: .gregorian),
            now: { Date(timeIntervalSince1970: 1_785_283_200) }
        )

        await viewModel.load()
        #expect(viewModel.selectedDay == wednesday)

        viewModel.select(dayID: 1)
        #expect(viewModel.selectedDay == monday)
    }

    @Test func bangumiWeekdayMapsSundayToSeven() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        // 2026-07-26 is Sunday UTC
        let sunday = Date(timeIntervalSince1970: 1_785_024_000)
        #expect(TrackingCalendarViewModel.bangumiWeekdayID(for: sunday, calendar: calendar) == 7)

        // 2026-07-27 is Monday UTC
        let monday = Date(timeIntervalSince1970: 1_785_110_400)
        #expect(TrackingCalendarViewModel.bangumiWeekdayID(for: monday, calendar: calendar) == 1)
    }
}
