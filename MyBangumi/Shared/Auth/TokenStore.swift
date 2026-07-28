import Foundation

protocol TokenStore: Sendable {
    func load() async throws -> OAuthToken?
    func save(_ token: OAuthToken) async throws
    func delete() async throws
}

actor MemoryTokenStore: TokenStore {
    private var token: OAuthToken?

    func load() async throws -> OAuthToken? {
        token
    }

    func save(_ token: OAuthToken) async throws {
        self.token = token
    }

    func delete() async throws {
        token = nil
    }
}
