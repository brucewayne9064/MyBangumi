import Testing
@testable import MyBangumi

@MainActor
struct SubjectDetailViewModelTests {
    @Test func detailLoadsSubject() async {
        let viewModel = SubjectDetailViewModel(subject: .preview, api: MockBangumiAPI(detail: .preview))
        await viewModel.load()

        guard case .loaded(let detail) = viewModel.state else {
            Issue.record("Expected loaded detail")
            return
        }
        #expect(detail.displayName == "星际牛仔")
    }

    @Test func detailLoadsEpisodeProgress() async {
        let episode = AnimeEpisode(id: 10, sort: 1, name: "Session 1", nameCN: "第一集", airdate: "1998-04-03")
        let progress = EpisodeProgress(episode: episode, status: .watched)
        let viewModel = SubjectDetailViewModel(
            subject: .preview,
            api: MockBangumiAPI(episodes: [episode], episodeProgress: [progress])
        )

        await viewModel.load()

        #expect(viewModel.episodeProgress == [progress])
    }
}
