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
    var collectionMessage: String?
    var episodeProgress: [EpisodeProgress] = []

    init(subject: AnimeSubject, api: any BangumiAPI) {
        self.subject = subject
        self.api = api
    }

    @MainActor
    func load() async {
        state = .loading
        do {
            state = .loaded(try await api.subject(id: subject.id))
            episodeProgress = (try? await api.episodeProgress(subjectID: subject.id)) ?? []
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    @MainActor
    func updateCollection(status: CollectionStatus) async {
        do {
            try await api.updateCollection(subjectID: subject.id, status: status, rating: nil, comment: nil, isPrivate: false)
            collectionMessage = "已标记为\(status.title)"
        } catch {
            collectionMessage = error.localizedDescription
        }
    }

    @MainActor
    func markEpisodeWatched(_ progress: EpisodeProgress) async {
        do {
            try await api.updateEpisodeProgress(episodeID: progress.episode.id, status: .watched)
            episodeProgress = episodeProgress.map { item in
                item.episode.id == progress.episode.id
                    ? EpisodeProgress(episode: item.episode, status: .watched)
                    : item
            }
        } catch {
            collectionMessage = error.localizedDescription
        }
    }
}
