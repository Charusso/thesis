import Foundation

extension Task {
  var begin: Date {
    get { begin_ ?? Date.unknownDate }
    set { begin_ = newValue }
  }
  
  var end: Date {
    get { end_ ?? Date.unknownDate }
    set { end_ = newValue }
  }
  
  var experience: Int {
    get { Int(experience_) }
    set { experience_ = Int16(newValue) }
  }
  
  var mode: Int {
    get { Int(mode_) }
    set { mode_ = Int16(newValue) }
  }
  
  var seconds: Int {
    get { Int(seconds_) }
    set { seconds_ = Int16(newValue) }
  }
  
  var isDone: Bool {
    get { is_done_ }
    set { is_done_ = newValue }
  }
  
  static var example: Task {
    let task = Task()
    
    // Interval of [5 - 120] minutes to go backwards in time.
    let interval = TimeInterval(60 * 5 * Int.random(in: 1...24))
    let endDate = Date()
    let beginDate = Date(timeInterval: -interval, since: endDate)
    
    task.begin = beginDate
    task.end = endDate
    task.seconds = 130
    
    task.experience = 13
    task.mode = Int.random(in: 0...1)
    task.isDone = true
    
    task.tag_ = Tag.example
    
    return task
  }
}
