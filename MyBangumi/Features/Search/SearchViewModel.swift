import Foundation
import Observation

@Observable
final class SearchViewModel {
    enum State: Equatable {
        case idle
        case loading
        case loaded(PagedSubjects)
        case empty
        case failed(String)
    }

    private let api: any BangumiAPI
    private let limit = 20
    private var searchTask: Task<Void, Never>?

    var keyword = ""
    var state: State = .idle

    init(api: any BangumiAPI) {
        self.api = api
    }

    @MainActor
    func keywordChanged(to value: String) {
        keyword = value
        searchTask?.cancel()

        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else {
            state = .idle
            return
        }

        searchTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(400))
            guard Task.isCancelled == false else { return }
            await self?.search(keyword: trimmed, offset: 0)
        }
    }

    @MainActor
    func search(keyword: String, offset: Int) async {
        self.keyword = keyword
        state = .loading
        do {
            let page = try await api.searchSubjects(keyword: keyword, type: .anime, limit: limit, offset: offset)
            state = page.items.isEmpty ? .empty : .loaded(page)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    @MainActor
    func loadMore() async {
        guard case .loaded(let current) = state, current.hasMore else { return }
        do {
            let next = try await api.searchSubjects(
                keyword: keyword,
                type: .anime,
                limit: limit,
                offset: current.offset + current.items.count
            )
            state = .loaded(PagedSubjects(
                items: current.items + next.items,
                total: next.total,
                limit: limit,
                offset: 0
            ))
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
