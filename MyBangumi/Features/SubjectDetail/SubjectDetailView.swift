import SwiftUI

struct SubjectDetailView: View {
    @State var viewModel: SubjectDetailViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                content
            }
            .padding()
        }
        .navigationTitle(viewModel.subject.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.load()
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 16) {
            SubjectPosterView(url: viewModel.subject.imageURL)
            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.subject.displayName)
                    .font(.title2.bold())
                if !viewModel.subject.name.isEmpty {
                    Text(viewModel.subject.name)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                if let score = viewModel.subject.rating.score {
                    Text(String(format: "评分 %.1f", score))
                        .font(.subheadline.bold())
                }
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
                .frame(maxWidth: .infinity)
        case .failed(let message):
            ErrorStateView(message: message) {
                Task { await viewModel.load() }
            }
        case .loaded(let detail):
            detailContent(detail)
        }
    }

    private func detailContent(_ detail: SubjectDetail) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            section(title: "简介", text: detail.summary.isEmpty ? "暂无简介" : detail.summary)

            if detail.tags.isEmpty == false {
                Text("标签")
                    .font(.headline)
                FlowTags(tags: detail.tags)
            }

            if detail.info.isEmpty == false {
                Text("信息")
                    .font(.headline)
                ForEach(detail.info, id: \.key) { item in
                    HStack(alignment: .top) {
                        Text(item.key)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(item.value)
                            .multilineTextAlignment(.trailing)
                    }
                    .font(.subheadline)
                }
            }
        }
    }

    private func section(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Text(text)
                .font(.body)
        }
    }
}

private struct FlowTags: View {
    let tags: [String]

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 8)], alignment: .leading, spacing: 8) {
            ForEach(tags, id: \.self) { tag in
                Text(tag)
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.thinMaterial, in: Capsule())
            }
        }
    }
}
