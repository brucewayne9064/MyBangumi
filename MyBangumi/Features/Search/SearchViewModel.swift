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

    let api: any BangumiAPI
    private let limit = 20
    private var searchTask: Task<Void, Never>?
    private var activeKeyword = ""
    private var searchGeneration = 0

    var keyword = ""
    var state: State = .idle
    var isLoadingMore = false
    var loadMoreError: String?

    init(api: any BangumiAPI) {
        self.api = api
    }

    @MainActor
    func keywordChanged(to value: String) {
        keyword = value
        searchTask?.cancel()
        isLoadingMore = false
        loadMoreError = nil
        searchGeneration += 1
        let generation = searchGeneration

        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else {
            activeKeyword = ""
            state = .idle
            return
        }
        activeKeyword = trimmed

        searchTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(400))
            guard Task.isCancelled == false else { return }
            await self?.performSearch(keyword: trimmed, offset: 0, generation: generation)
        }
    }

    @MainActor
    func search(keyword: String, offset: Int) async {
        self.keyword = keyword
        searchTask?.cancel()
        isLoadingMore = false
        loadMoreError = nil

        let trimmed = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        searchGeneration += 1
        let generation = searchGeneration
        guard trimmed.isEmpty == false else {
            activeKeyword = ""
            state = .idle
            return
        }

        activeKeyword = trimmed
        await performSearch(keyword: trimmed, offset: offset, generation: generation)
    }

    @MainActor
    private func performSearch(keyword: String, offset: Int, generation: Int) async {
        loadMoreError = nil
        state = .loading
        do {
            let page = try await api.searchSubjects(keyword: keyword, type: .anime, limit: limit, offset: offset)
            guard isCurrentSearch(generation: generation, keyword: keyword) else { return }
            state = page.items.isEmpty ? .empty : .loaded(page)
        } catch is CancellationError {
            guard isCurrentSearch(generation: generation, keyword: keyword) else { return }
        } catch {
            guard isCurrentSearch(generation: generation, keyword: keyword) else { return }
            state = .failed(error.localizedDescription)
        }
    }

    @MainActor
    func loadMore() async {
        guard isLoadingMore == false else { return }
        guard case .loaded(let current) = state, current.hasMore else { return }

        let generation = searchGeneration
        let keyword = activeKeyword
        let nextOffset = current.offset + current.items.count
        isLoadingMore = true
        loadMoreError = nil
        defer {
            if generation == searchGeneration {
                isLoadingMore = false
            }
        }

        do {
            let next = try await api.searchSubjects(
                keyword: keyword,
                type: .anime,
                limit: limit,
                offset: nextOffset
            )
            guard isCurrentSearch(generation: generation, keyword: keyword) else { return }
            state = .loaded(PagedSubjects(
                items: current.items + next.items,
                total: next.total,
                limit: current.limit,
                offset: current.offset
            ))
        } catch is CancellationError {
            guard isCurrentSearch(generation: generation, keyword: keyword) else { return }
        } catch {
            guard isCurrentSearch(generation: generation, keyword: keyword) else { return }
            loadMoreError = error.localizedDescription
        }
    }

    @MainActor
    private func isCurrentSearch(generation: Int, keyword: String) -> Bool {
        generation == searchGeneration && keyword == activeKeyword
    }
}
