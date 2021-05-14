import SwiftUI

struct TaskView: View {
  @AppStorage("isTestMode") var isTestMode = true
  
  let task: Task
  
  var body: some View {
    VStack {
      Text(task.isDone ? "Successful task!" : "Not bad task!")
        .font(.title.bold())
        .foregroundColor(task.isDone ? Color.K.green : Color.K.red)
      Text("")
      
      HStack(spacing: 0) {
        Text("You have focused for \(task.isDone ? "" : "about ")")
        Text(task.seconds >= 60
              ? "\(Int(task.seconds / 60)) minutes"
              : "\(Int(task.seconds)) seconds")
          .font(.callout.bold())
        Text(".")
      }
      .font(.callout)
      
      HStack(spacing: 0) {
        Text("Earned ")
        Text("\(task.experience) experience points")
          .font(.callout.bold())
        Text(".")
      }
      .font(.callout)
      Text("")
      
      Text(task.isDone ? "Keep up the great work!" : "Try better next time.")
        .font(.callout.bold())
        .foregroundColor(task.isDone ? Color.K.green : Color.K.red)
    }
  }
}

struct TaskView_Previews: PreviewProvider {
  static var previews: some View {
    TaskView(task: Task.example)
  }
}
