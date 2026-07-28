import Foundation
import Testing
@testable import MyBangumi

struct AuthFoundationTests {
    @Test func oauthConfigurationBuildsAuthorizeURL() throws {
        let configuration = BangumiOAuthConfiguration(
            clientID: "client-id",
            redirectURI: URL(string: "mybangumi://oauth")!
        )

        let url = try configuration.authorizeURL(state: "state-token")
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let query = Dictionary(uniqueKeysWithValues: (components?.queryItems ?? []).compactMap { item in
            item.value.map { (item.name, $0) }
        })

        #expect(components?.scheme == "https")
        #expect(components?.host == "bgm.tv")
        #expect(components?.path == "/oauth/authorize")
        #expect(query["response_type"] == "code")
        #expect(query["client_id"] == "client-id")
        #expect(query["redirect_uri"] == "mybangumi://oauth")
        #expect(query["state"] == "state-token")
    }

    @Test func memoryTokenStoreSavesLoadsAndDeletesToken() async throws {
        let store = MemoryTokenStore()
        let token = OAuthToken(
            accessToken: "access-token",
            refreshToken: "refresh-token",
            expiresAt: Date(timeIntervalSince1970: 100),
            userID: 42
        )

        try await store.save(token)
        #expect(try await store.load() == token)

        try await store.delete()
        #expect(try await store.load() == nil)
    }

    @Test func apiClientAddsBearerTokenWhenAvailable() async throws {
        let client = makeClient(accessToken: "access-token")
        URLProtocolStub.handler = { request in
            #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer access-token")
            let data = """
            { "data": [], "total": 0, "limit": 20, "offset": 0 }
            """.data(using: .utf8)!
            return (HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!, data)
        }

        _ = try await client.browseSubjects(type: .anime, sort: .rank, limit: 20, offset: 0)
    }

    @Test func oauthClientExchangesCodeForToken() async throws {
        let client = makeOAuthClient()
        URLProtocolStub.handler = { request in
            #expect(request.url?.absoluteString == "https://bgm.example.test/oauth/access_token")
            #expect(request.httpMethod == "POST")
            #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/x-www-form-urlencoded")
            let body = String(data: request.httpBody ?? Data(), encoding: .utf8) ?? ""
            #expect(body.contains("grant_type=authorization_code"))
            #expect(body.contains("client_id=client-id"))
            #expect(body.contains("client_secret=client-secret"))
            #expect(body.contains("code=auth-code"))

            let data = """
            {
              "access_token": "access-token",
              "refresh_token": "refresh-token",
              "expires_in": 604800,
              "token_type": "Bearer",
              "user_id": 42
            }
            """.data(using: .utf8)!
            return (HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!, data)
        }

        let token = try await client.exchangeCode("auth-code")

        #expect(token.accessToken == "access-token")
        #expect(token.refreshToken == "refresh-token")
        #expect(token.userID == 42)
        #expect(token.expiresAt > Date())
    }

    @Test @MainActor func appSessionRestoresAndClearsStoredToken() async throws {
        let store = MemoryTokenStore()
        let token = OAuthToken(
            accessToken: "access-token",
            refreshToken: "refresh-token",
            expiresAt: Date(timeIntervalSince1970: 100),
            userID: 42
        )
        try await store.save(token)
        let session = AppSession(tokenStore: store)

        await session.restore()
        #expect(session.authState == .authenticated(token))

        await session.signOut()
        #expect(session.authState == .signedOut)
        #expect(try await store.load() == nil)
    }

    private func makeClient(accessToken: String?) -> BangumiAPIClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        return BangumiAPIClient(
            baseURL: URL(string: "https://api.example.test")!,
            session: session,
            accessTokenProvider: { accessToken }
        )
    }

    private func makeOAuthClient() -> BangumiOAuthClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        return BangumiOAuthClient(
            baseURL: URL(string: "https://bgm.example.test")!,
            session: session,
            credentials: BangumiOAuthCredentials(
                clientID: "client-id",
                clientSecret: "client-secret",
                redirectURI: URL(string: "mybangumi://oauth")!
            )
        )
    }
}
