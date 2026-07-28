import SwiftUI

struct TrackingCalendarView: View {
    @State var viewModel: TrackingCalendarViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    content
                }
                .padding()
            }
            .navigationTitle("追番日历")
            .task {
                await viewModel.load()
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
        case .signedOut:
            EmptyStateView(title: "登录后生成日历", message: "追番日历会基于你的 Bangumi 在看收藏和章节放送日期生成。")
        case .loaded:
            if viewModel.days.isEmpty {
                EmptyStateView(title: "暂无待看章节", message: "在看动画有章节放送日期后会显示在这里。")
            } else {
                ForEach(viewModel.days, id: \.date) { day in
                    daySection(day)
                }
            }
        case .failed(let message):
            ErrorStateView(message: message) {
                Task { await viewModel.load() }
            }
        }
    }

    private func daySection(_ day: CalendarDay) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(day.date)
                .font(.headline)
                .padding(.horizontal, 4)
            ForEach(day.entries, id: \.progress.episode.id) { entry in
                GlassPanel(isInteractive: true) {
                    HStack(spacing: 12) {
                        SubjectPosterView(url: entry.subject.imageURL)
                            .frame(width: 44, height: 62)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.subject.displayName)
                                .font(.subheadline.weight(.semibold))
                            Text("EP \(String(format: "%.0f", entry.progress.episode.sort)) · \(entry.progress.episode.displayName)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(entry.progress.status.title)
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(.thinMaterial, in: Capsule())
                    }
                }
            }
        }
    }
}

#Preview {
    TrackingCalendarView(viewModel: TrackingCalendarViewModel(api: MockBangumiAPI(), username: "bruce"))
}
