import SwiftUI

struct DiscoverView: View {
    @State var viewModel: DiscoverViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    module(title: "高分动画", state: viewModel.ranked)
                    module(title: "近期动画", state: viewModel.recent)
                }
                .padding()
            }
            .refreshable {
                await viewModel.reload()
            }
            .navigationTitle("发现")
            .task {
                await viewModel.load()
            }
        }
    }

    @ViewBuilder
    private func module(title: String, state: DiscoverViewModel.ModuleState) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title2.bold())
            switch state {
            case .loading:
                ProgressView()
                    .frame(maxWidth: .infinity)
            case .loaded(let subjects):
                if subjects.isEmpty {
                    EmptyStateView(title: "暂无内容", message: "这个模块暂时没有可展示的动画。")
                } else {
                    GlassEffectContainer(spacing: 16) {
                        ForEach(subjects) { subject in
                            NavigationLink {
                                SubjectDetailView(viewModel: SubjectDetailViewModel(subject: subject, api: viewModel.api))
                            } label: {
                                SubjectCardView(subject: subject)
                            }
                            .buttonStyle(.plain)
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
}

#Preview {
    DiscoverView(viewModel: DiscoverViewModel(api: MockBangumiAPI()))
}
