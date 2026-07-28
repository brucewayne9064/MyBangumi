import Foundation

struct AiringCalendarDay: Equatable, Sendable {
    let id: Int
    let title: String
    let items: [AnimeSubject]
}
