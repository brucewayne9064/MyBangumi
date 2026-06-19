import SwiftUI

struct SearchView: View {
    var body: some View {
        NavigationStack {
            Text("搜索")
                .font(.largeTitle.bold())
                .navigationTitle("搜索")
        }
    }
}

#Preview {
    SearchView()
}
