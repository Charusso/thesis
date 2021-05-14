import Foundation
import CoreData
import Combine

extension StatisticsView {
  class ViewModel: NSObject, ObservableObject,
                   NSFetchedResultsControllerDelegate  {
    var taskHandler: TaskHandler
    var dateHandler = DateHandler()
    
    private let tagsController: NSFetchedResultsController<Tag>
    @Published var tags = [Tag]()
    
    @Published var selectedBarIndex: Int?
    @Published var selectedPieIndex = 0
    
    @Published var interval: DateHandler.IntervalKind
    
    private var cancellables = Set<AnyCancellable>()
    
    init(dataController: DataController) {
      taskHandler = TaskHandler(dataController: dataController,
                                dateHandler: dateHandler)
      
      interval = dateHandler.selectedInterval
      
      // Setup the auto-fetching tags.
      let request: NSFetchRequest<Tag> = Tag.fetchRequest()
      request.sortDescriptors = []
      
      tagsController = NSFetchedResultsController(
        fetchRequest: request,
        managedObjectContext: dataController.container.viewContext,
        sectionNameKeyPath: nil,
        cacheName: nil)
      
      super.init()
      tagsController.delegate = self
      
      do {
        try tagsController.performFetch()
        tags = tagsController.fetchedObjects ?? []
      } catch {
        print("Failed to fetch the tags.")
      }
      
      // Pass the 'interval' to the DateHandler.
      $interval
        .receive(on: DispatchQueue.main)
        .assign(to: &dateHandler.$selectedInterval)
      
      // Listen to 'interval' changes.
      $interval
        .receive(on: DispatchQueue.main)
        .sink{_ in
          self.dateHandler.resetDate()
          self.invalidateIndices()
        }
        .store(in: &cancellables)
    }
    
    func traverseBackwards() {
      dateHandler.traverseBackwards()
      invalidateIndices()
    }
    
    func traverseForwards() {
      dateHandler.traverseForwards()
      invalidateIndices()
    }
    
    func resetDate() {
      dateHandler.resetDate()
      invalidateIndices()
    }
    
    var displayDate: String {dateHandler.displayDate}
    
    var totalMinutes: Int {taskHandler.minutes}
    
    var isLeftButtonDisabled: Bool {taskHandler.tasks.first == nil}
    var isRightButtonDisabled: Bool {
      taskHandler.tasks.first == nil || dateHandler.isNextDateOverflow
    }
    var isResetButtonDisabled: Bool {dateHandler.selectedDayIsToday}
    
    var labelCount: Int {dateHandler.selectedInterval == .Week ? 7 : 5}
    
    var bars: [Bar] {
      if taskHandler.interestingTasks.isEmpty {
        return []
      }
      
      var bars = [Bar]()
      
      dateHandler.enumerateDates { date in
        let minutes = taskHandler.getMinutes(at: date)
        bars.append(Bar(value: Int(minutes),
                        label: dateHandler.getDateLabel(date)))
      }
      
      return bars
    }
    
    var pies: [Pie] {
      let tasks = taskHandler.interestingTasks
      if tasks.isEmpty {
        return []
      }
      
      var pies = [Pie]()
      
      // Count all the tags.
      var tagCounter: [Tag:Int] =
        Dictionary(uniqueKeysWithValues: tags.map{($0, 0)})
      
      for task in tasks {
        if let tag = task.tag_ {
          tagCounter[tag]! += 1
        }
      }
      
      // Sort the tags by importance to create the pie chart.
      for (tag, tagCount)
      in tagCounter.sorted(by: \.key.orderIndex)
      where tagCount > 0 {
        pies.append(Pie(value: Double(tagCount),
                        tag: tag.name,
                        color: tag.color))
      }
      
      let undefinedTagCount = tasks.filter{$0.tag_ == nil}.count
      if undefinedTagCount > 0 {
        pies.append(Pie(value: Double(undefinedTagCount),
                        tag: "Undefined",
                        color: .gray))
      }
      
      return pies
    }
    
    func invalidateIndices() {
      selectedBarIndex = nil
      selectedPieIndex = 0
    }
    
    func controllerDidChangeContent(
      _ controller: NSFetchedResultsController<NSFetchRequestResult>) {
      if let newTags = controller.fetchedObjects as? [Tag] {
        tags = newTags
      }
    }
  }
}
