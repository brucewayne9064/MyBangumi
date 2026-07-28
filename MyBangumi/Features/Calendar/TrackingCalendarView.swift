import SwiftUI

struct TrackingCalendarView: View {
    @State var viewModel: TrackingCalendarViewModel
    @State private var isWeekSelectorExpanded = true

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 20) {
                    content
                        .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .onScrollGeometryChange(for: CGFloat.self) { geometry in
                geometry.contentOffset.y
            } action: { oldOffset, newOffset in
                updateWeekSelectorExpansion(previousOffset: oldOffset, currentOffset: newOffset)
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                if showsWeekSelector {
                    weekSelectorChrome
                }
            }
            .background(calendarBackground)
            .toolbar(.hidden, for: .navigationBar)
            .task {
                await viewModel.load()
            }
        }
    }

    private var showsWeekSelector: Bool {
        guard case .loaded = viewModel.state else { return false }
        return viewModel.days.isEmpty == false && viewModel.selectedDay != nil
    }

    private var calendarBackground: some View {
        Color(.systemGroupedBackground)
        .ignoresSafeArea()
    }

    private func updateWeekSelectorExpansion(previousOffset: CGFloat, currentOffset: CGFloat) {
        guard showsWeekSelector else { return }

        let nextExpanded = WeekSelectorScrollVisibility.isExpanded(
            previousOffset: previousOffset,
            currentOffset: currentOffset,
            currentlyExpanded: isWeekSelectorExpanded
        )
        guard nextExpanded != isWeekSelectorExpanded else { return }
        isWeekSelectorExpanded = nextExpanded
    }

    private var weekSelectorChrome: some View {
        HStack(spacing: 0) {
            weekSelectorBar
            if isWeekSelectorExpanded == false {
                Spacer(minLength: 0)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .padding(.bottom, 8)
        .frame(minHeight: 52, alignment: .leading)
        .animation(.snappy(duration: 0.22), value: isWeekSelectorExpanded)
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
            } else if let selectedDay = viewModel.selectedDay {
                dayOverview(selectedDay)
            } else {
                EmptyStateView(title: "暂无放送数据", message: "Bangumi 每日放送暂时没有可展示内容。")
            }
        case .failed(let message):
            ErrorStateView(message: message) {
                Task { await viewModel.load() }
            }
        }
    }

    private var weekSelectorBar: some View {
        Group {
            if isWeekSelectorExpanded {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(viewModel.days, id: \.id) { day in
                            Button {
                                viewModel.select(dayID: day.id)
                            } label: {
                                weekdayChip(day)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(day.title)
                            .accessibilityValue("\(day.items.count) 部")
                            .accessibilityHint("切换到\(day.title)的每日放送")
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .glassEffect(.regular, in: .rect(cornerRadius: 22))
            } else {
                Button {
                    isWeekSelectorExpanded = true
                } label: {
                    Text(collapsedWeekOrbTitle)
                        .font(.headline.weight(.bold))
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .foregroundStyle(BangumiTheme.accent)
                .clipShape(Circle())
                .glassEffect(.regular, in: .circle)
                .accessibilityLabel(viewModel.selectedDay?.title ?? "每日放送")
                .accessibilityHint("展开星期选择")
            }
        }
    }

    private var collapsedWeekOrbTitle: String {
        guard let selectedDay = viewModel.selectedDay else { return "放送" }
        let shortTitle = shortWeekdayTitle(selectedDay.title)
        return shortTitle.isEmpty ? japaneseWeekdayMark(selectedDay.id) : shortTitle
    }

    private func weekdayChip(_ day: AiringCalendarDay) -> some View {
        let isSelected = viewModel.selectedDay?.id == day.id

        return ZStack {
            Text(japaneseWeekdayMark(day.id))
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundStyle(isSelected ? Color.white.opacity(0.28) : BangumiTheme.accent.opacity(0.14))
                .offset(x: 7, y: -6)

            VStack(spacing: 1) {
                Text(shortWeekdayTitle(day.title))
                    .font(.caption.weight(.semibold))
                Text("\(day.items.count) 部")
                    .font(.caption2.weight(.medium))
                    .opacity(isSelected ? 0.86 : 1)
                    .foregroundStyle(isSelected ? .white : .secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: 44, height: 36)
        .clipped()
        .foregroundStyle(isSelected ? .white : .primary)
        .background(isSelected ? BangumiTheme.accent : Color.clear, in: Capsule())
    }

    private func dayOverview(_ day: AiringCalendarDay) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(day.title)
                        .font(.largeTitle.weight(.bold))
                    Text("Bangumi 每日放送 · \(day.items.count) 部")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            if day.items.isEmpty {
                EmptyStateView(title: "当天暂无条目", message: "可以切换到其他星期查看每日放送。")
            } else {
                if let featured = featuredSubject(in: day) {
                    featuredBanner(featured, totalCount: day.items.count)
                }
                broadcastList(day.items)
            }
        }
    }

    private func featuredBanner(_ subject: AnimeSubject, totalCount: Int) -> some View {
        NavigationLink {
            SubjectDetailView(viewModel: SubjectDetailViewModel(subject: subject, api: viewModel.api))
        } label: {
            HeroPosterBackgroundView(url: subject.imageURL)
            .frame(height: 220)
            .overlay(
                LinearGradient(
                    colors: [.clear, .black.opacity(0.62)],
                    startPoint: .center,
                    endPoint: .bottom
                )
            )
            .overlay(alignment: .bottom) {
                featuredBannerText(subject, totalCount: totalCount)
            }
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(.white.opacity(0.18), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }

    private func featuredBannerText(_ subject: AnimeSubject, totalCount: Int) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text("今日焦点")
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(BangumiTheme.accent, in: Capsule())

                Text("共 \(totalCount) 部")
                    .font(.caption.weight(.semibold))
                    .opacity(0.82)
            }

            Text(subject.displayName)
                .font(.title2.weight(.bold))
                .lineLimit(2)

            HStack(spacing: 10) {
                if let score = subject.rating.score {
                    Label(String(format: "%.1f", score), systemImage: "star.fill")
                }
                if let rank = subject.rank {
                    Text("#\(rank)")
                }
            }
            .font(.caption.weight(.semibold))
            .opacity(0.86)
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background {
            LinearGradient(
                colors: [.black.opacity(0.78), .black.opacity(0.52), .clear],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }

    @ViewBuilder
    private func broadcastList(_ subjects: [AnimeSubject]) -> some View {
        if subjects.isEmpty == false {
            VStack(alignment: .leading, spacing: 12) {
                Text("放送清单")
                    .font(.headline)

                VStack(spacing: 14) {
                    ForEach(subjects) { subject in
                        broadcastRow(subject)
                    }
                }
            }
        }
    }

    private func broadcastRow(_ subject: AnimeSubject) -> some View {
        NavigationLink {
            SubjectDetailView(viewModel: SubjectDetailViewModel(subject: subject, api: viewModel.api))
        } label: {
            HStack(alignment: .center, spacing: 14) {
                SubjectPosterView(url: subject.imageURL, width: 72, height: 104)

                VStack(alignment: .leading, spacing: 8) {
                    Text(subject.displayName)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(2)

                    HStack(spacing: 8) {
                        if let score = subject.rating.score {
                            Label(String(format: "%.1f", score), systemImage: "star.fill")
                                .foregroundStyle(BangumiTheme.accent)
                        }
                        if let rank = subject.rank {
                            Text("#\(rank)")
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 132, alignment: .leading)
            .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
        }
        .buttonStyle(.plain)
    }

    private func featuredSubject(in day: AiringCalendarDay) -> AnimeSubject? {
        day.items.max { lhs, rhs in
            let lhsScore = lhs.rating.score ?? 0
            let rhsScore = rhs.rating.score ?? 0
            if lhsScore != rhsScore {
                return lhsScore < rhsScore
            }

            let lhsRank = lhs.rank ?? Int.max
            let rhsRank = rhs.rank ?? Int.max
            return lhsRank > rhsRank
        }
    }

    private func shortWeekdayTitle(_ title: String) -> String {
        title
            .replacingOccurrences(of: "星期", with: "")
            .replacingOccurrences(of: "周", with: "")
    }

    private func japaneseWeekdayMark(_ id: Int) -> String {
        switch id {
        case 1: "月"
        case 2: "火"
        case 3: "水"
        case 4: "木"
        case 5: "金"
        case 6: "土"
        case 7: "日"
        default: ""
        }
    }
}

private struct HeroPosterBackgroundView: View {
    let url: URL?

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            default:
                LinearGradient(
                    colors: [Color(.tertiarySystemFill), BangumiTheme.accent.opacity(0.12)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
    }
}

#Preview {
    TrackingCalendarView(viewModel: TrackingCalendarViewModel(api: MockBangumiAPI(airingCalendar: [
        AiringCalendarDay(id: 1, title: "星期一", items: [.preview]),
        AiringCalendarDay(id: 2, title: "星期二", items: [
            AnimeSubject(id: 2, name: "Sousou no Frieren", nameCN: "葬送的芙莉莲", summary: "", imageURL: nil, rating: RatingSummary(score: 8.6, totalVotes: 6200), rank: 18),
            AnimeSubject(id: 3, name: "Dungeon Meshi", nameCN: "迷宫饭", summary: "", imageURL: nil, rating: RatingSummary(score: 8.1, totalVotes: 4800), rank: 60)
        ]),
        AiringCalendarDay(id: 3, title: "星期三", items: [])
    ])))
}
