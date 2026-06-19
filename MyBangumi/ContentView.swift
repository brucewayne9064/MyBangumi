import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DiscoverView()
                .tabItem {
                    Label("发现", systemImage: "sparkles")
                }

            DatabaseView()
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
    ContentView()
}
