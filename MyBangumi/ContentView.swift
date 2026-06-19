import SwiftUI

struct ContentView: View {
    let api: any BangumiAPI

    init(api: any BangumiAPI) {
        self.api = api
    }

    var body: some View {
        TabView {
            DiscoverView(viewModel: DiscoverViewModel(api: api))
                .tabItem {
                    Label("发现", systemImage: "sparkles")
                }

            DatabaseView(viewModel: DatabaseViewModel(api: api))
                .tabItem {
                    Label("数据库", systemImage: "rectangle.stack")
                }

            ProfileView()
                .tabItem {
                    Label("我的", systemImage: "person.crop.circle")
                }

            SearchView()
                .tabItem {
                    Label("搜索", systemImage: "magnifyingglass")
                }
        }
    }
}

#Preview {
    ContentView(api: MockBangumiAPI())
}
