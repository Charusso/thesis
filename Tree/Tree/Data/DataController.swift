import SwiftUI
import CoreData

/// An environment singleton responsible for managing our Core Data stack.
///
/// Including handling saving, counting fetch requests, and dealing with sample data.
class DataController: ObservableObject {
  /// The lone CloudKit container used to store all our data.
  let container: NSPersistentCloudKitContainer
  
  /// Initializes a data controller, either in memory (for temporary use such
  /// as testing and previewing), or on permanent storage (for use in regular
  /// application runs).
  ///
  /// Defaults to permanent storage.
  ///
  /// - Parameter isTest: Whether to store the data for testing purposes, default value is false.
  init(isTest: Bool = false) {
    container = NSPersistentCloudKitContainer(name: "Main",
                                              managedObjectModel: Self.model)
    
    // For testing and previewing the application, we create a temporary,
    // in-memory database by writing to '/dev/null' so our data is destroyed
    // after the application finishes running.
    if isTest {
      container.persistentStoreDescriptions.first?.url =
        URL(fileURLWithPath: "/dev/null")
    }
    
    container.loadPersistentStores { _, error in
      if let error = error {
        fatalError("Fatal error loading store: \(error.localizedDescription)")
      }
      
      #if DEBUG
      // Clean up after each UI test runs and disable every animation.
      if CommandLine.arguments.contains("enable-testing") {
        self.deleteAll()
        UIView.setAnimationsEnabled(false)
      }
      #endif
    }
  }
  
  /// Saves our Core Data context iff there are changes.
  ///
  /// This silently ignores any errors caused by saving, but this should be fine
  /// because our attributes are optional.
  func save() {
    if container.viewContext.hasChanges {
      try? container.viewContext.save()
    }
  }
  
  func delete(_ object: NSManagedObject) {
    container.viewContext.delete(object)
  }
  
  func deleteAll() {
    _ = try? container.viewContext.execute(
      NSBatchDeleteRequest(fetchRequest: Task.fetchRequest()))
    
    _ = try? container.viewContext.execute(
      NSBatchDeleteRequest(fetchRequest: Tag.fetchRequest()))
    
    try! container.viewContext.save()
  }
  
  func count(for request: NSFetchRequest<NSFetchRequestResult>) -> Int {
    try! container.viewContext.count(for: request)
  }
  
  static var preview: DataController = {
    let dataController = DataController(isTest: true)
    let viewContext = dataController.container.viewContext
    
    do {
      try dataController.createTestFramework()
    } catch {
      fatalError("Fatal error creating preview: \(error.localizedDescription)")
    }
    
    return dataController
  }()
  
  /// Returns the underlying data model so that multiple containers could map to it simultaionusly.
  static let model: NSManagedObjectModel = {
    guard let url = Bundle.main.url(forResource: "Main", withExtension: "momd")
    else { fatalError("Failed to locate model file.") }
    
    guard let managedObjectModel = NSManagedObjectModel(contentsOf: url)
    else { fatalError("Failed to load model file.") }
    
    return managedObjectModel
  }()
  
  /// Creates a test framework to make testing easier.
  ///
  /// - Throws: An NSError sent from calling NSManagedObjectContext::save().
  func createTestFramework() throws {
    let viewContext = container.viewContext
    
    let tags = Tag.createDefaultTags(viewContext: viewContext)
    
    var lastDate = Date()
    for _ in 1...365 {
      let task = Task(context: viewContext)
      
      // Interval of [5 - 120] minutes to go backwards in time.
      var interval = TimeInterval(60 * 5 * Int.random(in: 1...24))
      
      // By 50% chance move to the next day.
      if Bool.random() {
        interval += TimeInterval(60 * 60 * 24)
      }
      
      let newDate = Date(timeInterval: -interval, since: lastDate)
      
      task.begin = newDate
      task.end = lastDate
      task.seconds = Int.random(in: 5...120) * 60
      lastDate = newDate
      
      // By 25% chance mark the task as not done.
      task.isDone = Int.random(in: 1...4) != 1
      task.experience = Int.random(in: 13...130)
      task.mode = Int.random(in: 1...2)
      task.tag_ = tags.randomElement()!
    }
    
    try viewContext.save()
  }
}
