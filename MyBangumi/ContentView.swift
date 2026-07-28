import SwiftUI

struct ContentView: View {
    let api: any BangumiAPI
    let appSession: AppSession
    let oauthSignInHandler: OAuthSignInHandler?
    @State private var discoverViewModel: DiscoverViewModel

    init(api: any BangumiAPI, appSession: AppSession, oauthSignInHandler: OAuthSignInHandler? = nil) {
        self.api = api
        self.appSession = appSession
        self.oauthSignInHandler = oauthSignInHandler
        _discoverViewModel = State(initialValue: DiscoverViewModel(api: api))
    }

    var body: some View {
        TabView {
            Tab("发现", systemImage: "sparkles") {
                DiscoverView(viewModel: discoverViewModel)
            }

            Tab("数据库", systemImage: "rectangle.stack") {
                DatabaseView(viewModel: DatabaseViewModel(api: api))
            }

            Tab("日历", systemImage: "calendar") {
                TrackingCalendarView(viewModel: TrackingCalendarViewModel(api: api))
            }

            Tab("我的", systemImage: "person.crop.circle") {
                ProfileView(viewModel: ProfileViewModel(api: api, appSession: appSession, signInHandler: oauthSignInHandler))
            }

            Tab(role: .search) {
                SearchView(viewModel: SearchViewModel(api: api))
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
        .background {
            TabBarReselectObserver(observedIndex: 0) {
                Task { await discoverViewModel.reload() }
            }
            .frame(width: 0, height: 0)
        }
    }
}

#Preview {
    ContentView(api: MockBangumiAPI(), appSession: AppSession(tokenStore: MemoryTokenStore()))
}
