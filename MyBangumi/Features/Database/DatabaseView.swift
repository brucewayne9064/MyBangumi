import SwiftUI

struct DatabaseView: View {
    @State var viewModel: DatabaseViewModel
    @State private var filterDraft = DatabaseFilterDraft()
    @State private var isShowingFilters = false

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
                Button {
                    filterDraft = DatabaseFilterDraft(sort: viewModel.sort)
                    isShowingFilters = true
                } label: {
                    Label("筛选", systemImage: "line.3.horizontal.decrease")
                }
            }
            .sheet(isPresented: $isShowingFilters) {
                DatabaseFilterSheet(
                    draft: $filterDraft,
                    onReset: {
                        filterDraft = DatabaseFilterDraft()
                    },
                    onApply: {
                        viewModel.apply(filter: filterDraft)
                        isShowingFilters = false
                        Task { await viewModel.load() }
                    }
                )
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
            .task {
                await viewModel.load()
            }
        }
    }
}

private struct DatabaseFilterSheet: View {
    @Binding var draft: DatabaseFilterDraft
    let onReset: () -> Void
    let onApply: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                GlassEffectContainer(spacing: 18) {
                    VStack(alignment: .leading, spacing: 18) {
                        GlassPanel {
                            VStack(alignment: .leading, spacing: 8) {
                                Label("数据库筛选", systemImage: "line.3.horizontal.decrease.circle")
                                    .font(.title2.bold())
                                Text("当前按\(sortTitle)浏览动画条目。更多筛选会在后续 API 能力接入后开放。")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        filterSection(title: "排序", subtitle: "会影响 Bangumi API 请求") {
                            HStack(spacing: 10) {
                                FilterChip(
                                    title: "排名",
                                    systemImage: "chart.bar.fill",
                                    isSelected: draft.sort == .rank
                                ) {
                                    draft.sort = .rank
                                }

                                FilterChip(
                                    title: "日期",
                                    systemImage: "calendar",
                                    isSelected: draft.sort == .date
                                ) {
                                    draft.sort = .date
                                }
                            }
                        }

                        filterSection(title: "类型", subtitle: "首版先专注动画") {
                            HStack(spacing: 10) {
                                FilterChip(title: "动画", systemImage: "play.rectangle.fill", isSelected: true) {}
                                FilterChip(title: "书籍", systemImage: "book.closed", isSelected: false, isEnabled: false) {}
                                FilterChip(title: "游戏", systemImage: "gamecontroller", isSelected: false, isEnabled: false) {}
                            }
                        }

                        filterSection(title: "时间", subtitle: "即将支持") {
                            HStack(spacing: 10) {
                                FilterChip(title: "全部", systemImage: "clock", isSelected: true) {}
                                FilterChip(title: "近年", systemImage: "sparkle.magnifyingglass", isSelected: false, isEnabled: false) {}
                                FilterChip(title: "近期", systemImage: "calendar.badge.clock", isSelected: false, isEnabled: false) {}
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("筛选")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("重置", action: onReset)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("应用", action: onApply)
                        .buttonStyle(.glass)
                }
            }
        }
    }

    private var sortTitle: String {
        switch draft.sort {
        case .rank:
            "排名"
        case .date:
            "日期"
        }
    }
}

private struct FilterChip: View {
    let title: String
    let systemImage: String
    let isSelected: Bool
    var isEnabled = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.subheadline.weight(isSelected ? .semibold : .regular))
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .foregroundStyle(isEnabled ? .primary : .secondary)
                .glassEffect(glass, in: .capsule)
                .overlay {
                    Capsule()
                        .stroke(strokeColor, lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.48)
    }

    private var glass: Glass {
        isSelected ? .regular.interactive() : .clear.interactive()
    }

    private var strokeColor: Color {
        isSelected ? Color.primary.opacity(0.24) : Color.white.opacity(0.12)
    }
}

private func filterSection<Content: View>(
    title: String,
    subtitle: String,
    @ViewBuilder content: () -> Content
) -> some View {
    VStack(alignment: .leading, spacing: 10) {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 4)

        GlassPanel {
            content()
        }
    }
}

#Preview {
    DatabaseView(viewModel: DatabaseViewModel(api: MockBangumiAPI()))
}
