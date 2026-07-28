import Foundation

struct AnimeEpisode: Identifiable, Equatable, Sendable {
    let id: Int
    let sort: Double
    let name: String
    let nameCN: String
    let airdate: String

    var displayName: String {
        nameCN.isEmpty ? name : nameCN
    }
}

enum EpisodeCollectionStatus: Int, Codable, Equatable, Sendable {
    case none = 0
    case wish = 1
    case watched = 2
    case dropped = 3

    var title: String {
        switch self {
        case .none:
            "未看"
        case .wish:
            "想看"
        case .watched:
            "看过"
        case .dropped:
            "抛弃"
        }
    }
}

struct EpisodeProgress: Equatable, Sendable {
    let episode: AnimeEpisode
    var status: EpisodeCollectionStatus
}
