import Foundation

enum SubjectType: Int, Codable, Sendable {
    case anime = 2
}

enum SubjectSort: String, Codable, Sendable, CaseIterable {
    case rank
    case date
}

struct RatingSummary: Equatable, Sendable {
    let score: Double?
    let totalVotes: Int
}

struct AnimeSubject: Identifiable, Equatable, Sendable {
    let id: Int
    let name: String
    let nameCN: String
    let summary: String
    let imageURL: URL?
    let rating: RatingSummary
    let rank: Int?

    var displayName: String {
        nameCN.isEmpty ? name : nameCN
    }
}
