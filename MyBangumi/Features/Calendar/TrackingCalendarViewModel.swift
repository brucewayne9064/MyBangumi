import Foundation
import Observation

@Observable
@MainActor
final class TrackingCalendarViewModel {
    enum State: Equatable {
        case idle
        case loading
        case loaded
        case failed(String)
    }

    private let api: any BangumiAPI

    var days: [AiringCalendarDay] = []
    var state: State = .idle

    init(api: any BangumiAPI) {
        self.api = api
    }

    func load() async {
        state = .loading
        do {
            days = try await api.airingCalendar().sorted { $0.id < $1.id }
            state = .loaded
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
