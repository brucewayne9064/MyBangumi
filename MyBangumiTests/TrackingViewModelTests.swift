import Testing
@testable import MyBangumi

struct TrackingViewModelTests {
    @Test @MainActor func trackingLoadsDoingCollections() async {
        let collection = UserAnimeCollection(subject: .preview, status: .doing, rating: 8, comment: "很喜欢")
        let viewModel = TrackingViewModel(api: MockBangumiAPI(collections: [.doing: [collection]]), username: "bruce")

        await viewModel.load(status: .doing)

        #expect(viewModel.selectedStatus == .doing)
        #expect(viewModel.collections == [collection])
    }
}
