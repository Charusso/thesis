import XCTest

class StatisticsViewUITest: BaseUITest {
  override func setUp() {
    app.buttons["Statistics"].tap()
  }
  
  func testDateIntervalButtonsPresent() {
    XCTAssertTrue(app.buttons["Day"].exists)
    XCTAssertTrue(app.buttons["Week"].exists)
    XCTAssertTrue(app.buttons["Month"].exists)
    XCTAssertTrue(app.buttons["Year"].exists)
  }
  
  func testNavigationButtonsAreDisabledByDefault() {
    XCTAssertTrue(app.buttons["backwards"].exists)
    XCTAssertTrue(app.buttons["reset"].exists)
    XCTAssertTrue(app.buttons["forwards"].exists)
    
    XCTAssertFalse(app.buttons["backwards"].isEnabled)
    XCTAssertFalse(app.buttons["reset"].isEnabled)
    XCTAssertFalse(app.buttons["forwards"].isEnabled)
  }
  
  func testNoDataPresentTwice() {
    XCTAssertTrue(app.staticTexts.matching(identifier: "No data").count == 2,
                  "There should be the 'No data' label on the 2 charts.")
  }
}
