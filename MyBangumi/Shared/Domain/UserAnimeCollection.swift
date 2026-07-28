import Foundation

enum CollectionStatus: Int, CaseIterable, Codable, Equatable, Sendable {
    case wish = 1
    case collected = 2
    case doing = 3
    case onHold = 4
    case dropped = 5

    var title: String {
        switch self {
        case .wish:
            "想看"
        case .collected:
            "看过"
        case .doing:
            "在看"
        case .onHold:
            "搁置"
        case .dropped:
            "抛弃"
        }
    }
}

struct UserAnimeCollection: Equatable, Sendable {
    let subject: AnimeSubject
    let status: CollectionStatus
    let rating: Int
    let comment: String
}
