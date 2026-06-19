import XCTest

final class MyBangumiUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testRootTabsExist() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.tabBars.buttons["发现"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.tabBars.buttons["数据库"].exists)
        XCTAssertTrue(app.tabBars.buttons["我的"].exists)
        XCTAssertTrue(app.tabBars.buttons["搜索"].exists)
    }
}
