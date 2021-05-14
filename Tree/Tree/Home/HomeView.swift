import SwiftUI

/// This defines the home view which is the main screen where the user could start a new focus session.
struct HomeView: View {
  @StateObject var viewModel: ViewModel
  
  init(dataController: DataController) {
    _viewModel =
      StateObject(wrappedValue: ViewModel(dataController: dataController))
  }
  
  /// This is the overall progress of the user measured with experience points after each task.
  var levelProgressBar: some View {
    LevelProgressBar()
      .frame(height: 30)
      .animation(nil)
  }
  
  /// This is the mode picker where the users could specify how they want to focus.
  var modePicker: some View {
    Picker("Mode", selection: $viewModel.mode) {
      ForEach(ViewModel.Mode.allCases, id: \.self) { kind in
        Text(kind.rawValue).tag(kind)
      }
    }
    .pickerStyle(SegmentedPickerStyle())
    .padding(.horizontal)
    .accessibility(identifier: "mode picker")
    .disabled(viewModel.disableButtons)
  }
  
  /// This is the tag picker to let the users use their own tags or the special undefined tag.
  var tagPicker: some View {
    Picker("Tag", selection: $viewModel.selectedTag) {
      ForEach(Array(viewModel.tags.enumerated()), id: \.0) { index, tag in
        Text(tag.name).tag(index)
      }
      Text("Undefined").tag(viewModel.tags.count)
    }
    .pickerStyle(WheelPickerStyle())
    .frame(height: 75)
    .clipped()
    .accessibility(identifier: "tag picker")
    .disabled(viewModel.disableButtons)
  }
  
  /// This is the tree with the time progress around it.
  var treeProgress: some View {
    GeometryReader { gr in
      ZStack {
        ProgressView(value: viewModel.progression)
          .progressViewStyle(GaugeProgressStyle(bgColor: Color.K.brown,
                                                fgColor: Color.K.green))
          .frame(width: gr.size.width * 0.75)
          .accessibility(identifier: "tree progress")
        
        Text(viewModel.🌳)
          .font(.system(size: gr.size.width * 0.5))
          .scaleEffect(x: CGFloat(viewModel.treeScale),
                       y: CGFloat(viewModel.treeScale),
                       anchor: .bottom)
      }
      .padding()
      .animation(.spring())
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
  }
  
  /// These are the normal and the overflow timers.
  var timers: some View {
    VStack {
      Text(viewModel.time)
        .font(.title)
        .foregroundColor(Color.K.foreground)
        .accessibility(identifier: "normal timer")
      
      Text(viewModel.timeOverflow)
        .font(.title)
        .foregroundColor(
          viewModel.timeOverflowColor.map{Color($0)} ?? .clear)
        .accessibility(identifier: "overflow timer")
        .accessibilityHidden(viewModel.isTimeOverflowHidden)
    }
  }
  
  /// This is the start and pause button.
  var startButton: some View {
    Button(action: viewModel.startButtonAction) {
      Image(systemName: viewModel.startButtonImageName)
    }
    .disabled(viewModel.disableStartButton)
    .accentColor(Color.K.green)
    .font(.system(size: 42))
    .accessibility(identifier: viewModel.startButtonAccessibilityID)
  }
  
  /// This is the done and stop button.
  var doneButton: some View {
    Button(action: viewModel.doneButtonAction) {
      Image(systemName: viewModel.doneButtonImageName)
    }
    .accentColor(Color(viewModel.doneButtonColorName))
    .font(.system(size: 42))
    .disabled(viewModel.disableDoneButton)
    .accessibility(identifier: viewModel.doneButtonAccessibilityID)
  }
  
  /// This is the slider to specify the `selectedMinutes`.
  var timeSlider: some View {
    HStack {
      Text("Doing")
      Slider(value: $viewModel.selectedMinutes, in: 5...80, step: 5,
             thumbColor: UIColor(Color.K.green),
             minTrackColor: UIColor(Color.K.green),
             maxTrackColor: UIColor(Color.K.brown))
        .padding(.horizontal)
        .accessibility(identifier: "doing time")
    }
    .font(.title3)
    .padding()
    .disabled(viewModel.disableButtons)
  }
  
  /// It glues everything together.
  var body: some View {
    VStack {
      levelProgressBar
      modePicker
      tagPicker
      Spacer()
      
      treeProgress
      timers
      Spacer()
      
      HStack {
        startButton
        doneButton
      }
      
      timeSlider
    }
    .sheet(isPresented: $viewModel.showFinishedTaskSheet, content: {
      TaskView(task: viewModel.task)
    })
    .alert(isPresented: $viewModel.showCancellingSheet, content: {
      Alert(title: Text("Session stop"),
            message: Text("Do you want to stop?"),
            primaryButton: .destructive(Text("Yes")) {viewModel.finishTask()},
            secondaryButton: .cancel() {viewModel.continueTask()})
    })
    .background(Color.K.background)
  }
  
  /// Tag for the TabView.
  static let tag: String? = "HomeView"
}

struct HomeView_Previews: PreviewProvider {
  static var previews: some View {
    HomeView(dataController: DataController.preview)
  }
}
