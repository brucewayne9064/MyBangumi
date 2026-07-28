import Testing
@testable import MyBangumi

struct ViewModelStateTests {
    @Test @MainActor func databaseLoadsSubjects() async {
        let viewModel = DatabaseViewModel(api: MockBangumiAPI(subjects: [.preview]))

        await viewModel.load()

        guard case .loaded(let page) = viewModel.state else {
            Issue.record("Expected loaded state")
            return
        }
        #expect(page.items == [.preview])
    }

    @Test @MainActor func databaseMapsErrorsToFailedState() async {
        let viewModel = DatabaseViewModel(api: MockBangumiAPI(error: .server(statusCode: 500)))

        await viewModel.load()

        guard case .failed(let message) = viewModel.state else {
            Issue.record("Expected failed state")
            return
        }
        #expect(message.isEmpty == false)
    }

    @Test @MainActor func databaseAppliesFilterDraftSort() {
        let viewModel = DatabaseViewModel(api: MockBangumiAPI(subjects: [.preview]))
        var draft = DatabaseFilterDraft(sort: .rank)

        draft.sort = .date
        viewModel.apply(filter: draft)

        #expect(viewModel.sort == .date)
    }

    @Test @MainActor func discoverLoadsRankedAndRecentSubjects() async {
        let viewModel = DiscoverViewModel(api: MockBangumiAPI(subjects: [.preview]))

        await viewModel.load()

        guard case .loaded(let ranked) = viewModel.ranked else {
            Issue.record("Expected ranked subjects to load")
            return
        }
        guard case .loaded(let recent) = viewModel.recent else {
            Issue.record("Expected recent subjects to load")
            return
        }
        #expect(ranked == [.preview])
        #expect(recent == [.preview])
    }

    @Test @MainActor func discoverLoadIsIdempotentAfterContentLoaded() async {
        let api = CountingBrowseBangumiAPI()
        let viewModel = DiscoverViewModel(api: api)

        await viewModel.load()
        await viewModel.load()

        #expect(await api.browseRequestCount == 2)
    }

    @Test @MainActor func discoverReloadForcesFreshRequests() async {
        let api = CountingBrowseBangumiAPI()
        let viewModel = DiscoverViewModel(api: api)

        await viewModel.load()
        await viewModel.reload()

        #expect(await api.browseRequestCount == 4)
    }

    @Test @MainActor func discoverMapsErrorsToFailedStates() async {
        let viewModel = DiscoverViewModel(api: MockBangumiAPI(error: .server(statusCode: 500)))

        await viewModel.load()

        guard case .failed(let rankedMessage) = viewModel.ranked else {
            Issue.record("Expected ranked failure state")
            return
        }
        guard case .failed(let recentMessage) = viewModel.recent else {
            Issue.record("Expected recent failure state")
            return
        }
        #expect(rankedMessage.isEmpty == false)
        #expect(recentMessage.isEmpty == false)
    }
}

private actor CountingBrowseBangumiAPI: BangumiAPI {
    private(set) var browseRequestCount = 0

    func me() async throws -> BangumiUser {
        .preview
    }

    func userCollections(username: String, status: CollectionStatus, limit: Int, offset: Int) async throws -> [UserAnimeCollection] {
        []
    }

    func updateCollection(subjectID: Int, status: CollectionStatus, rating: Int?, comment: String?, isPrivate: Bool) async throws {}

    func episodes(subjectID: Int) async throws -> [AnimeEpisode] {
        []
    }

    func episodeProgress(subjectID: Int) async throws -> [EpisodeProgress] {
        []
    }

    func updateEpisodeProgress(episodeID: Int, status: EpisodeCollectionStatus) async throws {}

    func browseSubjects(type: SubjectType, sort: SubjectSort, limit: Int, offset: Int) async throws -> PagedSubjects {
        browseRequestCount += 1
        return PagedSubjects(items: [.preview], total: 1, limit: limit, offset: offset)
    }

    func searchSubjects(keyword: String, type: SubjectType, limit: Int, offset: Int) async throws -> PagedSubjects {
        PagedSubjects(items: [], total: 0, limit: limit, offset: offset)
    }

    func subject(id: Int) async throws -> SubjectDetail {
        .preview
    }
}
