import CoreData
import Foundation
import SwiftUI

extension Tag {
  static let colors = ["Pink", "Purple", "Red", "Orange", "Gold", "Green",
                       "Teal", "Light Blue", "Dark Blue", "Midnight",
                       "Dark Gray", "Gray"]
  
  var color: String {
    get { color_ ?? "Gray" }
    set { color_ = newValue }
  }
  
  var name: String {
    get { name_ ?? "Undefined" }
    set { name_ = newValue }
  }
  
  var orderIndex: Int {
    get { Int(order_index_) }
    set { order_index_ = Int16(newValue) }
  }
  
  var isZombie: Bool {
    get { is_zombie_ }
    set { is_zombie_ = newValue }
  }
  
  func delete() { isZombie = true }
  
  static func createDefaultTags(viewContext: NSManagedObjectContext) -> [Tag] {
    let studyTag = Tag(context: viewContext)
    studyTag.name = "Study"
    studyTag.color = "Green"
    studyTag.orderIndex = 1
    
    let workTag = Tag(context: viewContext)
    workTag.name = "Work"
    workTag.color = "Red"
    workTag.orderIndex = 2
    
    let sportTag = Tag(context: viewContext)
    sportTag.name = "Sport"
    sportTag.color = "Gold"
    sportTag.orderIndex = 3
    
    let entertainmentTag = Tag(context: viewContext)
    entertainmentTag.name = "Entertainment"
    entertainmentTag.color = "Light Blue"
    entertainmentTag.orderIndex = 4
    
    return [studyTag, workTag, sportTag, entertainmentTag]
  }
  
  static var undefined: Tag {
    let tag = Tag(context: DataController.preview.container.viewContext)
    tag.name = "Undefined"
    tag.color = "Gray"
    tag.orderIndex = Int(Int16.max)
    return tag
  }
  
  static var example: Tag {
    let tag = Tag(context: DataController.preview.container.viewContext)
    tag.name = "Example tag"
    tag.color = "Purple"
    tag.orderIndex = 1
    return tag
  }
}
