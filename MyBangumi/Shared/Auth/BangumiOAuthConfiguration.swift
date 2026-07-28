import Foundation

struct BangumiOAuthConfiguration: Equatable, Sendable {
    let clientID: String
    let redirectURI: URL
    var authorizeBaseURL = URL(string: "https://bgm.tv/oauth/authorize")!

    func authorizeURL(state: String) throws -> URL {
        var components = URLComponents(url: authorizeBaseURL, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "redirect_uri", value: redirectURI.absoluteString),
            URLQueryItem(name: "state", value: state)
        ]
        guard let url = components?.url else { throw BangumiAuthError.invalidAuthorizeURL }
        return url
    }
}

enum BangumiAuthError: Error, Equatable, LocalizedError {
    case invalidAuthorizeURL
    case missingAuthorizationCode
    case stateMismatch
    case tokenUnavailable

    var errorDescription: String? {
        switch self {
        case .invalidAuthorizeURL:
            "无法创建 Bangumi 授权地址。"
        case .missingAuthorizationCode:
            "Bangumi 授权回调缺少验证码。"
        case .stateMismatch:
            "Bangumi 授权状态不匹配，请重试。"
        case .tokenUnavailable:
            "当前没有可用的登录凭证。"
        }
    }
}
