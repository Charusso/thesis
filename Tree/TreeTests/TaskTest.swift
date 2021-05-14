import XCTest
import CoreData
@testable import Tree

class TaskTest: BaseTestCase {
  func testCreatingTask() {
    let taskCount = 13
    
    for _ in 0..<taskCount {
      _ = Task(context: managedObjectContext)
    }
    
    XCTAssertEqual(dataController.count(for: Task.fetchRequest()), taskCount)
  }
  
  func testCreatingTag() {
    let tagCount = 13
    
    for _ in 0..<tagCount {
      _ = Tag(context: managedObjectContext)
    }
    
    XCTAssertEqual(dataController.count(for: Tag.fetchRequest()), tagCount)
  }
  
  func testDeletingTagMarksAsZombie() {
    let tag = Tag(context: managedObjectContext)
    XCTAssertFalse(tag.isZombie)
    tag.delete()
    XCTAssertTrue(tag.isZombie)
  }
  
  func testDeletingTaskDoesNotDeleteItsTag() {
    let tag = Tag(context: managedObjectContext)
    let task = Task(context: managedObjectContext)
    task.tag_ = tag
    XCTAssertFalse(task.isDeleted)
    XCTAssertFalse(tag.isDeleted)
    
    dataController.delete(task)
    XCTAssertTrue(task.isDeleted)
    XCTAssertFalse(tag.isDeleted)
  }
}
