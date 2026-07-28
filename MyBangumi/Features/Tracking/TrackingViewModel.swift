import Foundation
import Observation

@Observable
@MainActor
final class TrackingViewModel {
    enum State: Equatable {
        case idle
        case loading
        case loaded
        case failed(String)
    }

    private let api: any BangumiAPI
    private let username: String
    private let limit = 50

    var selectedStatus: CollectionStatus = .doing
    var collections: [UserAnimeCollection] = []
    var state: State = .idle

    init(api: any BangumiAPI, username: String) {
        self.api = api
        self.username = username
    }

    func load(status: CollectionStatus? = nil) async {
        let targetStatus = status ?? selectedStatus
        selectedStatus = targetStatus
        state = .loading
        do {
            collections = try await api.userCollections(username: username, status: targetStatus, limit: limit, offset: 0)
            state = .loaded
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
