import AuthenticationServices
import Foundation
import UIKit

typealias OAuthSignInHandler = @MainActor () async throws -> OAuthToken

protocol OAuthWebAuthenticating: Sendable {
    @MainActor
    func authorize(url: URL, callbackURLScheme: String) async throws -> URL
}

struct BangumiOAuthSignInService: Sendable {
    private let credentials: BangumiOAuthCredentials
    private let oauthClient: BangumiOAuthClient
    private let webAuthenticator: any OAuthWebAuthenticating
    private let stateProvider: @Sendable () -> String

    @MainActor
    init(
        credentials: BangumiOAuthCredentials,
        oauthClient: BangumiOAuthClient? = nil,
        webAuthenticator: (any OAuthWebAuthenticating)? = nil,
        stateProvider: @escaping @Sendable () -> String = { UUID().uuidString }
    ) {
        self.credentials = credentials
        self.oauthClient = oauthClient ?? BangumiOAuthClient(credentials: credentials)
        self.webAuthenticator = webAuthenticator ?? ASWebAuthenticationSessionAuthenticator()
        self.stateProvider = stateProvider
    }

    @MainActor
    func signIn() async throws -> OAuthToken {
        let state = stateProvider()
        let configuration = BangumiOAuthConfiguration(clientID: credentials.clientID, redirectURI: credentials.redirectURI)
        let authorizeURL = try configuration.authorizeURL(state: state)
        guard let callbackURLScheme = credentials.redirectURI.scheme else {
            throw BangumiAuthError.invalidAuthorizeURL
        }

        let callbackURL = try await webAuthenticator.authorize(url: authorizeURL, callbackURLScheme: callbackURLScheme)
        let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false)
        let query = Dictionary(uniqueKeysWithValues: (components?.queryItems ?? []).compactMap { item in
            item.value.map { (item.name, $0) }
        })
        guard query["state"] == state else { throw BangumiAuthError.stateMismatch }
        guard let code = query["code"], code.isEmpty == false else { throw BangumiAuthError.missingAuthorizationCode }
        return try await oauthClient.exchangeCode(code)
    }
}

@MainActor
final class ASWebAuthenticationSessionAuthenticator: NSObject, OAuthWebAuthenticating, ASWebAuthenticationPresentationContextProviding {
    private var session: ASWebAuthenticationSession?

    func authorize(url: URL, callbackURLScheme: String) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(url: url, callbackURLScheme: callbackURLScheme) { callbackURL, error in
                if let callbackURL {
                    continuation.resume(returning: callbackURL)
                } else {
                    continuation.resume(throwing: error ?? BangumiAuthError.missingAuthorizationCode)
                }
            }
            session.presentationContextProvider = self
            session.prefersEphemeralWebBrowserSession = false
            self.session = session
            if session.start() == false {
                continuation.resume(throwing: BangumiAuthError.missingAuthorizationCode)
            }
        }
    }

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow } ?? ASPresentationAnchor()
    }
}
