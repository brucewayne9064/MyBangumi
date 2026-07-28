import Foundation
import Testing
@testable import MyBangumi

struct ProfileViewModelTests {
    @Test @MainActor func profileShowsSignedOutWhenSessionHasNoToken() async {
        let session = AppSession(tokenStore: MemoryTokenStore())
        let viewModel = ProfileViewModel(api: MockBangumiAPI(), appSession: session)

        await session.restore()
        await viewModel.load()

        #expect(viewModel.state == .signedOut)
    }

    @Test @MainActor func profileLoadsCurrentUserWhenAuthenticated() async {
        let token = OAuthToken(
            accessToken: "access-token",
            refreshToken: "refresh-token",
            expiresAt: Date(timeIntervalSinceNow: 3600),
            userID: 42
        )
        let session = AppSession(tokenStore: MemoryTokenStore())
        await session.signIn(with: token)
        let user = BangumiUser(id: 42, username: "bruce", nickname: "Bruce", avatarURL: URL(string: "https://example.com/avatar.jpg"))
        let viewModel = ProfileViewModel(api: MockBangumiAPI(currentUser: user), appSession: session)

        await viewModel.load()

        #expect(viewModel.state == .authenticated(user))
    }
}
