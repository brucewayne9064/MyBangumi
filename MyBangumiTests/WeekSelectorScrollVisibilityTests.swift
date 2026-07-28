import CoreGraphics
import Testing
@testable import MyBangumi

struct WeekSelectorScrollVisibilityTests {
    @Test func expandsWhenAtTop() {
        let expanded = WeekSelectorScrollVisibility.isExpanded(
            previousOffset: 80,
            currentOffset: 0,
            currentlyExpanded: false
        )
        #expect(expanded == true)
    }

    @Test func collapsesWhenScrollingDownPastThreshold() {
        let expanded = WeekSelectorScrollVisibility.isExpanded(
            previousOffset: 20,
            currentOffset: 52,
            currentlyExpanded: true
        )
        #expect(expanded == false)
    }

    @Test func expandsWhenScrollingUpPastThreshold() {
        let expanded = WeekSelectorScrollVisibility.isExpanded(
            previousOffset: 80,
            currentOffset: 40,
            currentlyExpanded: false
        )
        #expect(expanded == true)
    }

    @Test func keepsCurrentStateForSmallScrollDeltas() {
        let staysExpanded = WeekSelectorScrollVisibility.isExpanded(
            previousOffset: 40,
            currentOffset: 52,
            currentlyExpanded: true
        )
        #expect(staysExpanded == true)

        let staysCollapsed = WeekSelectorScrollVisibility.isExpanded(
            previousOffset: 40,
            currentOffset: 52,
            currentlyExpanded: false
        )
        #expect(staysCollapsed == false)
    }
}
