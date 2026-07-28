import Foundation

enum WeekSelectorScrollVisibility {
    /// Ignore tiny scroll jitter so expansion does not thrash mid-fling.
    static let minimumDelta: CGFloat = 24

    static func isExpanded(
        previousOffset: CGFloat,
        currentOffset: CGFloat,
        currentlyExpanded: Bool,
        minimumDelta: CGFloat = minimumDelta
    ) -> Bool {
        if currentOffset <= 0 {
            return true
        }

        let delta = currentOffset - previousOffset
        guard abs(delta) >= minimumDelta else {
            return currentlyExpanded
        }

        return delta < 0
    }
}
