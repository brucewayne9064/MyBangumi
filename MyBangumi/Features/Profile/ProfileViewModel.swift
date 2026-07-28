import Foundation
import Observation

@Observable
@MainActor
final class ProfileViewModel {
    enum State: Equatable {
        case loading
        case signedOut
        case authenticated(BangumiUser)
        case failed(String)
    }

    let api: any BangumiAPI
    private let appSession: AppSession
    private let signInHandler: OAuthSignInHandler?
    var state: State = .loading

    init(api: any BangumiAPI, appSession: AppSession, signInHandler: OAuthSignInHandler? = nil) {
        self.api = api
        self.appSession = appSession
        self.signInHandler = signInHandler
    }

    var canSignIn: Bool {
        signInHandler != nil
    }

    func load() async {
        guard appSession.authState.token != nil else {
            state = .signedOut
            return
        }

        state = .loading
        do {
            state = .authenticated(try await api.me())
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func signOut() async {
        await appSession.signOut()
        state = .signedOut
    }

    func signIn() async {
        guard let signInHandler else {
            state = .failed("请先在 Scheme 环境变量中配置 Bangumi OAuth。")
            return
        }
        state = .loading
        do {
            let token = try await signInHandler()
            await appSession.signIn(with: token)
            await load()
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
