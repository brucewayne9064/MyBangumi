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
                        List(page.items) { subject in
                            NavigationLink {
                                SubjectDetailView(viewModel: SubjectDetailViewModel(subject: subject, api: viewModel.api))
                            } label: {
                                SubjectCardView(subject: subject)
                            }
                            .listRowSeparator(.hidden)
                        }
                        .listStyle(.plain)
                    }
                case .failed(let message):
                    ErrorStateView(message: message) {
                        Task { await viewModel.load() }
                    }
                }
            }
            .navigationTitle("数据库")
            .toolbar {
                Picker("排序", selection: $viewModel.sort) {
                    Text("排名").tag(SubjectSort.rank)
                    Text("日期").tag(SubjectSort.date)
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
}

#Preview {
    DatabaseView(viewModel: DatabaseViewModel(api: MockBangumiAPI()))
}
