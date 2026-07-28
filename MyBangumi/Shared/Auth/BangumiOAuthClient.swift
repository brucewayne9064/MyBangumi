import Foundation

struct BangumiOAuthCredentials: Equatable, Sendable {
    let clientID: String
    let clientSecret: String
    let redirectURI: URL
}

struct BangumiOAuthClient: Sendable {
    private let baseURL: URL
    private let session: URLSession
    private let credentials: BangumiOAuthCredentials
    private let now: @Sendable () -> Date

    init(
        baseURL: URL = URL(string: "https://bgm.tv")!,
        session: URLSession = .shared,
        credentials: BangumiOAuthCredentials,
        now: @escaping @Sendable () -> Date = Date.init
    ) {
        self.baseURL = baseURL
        self.session = session
        self.credentials = credentials
        self.now = now
    }

    func exchangeCode(_ code: String) async throws -> OAuthToken {
        try await requestToken(parameters: [
            "grant_type": "authorization_code",
            "client_id": credentials.clientID,
            "client_secret": credentials.clientSecret,
            "code": code,
            "redirect_uri": credentials.redirectURI.absoluteString
        ])
    }

    func refreshToken(_ refreshToken: String) async throws -> OAuthToken {
        try await requestToken(parameters: [
            "grant_type": "refresh_token",
            "client_id": credentials.clientID,
            "client_secret": credentials.clientSecret,
            "refresh_token": refreshToken,
            "redirect_uri": credentials.redirectURI.absoluteString
        ])
    }

    private func requestToken(parameters: [String: String]) async throws -> OAuthToken {
        var request = URLRequest(url: baseURL.appending(path: "/oauth/access_token"))
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = Self.formBody(parameters)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw BangumiAPIError.transport(error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw BangumiAPIError.transport("Missing HTTP response")
        }
        guard 200..<300 ~= httpResponse.statusCode else {
            throw BangumiAPIError.server(statusCode: httpResponse.statusCode)
        }

        let payload = try JSONDecoder().decode(TokenResponse.self, from: data)
        return OAuthToken(
            accessToken: payload.accessToken,
            refreshToken: payload.refreshToken,
            expiresAt: now().addingTimeInterval(TimeInterval(payload.expiresIn)),
            userID: payload.userID
        )
    }

    private static func formBody(_ parameters: [String: String]) -> Data {
        parameters
            .map { key, value in
                "\(key.urlFormEncoded)=\(value.urlFormEncoded)"
            }
            .sorted()
            .joined(separator: "&")
            .data(using: .utf8) ?? Data()
    }
}

private struct TokenResponse: Decodable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
    let userID: Int

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
        case userID = "user_id"
    }
}

private extension String {
    var urlFormEncoded: String {
        addingPercentEncoding(withAllowedCharacters: .urlFormAllowed) ?? self
    }
}

private extension CharacterSet {
    static let urlFormAllowed: CharacterSet = {
        var set = CharacterSet.urlQueryAllowed
        set.remove(charactersIn: ":#[]@!$&'()*+,;=")
        return set
    }()
}
