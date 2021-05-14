import XCTest
import CoreData
@testable import Tree

class PerformanceTest: BaseTestCase {
  func testDateIntervalTraversalPerformance() throws {
    // Given spending at least 6 hours every day within the app for a year.
    let hours = 6
    for _ in 0..<hours {
      try dataController.createTestFramework()
    }
    
    let tasks =
      try managedObjectContext.fetch(NSFetchRequest<Task>(entityName: "Task"))
    XCTAssertEqual(tasks.count, 365 * hours,
                   "The volume of the test is changed.")
    
    // When the date interval is a year to traverse.
    let dateHandler = DateHandler()
    dateHandler.selectedInterval = .Year
    let taskHandler = TaskHandler(dataController: dataController,
                                  dateHandler: dateHandler)
    
    // Then
    var minuteSum = 0
    measure {
      // First part of the year.
      dateHandler.enumerateDates{ date in
        minuteSum += taskHandler.getMinutes(at: date)
      }
      dateHandler.traverseBackwards()
      // Second part of the year.
      dateHandler.enumerateDates{ date in
        minuteSum += taskHandler.getMinutes(at: date)
      }
    }
    
    XCTAssertTrue(Int(Double(minuteSum) / 60 / 365) >= hours)
  }
}
