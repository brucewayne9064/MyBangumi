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
}
