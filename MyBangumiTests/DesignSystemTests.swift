import SwiftUI
import Testing
@testable import MyBangumi

struct DesignSystemTests {
    @Test @MainActor func glassPanelWrapsContent() {
        _ = GlassPanel { Text("Hello") }
        _ = GlassPanel(isInteractive: true) { Text("Interactive") }
    }

    @Test @MainActor func subjectPosterViewAcceptsOptionalURL() {
        _ = SubjectPosterView(url: nil)
        _ = SubjectPosterView(url: URL(string: "https://example.com/poster.jpg"))
    }

    @Test @MainActor func subjectCardViewAcceptsAnimeSubject() {
        _ = SubjectCardView(subject: .preview)
    }

    @Test @MainActor func errorAndEmptyStateViewsInitialize() {
        _ = ErrorStateView(message: "加载失败") {}
        _ = EmptyStateView(title: "暂无内容", message: "试试其他关键词")
    }
}
