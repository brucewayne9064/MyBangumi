import CoreGraphics
import Testing
@testable import MyBangumi

struct WeekSelectorScrollVisibilityTests {
    @Test func expandsAtTop() {
        #expect(WeekSelectorScrollVisibility.isExpanded(offset: 0) == true)
    }

    @Test func expandsNearTop() {
        #expect(WeekSelectorScrollVisibility.isExpanded(offset: 20) == true)
    }

    @Test func collapsesAfterLeavingTop() {
        #expect(WeekSelectorScrollVisibility.isExpanded(offset: 40) == false)
    }

    @Test func collapsesFurtherDown() {
        #expect(WeekSelectorScrollVisibility.isExpanded(offset: 400) == false)
    }
}
