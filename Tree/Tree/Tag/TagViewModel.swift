import Foundation
import CoreData
import SwiftUI

extension TagsView {
  class ViewModel: NSObject, ObservableObject,
                   NSFetchedResultsControllerDelegate {
    let dataController: DataController
    
    private let tagsController: NSFetchedResultsController<Tag>
    @Published var tags = [Tag]()
    
    let newTagName = "New tag"
    
    init(dataController: DataController) {
      self.dataController = dataController
      
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
    }
    
    var isEditButtonDisabled: Bool {tags.isEmpty}
    
    var isAddButtonDisabled: Bool {tags.contains{$0.name == newTagName}}
    
    func add() {
      let tag = Tag(context: dataController.container.viewContext)
      tag.name = newTagName
      tag.color = Tag.colors[0]
      tag.orderIndex = 0
      for i in tags.indices {
        tags[i].orderIndex = i + 1
      }
      
      dataController.save()
    }
    
    func move(from: IndexSet, to: Int) {
      var tags = tags.map{$0}
      tags.move(fromOffsets: from, toOffset: to)
      for i in tags.indices {
        tags[i].orderIndex = i
      }
    }
    
    func delete(offsets: IndexSet) {
      for offset in offsets {
        tags[offset].delete()
      }
      
      dataController.save()
    }
    
    func controllerDidChangeContent(
      _ controller: NSFetchedResultsController<NSFetchRequestResult>) {
      if let newTags = controller.fetchedObjects as? [Tag] {
        tags = newTags
      }
    }
  }
}
