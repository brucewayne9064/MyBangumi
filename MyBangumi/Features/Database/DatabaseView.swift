import SwiftUI

struct DatabaseView: View {
    @State var viewModel: DatabaseViewModel

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .loading:
                    ProgressView()
                case .loaded(let page):
                    if page.items.isEmpty {
                        EmptyStateView(title: "暂无条目", message: "当前排序下没有动画条目。")
                    } else {
                        ScrollView {
                            GlassEffectContainer(spacing: 16) {
                                LazyVStack(spacing: 12) {
                                    ForEach(page.items) { subject in
                                        NavigationLink {
                                            SubjectDetailView(viewModel: SubjectDetailViewModel(subject: subject, api: viewModel.api))
                                        } label: {
                                            SubjectCardView(subject: subject)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                case .failed(let message):
                    ErrorStateView(message: message) {
                        Task { await viewModel.load() }
                    }
                }
            }
            .navigationTitle("数据库")
            .toolbar {
                Menu {
                    Picker("排序", selection: $viewModel.sort) {
                        Text("排名").tag(SubjectSort.rank)
                        Text("日期").tag(SubjectSort.date)
                    }
                } label: {
                    Label(sortTitle, systemImage: "arrow.up.arrow.down")
                }
            }
            .task {
                await viewModel.load()
            }
            .onChange(of: viewModel.sort) {
                Task { await viewModel.load() }
            }
        }
    }

    private var sortTitle: String {
        switch viewModel.sort {
        case .rank:
            "排名"
        case .date:
            "日期"
        }
    }
}

#Preview {
    DatabaseView(viewModel: DatabaseViewModel(api: MockBangumiAPI()))
}
