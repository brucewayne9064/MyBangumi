import SwiftUI

struct DatabaseView: View {
    var body: some View {
        NavigationStack {
            Text("数据库")
                .font(.largeTitle.bold())
                .navigationTitle("数据库")
        }
    }
}

#Preview {
    DatabaseView()
}
