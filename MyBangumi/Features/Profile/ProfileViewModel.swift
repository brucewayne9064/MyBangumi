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

    private let api: any BangumiAPI
    private let appSession: AppSession
    var state: State = .loading

    init(api: any BangumiAPI, appSession: AppSession) {
        self.api = api
        self.appSession = appSession
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
}
