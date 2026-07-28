import Foundation
import Observation

enum AuthState: Equatable {
    case restoring
    case signedOut
    case authenticated(OAuthToken)
    case failed(String)

    var token: OAuthToken? {
        if case .authenticated(let token) = self {
            return token
        }
        return nil
    }
}

@Observable
@MainActor
final class AppSession {
    private let tokenStore: any TokenStore
    private(set) var authState: AuthState = .restoring

    init(tokenStore: any TokenStore = KeychainTokenStore()) {
        self.tokenStore = tokenStore
    }

    var accessToken: String? {
        authState.token?.accessToken
    }

    func restore() async {
        do {
            if let token = try await tokenStore.load(), !token.isExpired {
                authState = .authenticated(token)
            } else {
                authState = .signedOut
            }
        } catch {
            authState = .failed(error.localizedDescription)
        }
    }

    func signIn(with token: OAuthToken) async {
        do {
            try await tokenStore.save(token)
            authState = .authenticated(token)
        } catch {
            authState = .failed(error.localizedDescription)
        }
    }

    func signOut() async {
        do {
            try await tokenStore.delete()
            authState = .signedOut
        } catch {
            authState = .failed(error.localizedDescription)
        }
    }
}
