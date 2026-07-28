import Testing
@testable import MyBangumi

struct TrackingCalendarViewModelTests {
    @Test @MainActor func calendarGroupsDoingEpisodesByAirdate() async {
        let subject = AnimeSubject.preview
        let collection = UserAnimeCollection(subject: subject, status: .doing, rating: 0, comment: "")
        let episode = AnimeEpisode(id: 10, sort: 1, name: "Session 1", nameCN: "第一集", airdate: "2026-07-28")
        let progress = EpisodeProgress(episode: episode, status: .none)
        let viewModel = TrackingCalendarViewModel(
            api: MockBangumiAPI(collections: [.doing: [collection]], episodeProgress: [progress]),
            username: "bruce"
        )

        await viewModel.load()

        #expect(viewModel.days == [
            CalendarDay(date: "2026-07-28", entries: [
                CalendarEntry(subject: subject, progress: progress)
            ])
        ])
    }
}
