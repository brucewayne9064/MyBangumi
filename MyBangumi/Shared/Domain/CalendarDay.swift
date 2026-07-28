import Foundation

struct CalendarEntry: Equatable, Sendable {
    let subject: AnimeSubject
    let progress: EpisodeProgress
}

struct CalendarDay: Equatable, Sendable {
    let date: String
    let entries: [CalendarEntry]
}
