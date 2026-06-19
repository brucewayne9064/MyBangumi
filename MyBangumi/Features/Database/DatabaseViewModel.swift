import Foundation
import Observation

struct DatabaseFilterDraft: Equatable {
    var sort: SubjectSort = .rank
}

@Observable
final class DatabaseViewModel {
    enum State: Equatable {
        case loading
        case loaded(PagedSubjects)
        case failed(String)
    }

    let api: any BangumiAPI
    private let limit = 20
    var sort: SubjectSort = .rank
    var state: State = .loading

    init(api: any BangumiAPI) {
        self.api = api
    }

    @MainActor
    func apply(filter: DatabaseFilterDraft) {
        sort = filter.sort
    }

    @MainActor
    func load(offset: Int = 0) async {
        state = .loading
        do {
            let page = try await api.browseSubjects(type: .anime, sort: sort, limit: limit, offset: offset)
            state = .loaded(page)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
