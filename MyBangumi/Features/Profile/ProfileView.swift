import SwiftUI

struct ProfileView: View {
    @State var viewModel: ProfileViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    content
                    aboutSection
                }
                .padding()
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
            .task {
                await viewModel.load()
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
        case .signedOut:
            signedOutCard
        case .authenticated(let user):
            userCard(user)
            trackingEntry(user)
            accountActions
        case .failed(let message):
            ErrorStateView(message: message) {
                Task { await viewModel.load() }
            }
        }
    }

    private var signedOutCard: some View {
        GlassPanel {
            VStack(alignment: .leading, spacing: 12) {
                Label("登录 Bangumi", systemImage: "person.crop.circle.badge.plus")
                    .font(.title2.bold())
                Text("登录后可以同步你的收藏、在看进度和追番日历。OAuth 授权入口将在配置 Bangumi 应用凭据后启用。")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Button("准备登录") {}
                    .buttonStyle(.glass)
                    .disabled(true)
            }
        }
    }

    private func userCard(_ user: BangumiUser) -> some View {
        GlassPanel {
            HStack(alignment: .center, spacing: 14) {
                AsyncImage(url: user.avatarURL) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 64, height: 64)
                .clipShape(Circle())

                VStack(alignment: .leading, spacing: 6) {
                    Text(user.nickname)
                        .font(.title2.bold())
                    Text("@\(user.username)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("Bangumi ID \(user.id)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func trackingEntry(_ user: BangumiUser) -> some View {
        NavigationLink {
            TrackingView(viewModel: TrackingViewModel(api: viewModel.api, username: user.username))
        } label: {
            GlassPanel(isInteractive: true) {
                HStack {
                    Label("我的动画", systemImage: "play.rectangle.stack")
                        .font(.headline)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var accountActions: some View {
        GlassPanel {
            Button(role: .destructive) {
                Task { await viewModel.signOut() }
            } label: {
                Label("退出登录", systemImage: "rectangle.portrait.and.arrow.right")
            }
            .buttonStyle(.plain)
        }
    }

    private var aboutSection: some View {
        GlassPanel {
            VStack(alignment: .leading, spacing: 12) {
                LabeledContent("数据来源", value: "Bangumi Public API")
                LabeledContent("缓存策略", value: "内存缓存 + Keychain 凭证")
                Link("GitHub", destination: URL(string: "https://github.com/brucewayne9064/MyBangumi")!)
            }
        }
    }
}

#Preview {
    ProfileView(viewModel: ProfileViewModel(api: MockBangumiAPI(), appSession: AppSession(tokenStore: MemoryTokenStore())))
}
