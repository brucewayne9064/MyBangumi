import Foundation

struct OAuthToken: Codable, Equatable, Sendable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: Date
    let userID: Int

    var isExpired: Bool {
        expiresAt <= Date()
    }
}
