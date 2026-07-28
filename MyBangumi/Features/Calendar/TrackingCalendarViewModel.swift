import Foundation
import Observation

@Observable
@MainActor
final class TrackingCalendarViewModel {
    enum State: Equatable {
        case idle
        case loading
        case loaded
        case signedOut
        case failed(String)
    }

    private let api: any BangumiAPI
    private var username: String?

    var days: [CalendarDay] = []
    var state: State = .idle

    init(api: any BangumiAPI, username: String? = nil) {
        self.api = api
        self.username = username
    }

    func load() async {
        state = .loading
        do {
            let username = try await resolvedUsername()
            let doing = try await api.userCollections(username: username, status: .doing, limit: 50, offset: 0)
            let entries = try await calendarEntries(for: doing)
            days = Dictionary(grouping: entries, by: { $0.progress.episode.airdate })
                .map { CalendarDay(date: $0.key, entries: $0.value.sorted { $0.progress.episode.sort < $1.progress.episode.sort }) }
                .sorted { $0.date < $1.date }
            state = .loaded
        } catch BangumiAuthError.tokenUnavailable {
            state = .signedOut
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    private func resolvedUsername() async throws -> String {
        if let username {
            return username
        }
        let user = try await api.me()
        username = user.username
        return user.username
    }

    private func calendarEntries(for collections: [UserAnimeCollection]) async throws -> [CalendarEntry] {
        var entries: [CalendarEntry] = []
        for collection in collections {
            let progress = try await api.episodeProgress(subjectID: collection.subject.id)
            entries += progress
                .filter { !$0.episode.airdate.isEmpty }
                .map { CalendarEntry(subject: collection.subject, progress: $0) }
        }
        return entries
    }
}
