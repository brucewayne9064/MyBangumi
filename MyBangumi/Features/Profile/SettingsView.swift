import SwiftUI

struct SettingsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                GlassPanel {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("MyBangumi", systemImage: "sparkles")
                            .font(.title2.bold())
                        Text("一个使用 Bangumi Public API 的原生 iOS 客户端。")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                settingsGroup(title: "数据") {
                    LabeledContent("数据来源", value: "Bangumi Public API")
                    LabeledContent("缓存策略", value: "内存缓存")
                    LabeledContent("持久化", value: "后续版本")
                }

                settingsGroup(title: "账号") {
                    LabeledContent("登录", value: "即将支持")
                    LabeledContent("收藏同步", value: "即将支持")
                }
            }
            .padding()
        }
        .navigationTitle("设置")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func settingsGroup<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .padding(.horizontal, 4)

            GlassPanel {
                VStack(spacing: 12) {
                    content()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
