import SwiftUI

struct SearchView: View {
    @State var viewModel: SearchViewModel

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .idle:
                    EmptyStateView(title: "搜索动画", message: "输入关键词查找 Bangumi 动画条目。")
                case .loading:
                    ProgressView()
                case .empty:
                    EmptyStateView(title: "没有结果", message: "换一个关键词试试。")
                case .failed(let message):
                    ErrorStateView(message: message) {
                        Task { await viewModel.search(keyword: viewModel.keyword, offset: 0) }
                    }
                case .loaded(let page):
                    List {
                        ForEach(page.items) { subject in
                            NavigationLink {
                                SubjectDetailView(viewModel: SubjectDetailViewModel(subject: subject, api: viewModel.api))
                            } label: {
                                SubjectCardView(subject: subject)
                            }
                            .listRowSeparator(.hidden)
                        }
                        if page.hasMore {
                            VStack(spacing: 8) {
                                if let loadMoreError = viewModel.loadMoreError {
                                    Text(loadMoreError)
                                        .font(.footnote)
                                        .foregroundStyle(.red)
                                        .multilineTextAlignment(.center)
                                }

                                Button(viewModel.isLoadingMore ? "加载中..." : "加载更多") {
                                    Task { await viewModel.loadMore() }
                                }
                                .disabled(viewModel.isLoadingMore)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("搜索")
            .searchable(text: Binding(
                get: { viewModel.keyword },
                set: { viewModel.keywordChanged(to: $0) }
            ), prompt: "搜索动画")
        }
    }
}

#Preview {
    SearchView(viewModel: SearchViewModel(api: MockBangumiAPI()))
}
