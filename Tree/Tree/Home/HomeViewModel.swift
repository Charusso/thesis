import Foundation
import CoreData
import Combine

extension HomeView {
  class ViewModel: NSObject, ObservableObject,
                   NSFetchedResultsControllerDelegate {
    private let dataController: DataController
    private let timeHandler = TimeHandler()
    
    enum Mode: String, CaseIterable { case Growing, Panicking }
    
    private let extraSeconds = 300
    
    private let tagsController: NSFetchedResultsController<Tag>
    @Published var tags = [Tag]()
    
    @Published var mode = Mode.Growing
    @Published var selectedMinutes: Float = 5
    @Published var selectedTag: Int = 0
    @Published var task: Task!
    
    @Published var showFinishedTaskSheet = false
    @Published var showCancellingSheet = false
    
    let 🌳 = "🌲" /// The displayed tree.
    
    private var cancellables = Set<AnyCancellable>()
    
    init(dataController: DataController) {
      self.dataController = dataController
      
      // Setup the auto-fetching tags.
      let request: NSFetchRequest<Tag> = Tag.fetchRequest()
      request.sortDescriptors =
        [NSSortDescriptor(keyPath: \Tag.order_index_, ascending: true)]
      request.predicate = NSPredicate(format: "is_zombie_ = FALSE")
      
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
      
      // Combine the `timeHandler` changes and emit them from that view-model.
      timeHandler.objectWillChange
        .receive(on: DispatchQueue.main)
        .sink{_ in self.objectWillChange.send()}
        .store(in: &cancellables)
    }
    
    var time: String {
      timeHandler.timerState == .None
        ? timeHandler.secondsToStr(seconds: Int(selectedMinutes) * 60)
        : timeHandler.time
    }
    
    var timeOverflow: String {timeHandler.timeOverflow}
    
    var isTimeOverflowHidden: Bool {!isOverflow}
    
    var timeOverflowColor: String? {
      timeHandler.timerState == .Active(.Overflow) ? "UIForeground" : nil
    }
    
    var treeScale: Float {
      timeHandler.progress > 0
        ? Float(max(0.3, timeHandler.progress)) : 1
    }
    
    var progression: Float {
      if timeHandler.timerState == .None && mode == .Panicking {
        return 1
      }
      
      return timeHandler.timerState != .Active(.Overflow)
        ? timeHandler.progress
        : timeHandler.progressOverflow
    }
    
    func finishTask() {
      let task = Task(context: dataController.container.viewContext)
      task.begin = timeHandler.startTime
      task.end = Date()
      task.seconds = timeHandler.seconds
      task.isDone = timeHandler.seconds >= Int(selectedMinutes * 60)
        && timeHandler.timerState == .Active(.Overflow)
      task.tag_ = selectedTag < tags.count ? tags[selectedTag] : nil
      
      var experience = Int(Double(task.seconds) / 60 * 10)
      if !task.isDone {
        experience /= timeHandler.timerState == .Expired ? 4 : 2
      }
      task.experience = Int(experience)
      
      self.task = task
      
      timeHandler.stop()
      showFinishedTaskSheet = true
      
      dataController.save()
    }
    
    func tryFinishTask() {
      timeHandler.pause()
      showCancellingSheet = true
    }
    
    func continueTask() {timeHandler.run()}
    
    func startButtonAction() {
      switch timeHandler.timerState {
        case .None:
          timeHandler.start(endSeconds: Int(selectedMinutes * 60),
                            extraSeconds: extraSeconds,
                            isIncreasing: mode == .Growing,
                            expireCallback: finishTask)
        case .Pause:
          timeHandler.run()
        case .Active(.Normal):
          timeHandler.pause()
        case .Active(.Overflow), .Expired:
          fatalError("Start button should be disabled when the timer overflow.")
      }
    }
    
    var disableButtons: Bool {timeHandler.isRunning}
    
    private var noneOrPaused: Bool {
      timeHandler.timerState == .None || timeHandler.timerState == .Pause
    }
    
    var startButtonImageName: String {
      noneOrPaused ? "play.rectangle.fill" : "pause.rectangle.fill"
    }
    
    var startButtonAccessibilityID: String {noneOrPaused ? "start" : "pause"}
    
    private var isOverflow: Bool {
      timeHandler.timerState == .Active(.Overflow)
    }
    
    var disableStartButton: Bool {
      isOverflow || timeHandler.timerState == .Expired
    }
    
    func doneButtonAction() {
      if isOverflow {
        finishTask()
      } else {
        tryFinishTask()
      }
    }
    
    var doneButtonAccessibilityID: String {isOverflow ? "confirm" : "stop"}
    
    var doneButtonImageName: String {
      isOverflow ? "checkmark.rectangle.fill" : "xmark.rectangle.fill"
    }
    
    var disableDoneButton: Bool {
      timeHandler.timerState == .None || timeHandler.timerState == .Expired
    }
    
    var doneButtonColorName: String {
      isOverflow ? "UIGreen" : "UIRed"
    }
    
    func controllerDidChangeContent(
      _ controller: NSFetchedResultsController<NSFetchRequestResult>) {
      if let newTags = controller.fetchedObjects as? [Tag] {
        tags = newTags
      }
    }
  }
}
