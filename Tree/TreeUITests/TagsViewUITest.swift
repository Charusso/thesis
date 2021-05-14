import XCTest

class TagsViewUITest: BaseUITest {
  override func setUp() {
    app.buttons["Tags"].tap()
  }
  
  func testAddTagsYieldOneNewTag() {
    XCTAssertEqual(app.tables.cells.count, 1,
                   "There should be the undefined tag only.")
    
    for _ in 0..<3 {
      app.buttons["add"].tap()
      XCTAssertEqual(app.tables.cells.count, 2,
                     "There should be 2 list rows because it prevents the user"
                      + " to add new tags by accident.")
    }
  }
  
  func testEditingTagUpdatesCorrectly() {
    XCTAssertEqual(app.tables.cells.count, 1,
                   "There should be the undefined tag only.")
    
    app.buttons["add"].tap()
    XCTAssertEqual(app.tables.cells.count, 2,
                   "There should be 2 list rows after adding a tag.")
    
    app.buttons["New tag"].tap()
    app.textFields["Name"].tap()
    
    // We need to enable the software keyboard in the I/O - keyboard settings
    // via disabling the hardware keyboard.
    app.keys["space"].tap()
    app.keys["more"].tap()
    app.keys["2"].tap()
    app.buttons["return"].tap()
    
    app.buttons["Tag list"].tap()
    XCTAssertTrue(app.buttons["New tag 2"].exists,
                  "The new tag should be visible and updated in the list.")
  }
}
