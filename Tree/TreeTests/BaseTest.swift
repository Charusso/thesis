import XCTest
import CoreData
@testable import Tree

/// It creates the testing environment.
class BaseTestCase: XCTestCase {
  var dataController: DataController!
  var managedObjectContext: NSManagedObjectContext!
  
  override func setUpWithError() throws {
    dataController = DataController(isTest: true)
    managedObjectContext = dataController.container.viewContext
  }
}
