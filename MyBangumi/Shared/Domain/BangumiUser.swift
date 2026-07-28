import Foundation

struct BangumiUser: Equatable, Sendable {
    let id: Int
    let username: String
    let nickname: String
    let avatarURL: URL?
}
