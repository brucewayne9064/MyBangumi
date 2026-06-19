import SwiftUI

struct GlassPanel<Content: View>: View {
    private let cornerRadius: Double
    private let isInteractive: Bool
    private let content: Content

    init(
        cornerRadius: Double = 24,
        isInteractive: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.isInteractive = isInteractive
        self.content = content()
    }

    var body: some View {
        content
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassEffect(glass, in: .rect(cornerRadius: cornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(.white.opacity(0.16), lineWidth: 1)
            }
    }

    private var glass: Glass {
        isInteractive ? .regular.interactive() : .regular
    }
}
