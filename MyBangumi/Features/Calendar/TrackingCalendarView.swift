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
            .navigationTitle("每日放送")
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
        case .loaded:
            if viewModel.days.isEmpty {
                EmptyStateView(title: "暂无放送数据", message: "Bangumi 每日放送暂时没有可展示内容。")
            } else {
                ForEach(viewModel.days, id: \.id) { day in
                    daySection(day)
                }
            }
        case .failed(let message):
            ErrorStateView(message: message) {
                Task { await viewModel.load() }
            }
        }
    }

    private func daySection(_ day: AiringCalendarDay) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(day.title)
                .font(.headline)
                .padding(.horizontal, 4)
            ForEach(day.items) { subject in
                GlassPanel(isInteractive: true) {
                    HStack(spacing: 12) {
                        SubjectPosterView(url: subject.imageURL)
                            .frame(width: 44, height: 62)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(subject.displayName)
                                .font(.subheadline.weight(.semibold))
                            if let score = subject.rating.score {
                                Text(String(format: "评分 %.1f", score))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                    }
                }
            }
        }
    }
}

#Preview {
    TrackingCalendarView(viewModel: TrackingCalendarViewModel(api: MockBangumiAPI(airingCalendar: [
        AiringCalendarDay(id: 1, title: "星期一", items: [.preview])
    ])))
}
