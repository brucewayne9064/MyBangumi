import Foundation
import Observation

@Observable
final class SubjectDetailViewModel {
    enum State: Equatable {
        case loading
        case loaded(SubjectDetail)
        case failed(String)
    }

    private let api: any BangumiAPI
    let subject: AnimeSubject
    var state: State = .loading

    init(subject: AnimeSubject, api: any BangumiAPI) {
        self.subject = subject
        self.api = api
    }

    @MainActor
    func load() async {
        state = .loading
        do {
            state = .loaded(try await api.subject(id: subject.id))
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
