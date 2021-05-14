import Foundation
import CoreData

class TaskHandler: NSObject, ObservableObject,
                   NSFetchedResultsControllerDelegate {
  let dataController: DataController
  let dateHandler: DateHandler
  
  private let tasksController: NSFetchedResultsController<Task>
  @Published var tasks = [Task]()
  
  init(dataController: DataController, dateHandler: DateHandler) {
    self.dataController = dataController
    self.dateHandler = dateHandler
    
    // Setup the auto-fetching tasks.
    let request: NSFetchRequest<Task> = Task.fetchRequest()
    request.sortDescriptors =
      [NSSortDescriptor(keyPath: \Task.begin_, ascending: true)]
    request.predicate = NSPredicate(format: "is_done_ = TRUE")
    
    tasksController = NSFetchedResultsController(
      fetchRequest: request,
      managedObjectContext: dataController.container.viewContext,
      sectionNameKeyPath: nil,
      cacheName: nil)
    
    super.init()
    tasksController.delegate = self
    
    do {
      try tasksController.performFetch()
      tasks = tasksController.fetchedObjects ?? []
    } catch {
      print("Failed to fetch the tasks.")
    }
  }
  
  var interestingTasks: [Task] {
    tasks.filter{dateHandler.selectedDateInterval.contains($0.begin)}
  }
  
  func getMinutes(at date: Date) -> Int {
    tasks
      .filter{dateHandler.matchingDates($0.begin, date)}
      .map{$0.seconds}
      .reduce(0, +) / 60
  }
  
  var minutes: Int {
    interestingTasks
      .map{$0.seconds}
      .reduce(0, +) / 60
  }
  
  func controllerDidChangeContent(
    _ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    if let newTasks = controller.fetchedObjects as? [Task] {
      tasks = newTasks
    }
  }
}
