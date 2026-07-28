import SwiftUI

struct SubjectPosterView: View {
    let url: URL?
    var width: CGFloat = 92
    var height: CGFloat = 132

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                fallback
                    .overlay { ProgressView() }
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            case .failure:
                fallback
            @unknown default:
                fallback
            }
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .accessibilityHidden(true)
    }

    private var fallback: some View {
        LinearGradient(
            colors: [Color(.tertiarySystemFill), Color(.secondarySystemFill)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay {
            Image(systemName: "photo")
                .font(.title3)
                .foregroundStyle(.secondary.opacity(0.45))
        }
    }
}
