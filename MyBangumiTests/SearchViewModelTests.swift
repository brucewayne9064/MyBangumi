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
