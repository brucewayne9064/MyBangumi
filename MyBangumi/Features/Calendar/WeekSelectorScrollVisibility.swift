import Foundation

enum WeekSelectorScrollVisibility {
    /// How close to the top counts as expanded.
    static let topEdgeThreshold: CGFloat = 24

    static func isExpanded(
        offset: CGFloat,
        topEdgeThreshold: CGFloat = topEdgeThreshold
    ) -> Bool {
        offset <= topEdgeThreshold
    }
}
