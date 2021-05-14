import XCTest

class SettingsViewUITest: BaseUITest {
  override func setUp() {
    app.buttons["Settings"].tap()
  }
  
  func testTheTestModeIsEnabled() {
    XCTAssertTrue(app.switches["test mode"].exists)
    XCTAssertEqual(app.switches["test mode"].value as! String, "1")
  }
  
  func testDNDModeDisabled() {
    XCTAssertTrue(app.switches["DND mode"].exists)
    XCTAssertEqual(app.switches["DND mode"].value as! String, "0")
  }
}
