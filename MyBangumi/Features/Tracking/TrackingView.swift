import SwiftUI

struct TrackingView: View {
    @State var viewModel: TrackingViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                statusPicker
                content
            }
            .padding()
        }
        .navigationTitle("我的动画")
        .task {
            await viewModel.load()
        }
    }

    private var statusPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(CollectionStatus.allCases, id: \.self) { status in
                    Button(status.title) {
                        Task { await viewModel.load(status: status) }
                    }
                    .buttonStyle(.glass)
                    .tint(status == viewModel.selectedStatus ? .primary : .secondary)
                }
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
        case .loaded:
            if viewModel.collections.isEmpty {
                EmptyStateView(title: "暂无\(viewModel.selectedStatus.title)", message: "同步 Bangumi 收藏后会显示在这里。")
            } else {
                GlassEffectContainer(spacing: 16) {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.collections, id: \.subject.id) { collection in
                            UserAnimeCollectionRow(collection: collection)
                        }
                    }
                }
            }
        case .failed(let message):
            ErrorStateView(message: message) {
                Task { await viewModel.load() }
            }
        }
    }
}

private struct UserAnimeCollectionRow: View {
    let collection: UserAnimeCollection

    var body: some View {
        GlassPanel(isInteractive: true) {
            VStack(alignment: .leading, spacing: 8) {
                SubjectCardView(subject: collection.subject)
                HStack {
                    Text(collection.status.title)
                    if collection.rating > 0 {
                        Text("评分 \(collection.rating)")
                    }
                    if !collection.comment.isEmpty {
                        Text(collection.comment)
                            .lineLimit(1)
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        TrackingView(viewModel: TrackingViewModel(api: MockBangumiAPI(collections: [
            .doing: [UserAnimeCollection(subject: .preview, status: .doing, rating: 8, comment: "很喜欢")]
        ]), username: "bruce"))
    }
}
