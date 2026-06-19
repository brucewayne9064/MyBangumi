import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("登录与同步")
                            .font(.headline)
                        Text("Bangumi 登录、收藏、追番进度和章节管理将在后续版本支持。")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                }

                Section("关于") {
                    LabeledContent("数据来源", value: "Bangumi Public API")
                    LabeledContent("缓存策略", value: "内存缓存")
                    Link("GitHub", destination: URL(string: "https://github.com/brucewayne9064/MyBangumi")!)
                }
            }
            .navigationTitle("我的")
            .toolbar {
                NavigationLink {
                    SettingsView()
                } label: {
                    Image(systemName: "gearshape")
                }
                .accessibilityLabel("设置")
            }
        }
    }
}

#Preview {
    ProfileView()
}
