import SwiftUI

/// One minute of work worth 10 experience points. People could not focus for more than 4 hours, so
/// we cap each level worth 4 hours of work, meaning 2400 experience points. With that we have a linear
/// progression system, so we do not create a pressure on the user by more and more difficult growth.
struct LevelProgressBar: View {
  @FetchRequest(entity: Task.entity(), sortDescriptors: [])
  var tasks: FetchedResults<Task>
  
  @AppStorage("selectedColor") var selectedColor = "Dark Blue"

  let experiencePerMinute = 10
  let experiencePerLevel = 2400
  
  var experience: Int { tasks.map{$0.experience}.reduce(0, +) }
  
  var level: Int { experience / experiencePerLevel + 1 }
  
  var nextLevelExperience: Int {
    experiencePerLevel * (level - 1) + experiencePerLevel
  }
  
  var progress: CGFloat {
    CGFloat(experience % experiencePerLevel) / CGFloat(experiencePerLevel)
  }
  
  var body: some View {
    GeometryReader { GR in
      ZStack {
        Rectangle()
          .foregroundColor(Color(selectedColor).opacity(0.4))
        
        Rectangle()
          .scaleEffect(x: progress, y: 1, anchor: .leading)
          .foregroundColor(Color(selectedColor))
          .animation(.linear(duration: 2))
        
        Text(" Level \(level) ")
          .fixedSize()
          .background(Capsule().scale(1.1).foregroundColor(Color.K.background))
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.leading, 13)
          .font(.headline)
          .foregroundColor(Color.K.foreground)
        
        Text("\(experience) / \(nextLevelExperience)")
          .fixedSize()
          .background(Capsule().scale(1.1).foregroundColor(Color.K.background))
          .font(.headline)
          .foregroundColor(Color.K.foreground)
      }
    }
  }
}

struct IProgressBar_Previews: PreviewProvider {
  static var previews: some View {
    LevelProgressBar()
      .frame(height: 30)
  }
}
