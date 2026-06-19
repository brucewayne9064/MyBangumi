import SwiftUI

struct SubjectCardView: View {
    let subject: AnimeSubject

    var body: some View {
        GlassPanel {
            HStack(alignment: .top, spacing: 14) {
                SubjectPosterView(url: subject.imageURL)

                VStack(alignment: .leading, spacing: 8) {
                    Text(subject.displayName)
                        .font(.headline)
                        .lineLimit(2)

                    if !subject.nameCN.isEmpty && subject.nameCN != subject.name {
                        Text(subject.name)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }

                    HStack(spacing: 8) {
                        if let score = subject.rating.score {
                            Text(String(format: "%.1f", score))
                                .font(.caption.bold())
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.regularMaterial, in: Capsule())
                        }
                        if let rank = subject.rank {
                            Text("#\(rank)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Text(subject.summary.isEmpty ? "暂无简介" : subject.summary)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                }
            }
        }
    }
}
