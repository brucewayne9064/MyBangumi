import SwiftUI

struct GlassPanel<Content: View>: View {
    private let material: Material
    private let content: Content

    init(material: Material = .thinMaterial, @ViewBuilder content: () -> Content) {
        self.material = material
        self.content = content()
    }

    var body: some View {
        content
            .padding()
            .background(material, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .glassEffect()
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(.white.opacity(0.18), lineWidth: 1)
            }
    }
}
