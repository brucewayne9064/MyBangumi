import XCTest

final class MyBangumiUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testRootTabsExist() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-useMockAPI")
        app.launch()

        XCTAssertTrue(app.tabBars.buttons["发现"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.tabBars.buttons["数据库"].exists)
        XCTAssertTrue(app.tabBars.buttons["我的"].exists)
        XCTAssertTrue(app.tabBars.buttons["搜索"].exists)
    }

    @MainActor
    func testCanSwitchBetweenAllTabs() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-useMockAPI")
        app.launch()

        for title in ["发现", "数据库", "我的", "搜索"] {
            app.tabBars.buttons[title].tap()
            XCTAssertTrue(app.navigationBars[title].waitForExistence(timeout: 3))
        }
    }
}
