import SwiftUI

struct DiscoverView: View {
    var body: some View {
        NavigationStack {
            Text("发现")
                .font(.largeTitle.bold())
                .navigationTitle("发现")
        }
    }
}

#Preview {
    DiscoverView()
}
