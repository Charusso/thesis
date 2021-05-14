import XCTest
import CoreData
@testable import Tree

class DevelopmentTest: BaseTestCase {
  func testTestingFrameworkCreation() throws {
    try dataController.createTestFramework()
    
    XCTAssertEqual(dataController.count(for: Task.fetchRequest()), 365,
                   "There should be 365 sample tasks.")
    XCTAssertEqual(dataController.count(for: Tag.fetchRequest()), 4,
                   "There should be 4 sample tags.")
  }
  
  func testDeleteAllClearsEverything() throws {
    try dataController.createTestFramework()
    dataController.deleteAll()
    
    XCTAssertEqual(dataController.count(for: Task.fetchRequest()), 0,
                   "Deleting everything should leave 0 tasks.")
    XCTAssertEqual(dataController.count(for: Tag.fetchRequest()), 0,
                   "Deleting everything should leave 0 tags.")
  }
  
  func testUndefinedTagIsLastOrdered() {
    let tag = Tag.undefined
    XCTAssertEqual(tag.orderIndex, Int(Int16.max),
                   "The undefined tag should appear to be the last")
  }
}
