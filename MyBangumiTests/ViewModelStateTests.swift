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
