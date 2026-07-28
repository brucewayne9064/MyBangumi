import SwiftUI

struct ContentView: View {
    let api: any BangumiAPI
    let appSession: AppSession

    init(api: any BangumiAPI, appSession: AppSession) {
        self.api = api
        self.appSession = appSession
    }

    var body: some View {
        TabView {
            Tab("发现", systemImage: "sparkles") {
                DiscoverView(viewModel: DiscoverViewModel(api: api))
            }

            Tab("数据库", systemImage: "rectangle.stack") {
                DatabaseView(viewModel: DatabaseViewModel(api: api))
            }

            Tab("我的", systemImage: "person.crop.circle") {
                ProfileView()
            }

            Tab(role: .search) {
                SearchView(viewModel: SearchViewModel(api: api))
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}

#Preview {
    ContentView(api: MockBangumiAPI(), appSession: AppSession(tokenStore: MemoryTokenStore()))
}
