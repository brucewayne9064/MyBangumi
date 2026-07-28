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
}
