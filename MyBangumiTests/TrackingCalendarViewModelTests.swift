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

    @Test @MainActor func calendarSelectsFirstDayAndAllowsChangingDay() async {
        let monday = AiringCalendarDay(id: 1, title: "星期一", items: [.preview])
        let tuesday = AiringCalendarDay(id: 2, title: "星期二", items: [])
        let viewModel = TrackingCalendarViewModel(
            api: MockBangumiAPI(airingCalendar: [tuesday, monday])
        )

        await viewModel.load()
        #expect(viewModel.selectedDay == monday)

        viewModel.select(dayID: 2)
        #expect(viewModel.selectedDay == tuesday)
    }
}
