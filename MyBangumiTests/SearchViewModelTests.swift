import Foundation
import Testing
@testable import MyBangumi

@MainActor
struct SearchViewModelTests {
    @Test func emptyKeywordReturnsIdleState() {
        let viewModel = SearchViewModel(api: MockBangumiAPI())

        viewModel.keywordChanged(to: "   ")

        #expect(viewModel.state == .idle)
    }

    @Test func keywordChangeDebouncesAndLoadsMatchingSubjects() async {
        let viewModel = SearchViewModel(api: MockBangumiAPI(subjects: [.preview]))

        viewModel.keywordChanged(to: "星际")
        try? await Task.sleep(for: .milliseconds(450))

        guard case .loaded(let page) = viewModel.state else {
            Issue.record("Expected loaded search state after debounce")
            return
        }
        #expect(page.items.first?.displayName == "星际牛仔")
    }

    @Test func explicitSearchLoadsMatchingSubjects() async {
        let viewModel = SearchViewModel(api: MockBangumiAPI(subjects: [.preview]))

        await viewModel.search(keyword: "星际", offset: 0)

        guard case .loaded(let page) = viewModel.state else {
            Issue.record("Expected loaded search state")
            return
        }
        #expect(page.items.first?.displayName == "星际牛仔")
    }

    @Test func loadMoreAppendsRemainingSubjects() async {
        let subjects = (1...25).map(makeSubject(id:))
        let viewModel = SearchViewModel(api: MockBangumiAPI(subjects: subjects))

        await viewModel.search(keyword: "作品", offset: 0)
        await viewModel.loadMore()

        guard case .loaded(let page) = viewModel.state else {
            Issue.record("Expected loaded state after loading more")
            return
        }
        #expect(page.items.count == 25)
        #expect(page.items.first?.id == 1)
        #expect(page.items.last?.id == 25)
        #expect(page.hasMore == false)
    }

    @Test func supersededSearchIgnoresStaleResults() async throws {
        let api = ControlledSearchBangumiAPI()
        let viewModel = SearchViewModel(api: api)
        let oldSubjects = [makeSubject(id: 1), makeSubject(id: 2)]
        let newSubjects = [makeSubject(id: 99)]

        let oldSearch = Task { await viewModel.search(keyword: "old", offset: 0) }
        try await api.waitForRequest(keyword: "old", offset: 0)

        let newSearch = Task { await viewModel.search(keyword: "new", offset: 0) }
        try await api.waitForRequest(keyword: "new", offset: 0)

        await api.succeed(
            keyword: "new",
            offset: 0,
            with: PagedSubjects(items: newSubjects, total: newSubjects.count, limit: 20, offset: 0)
        )
        await newSearch.value

        await api.succeed(
            keyword: "old",
            offset: 0,
            with: PagedSubjects(items: oldSubjects, total: oldSubjects.count, limit: 20, offset: 0)
        )
        await oldSearch.value

        guard case .loaded(let page) = viewModel.state else {
            Issue.record("Expected the newest search result to stay loaded")
            return
        }
        #expect(page.items == newSubjects)
    }

    @Test func supersededSearchIgnoresCancellationError() async throws {
        let api = ControlledSearchBangumiAPI()
        let viewModel = SearchViewModel(api: api)
        let newSubjects = [makeSubject(id: 77)]

        viewModel.keywordChanged(to: "old")
        try? await Task.sleep(for: .milliseconds(450))
        try await api.waitForRequest(keyword: "old", offset: 0)

        viewModel.keywordChanged(to: "new")
        try? await Task.sleep(for: .milliseconds(450))
        try await api.waitForRequest(keyword: "new", offset: 0)

        await api.succeed(
            keyword: "new",
            offset: 0,
            with: PagedSubjects(items: newSubjects, total: newSubjects.count, limit: 20, offset: 0)
        )
        try? await Task.sleep(for: .milliseconds(20))

        await api.fail(keyword: "old", offset: 0, with: CancellationError())
        try? await Task.sleep(for: .milliseconds(20))

        guard case .loaded(let page) = viewModel.state else {
            Issue.record("Expected cancellation from an obsolete request to stay non-user-visible")
            return
        }
        #expect(page.items == newSubjects)
    }

    @Test func overlappingLoadMoreStartsOnlyOnePaginationRequest() async throws {
        let api = ControlledSearchBangumiAPI()
        let viewModel = SearchViewModel(api: api)
        let firstPage = (1...20).map(makeSubject(id:))
        let secondPage = (21...25).map(makeSubject(id:))

        let initialSearch = Task { await viewModel.search(keyword: "作品", offset: 0) }
        try await api.waitForRequest(keyword: "作品", offset: 0)
        await api.succeed(
            keyword: "作品",
            offset: 0,
            with: PagedSubjects(items: firstPage, total: 25, limit: 20, offset: 0)
        )
        await initialSearch.value

        let firstLoadMore = Task { await viewModel.loadMore() }
        try await api.waitForRequest(keyword: "作品", offset: 20)
        #expect(viewModel.isLoadingMore == true)

        let secondLoadMore = Task { await viewModel.loadMore() }
        try? await Task.sleep(for: .milliseconds(20))

        let paginationCount = await api.requestCount(keyword: "作品", offset: 20)
        #expect(paginationCount == 1)

        await api.succeed(
            keyword: "作品",
            offset: 20,
            with: PagedSubjects(items: secondPage, total: 25, limit: 20, offset: 20)
        )
        await firstLoadMore.value
        await secondLoadMore.value

        guard case .loaded(let page) = viewModel.state else {
            Issue.record("Expected pagination to keep the combined loaded state")
            return
        }
        #expect(page.items.count == 25)
        #expect(page.items.last?.id == 25)
        #expect(viewModel.isLoadingMore == false)
    }

    @Test func loadMoreFailureKeepsLoadedResultsAndSurfacesNonDestructiveError() async throws {
        let api = ControlledSearchBangumiAPI()
        let viewModel = SearchViewModel(api: api)
        let firstPage = (1...20).map(makeSubject(id:))

        let initialSearch = Task { await viewModel.search(keyword: "作品", offset: 0) }
        try await api.waitForRequest(keyword: "作品", offset: 0)
        await api.succeed(
            keyword: "作品",
            offset: 0,
            with: PagedSubjects(items: firstPage, total: 25, limit: 20, offset: 0)
        )
        await initialSearch.value

        let loadMore = Task { await viewModel.loadMore() }
        try await api.waitForRequest(keyword: "作品", offset: 20)
        await api.fail(keyword: "作品", offset: 20, with: BangumiAPIError.server(statusCode: 503))
        await loadMore.value

        guard case .loaded(let page) = viewModel.state else {
            Issue.record("Expected pagination failure to preserve the previously loaded state")
            return
        }
        #expect(page.items == firstPage)
        #expect(viewModel.loadMoreError?.isEmpty == false)
        #expect(viewModel.isLoadingMore == false)
    }

    private func makeSubject(id: Int) -> AnimeSubject {
        AnimeSubject(
            id: id,
            name: "Work \(id)",
            nameCN: "作品 \(id)",
            summary: "Summary \(id)",
            imageURL: nil,
            rating: RatingSummary(score: 8.0, totalVotes: 100 + id),
            rank: id
        )
    }
}

private actor ControlledSearchBangumiAPI: BangumiAPI {
    private struct RequestKey: Hashable {
        let keyword: String
        let offset: Int
    }

    private var pending: [RequestKey: [CheckedContinuation<PagedSubjects, Error>]] = [:]
    private var counts: [RequestKey: Int] = [:]

    func me() async throws -> BangumiUser {
        fatalError("Unused in SearchViewModelTests")
    }

    func userCollections(username: String, status: CollectionStatus, limit: Int, offset: Int) async throws -> [UserAnimeCollection] {
        fatalError("Unused in SearchViewModelTests")
    }

    func updateCollection(subjectID: Int, status: CollectionStatus, rating: Int?, comment: String?, isPrivate: Bool) async throws {
        fatalError("Unused in SearchViewModelTests")
    }

    func episodes(subjectID: Int) async throws -> [AnimeEpisode] {
        fatalError("Unused in SearchViewModelTests")
    }

    func episodeProgress(subjectID: Int) async throws -> [EpisodeProgress] {
        fatalError("Unused in SearchViewModelTests")
    }

    func updateEpisodeProgress(episodeID: Int, status: EpisodeCollectionStatus) async throws {
        fatalError("Unused in SearchViewModelTests")
    }

    func browseSubjects(type: SubjectType, sort: SubjectSort, limit: Int, offset: Int) async throws -> PagedSubjects {
        fatalError("Unused in SearchViewModelTests")
    }

    func searchSubjects(keyword: String, type: SubjectType, limit: Int, offset: Int) async throws -> PagedSubjects {
        let key = RequestKey(keyword: keyword, offset: offset)
        counts[key, default: 0] += 1
        return try await withCheckedThrowingContinuation { continuation in
            pending[key, default: []].append(continuation)
        }
    }

    func subject(id: Int) async throws -> SubjectDetail {
        fatalError("Unused in SearchViewModelTests")
    }

    func requestCount(keyword: String, offset: Int) -> Int {
        counts[RequestKey(keyword: keyword, offset: offset), default: 0]
    }

    func waitForRequest(keyword: String, offset: Int, timeout: Duration = .seconds(1)) async throws {
        let key = RequestKey(keyword: keyword, offset: offset)
        let timeoutDate = ContinuousClock.now + timeout

        while counts[key, default: 0] == 0 {
            guard ContinuousClock.now < timeoutDate else {
                throw TimeoutError()
            }
            try await Task.sleep(for: .milliseconds(10))
        }
    }

    func succeed(keyword: String, offset: Int, with page: PagedSubjects) {
        let key = RequestKey(keyword: keyword, offset: offset)
        let continuations = pending.removeValue(forKey: key) ?? []
        continuations.forEach { $0.resume(returning: page) }
    }

    func fail(keyword: String, offset: Int, with error: Error) {
        let key = RequestKey(keyword: keyword, offset: offset)
        let continuations = pending.removeValue(forKey: key) ?? []
        continuations.forEach { $0.resume(throwing: error) }
    }
}

private struct TimeoutError: Error {}
