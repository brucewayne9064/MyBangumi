import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            Text("我的")
                .font(.largeTitle.bold())
                .navigationTitle("我的")
        }
    }
}

#Preview {
    ProfileView()
}
