import XCTest

class BaseUITest: XCTestCase {
  var app: XCUIApplication!
  
  override func setUpWithError() throws {
    continueAfterFailure = false
    
    // Create the app with testing enabled for each test.
    app = XCUIApplication()
    app.launchArguments = ["enable-testing"]
    app.launch()
  }
  
  func testAppHas4Tabs() {
    XCTAssertEqual(app.tabBars.buttons.count, 4, "There should be 4 tabs.")
  }
}
