import SwiftUI

struct StatisticsView: View {
  @StateObject var viewModel: ViewModel
  
  init(dataController: DataController) {
    _viewModel =
      StateObject(wrappedValue: ViewModel(dataController: dataController))
  }
  
  var body: some View {
    VStack {
      dateIntervalPickMenu
      Divider().background(Color.K.foreground)
      
      taskBarChart
      Divider().background(Color.K.foreground)
      
      tagDistributionDonutChart
    }
    .background(Color.K.background)
  }
  
  var leftButton: some View {
    Button(action: viewModel.traverseBackwards, label: {
      Image(systemName: "chevron.left")
        .font(.title3.bold())
    })
    .accessibility(identifier: "backwards")
    .disabled(viewModel.isLeftButtonDisabled)
  }
  
  var resetButton: some View {
    Button(action: viewModel.resetDate, label: {
      Image(systemName: "arrow.counterclockwise")
    })
    .accessibility(identifier: "reset")
    .disabled(viewModel.isResetButtonDisabled)
  }
  
  var rightButton: some View {
    Button(action: viewModel.traverseForwards, label: {
      Image(systemName: "chevron.right")
        .font(.title3.bold())
    })
    .accessibility(identifier: "forwards")
    .disabled(viewModel.isRightButtonDisabled)
  }
  
  var dateIntervalPickMenu: some View {
    VStack {
      Picker(selection: $viewModel.interval, label: Text("Mode")) {
        ForEach(DateHandler.IntervalKind.allCases, id: \.self) { kind in
          Text(kind.rawValue).tag(kind)
        }
      }
      .pickerStyle(SegmentedPickerStyle())
      .padding(.horizontal)
      
      HStack {
        leftButton
          .padding(.leading, 25)
        
        HStack {
          Text(viewModel.displayDate)
          resetButton
        }
        .frame(maxWidth: .infinity)
        
        rightButton
          .padding(.trailing, 25)
      }
    }
  }
  
  var taskBarChart: some View {
    VStack {
      VStack {
        Text("Focused time")
          .font(.title2)
          .frame(maxWidth: .infinity, alignment: .leading)
        
        HStack(spacing: 5) {
          Text("Total: ")
            .font(.headline)
          Text(String(viewModel.totalMinutes) + " minutes")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
      }
      .padding(.leading)
      
      BarChartView(bars: viewModel.bars,
                   labelCount: viewModel.labelCount,
                   selectedBarIndex: $viewModel.selectedBarIndex)
        .padding(.bottom, 5)
        .animation(nil)
    }
  }
  
  var tagDistributionDonutChart: some View {
    VStack {
      Text("Tag distribution")
        .font(.title2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading)
      
      PieChartView(pies: viewModel.pies,
                   selectedPieIndex: $viewModel.selectedPieIndex)
        .padding(.horizontal)
        .animation(nil)
    }
  }
  
  static let tag: String? = "StatisticsView"
}

struct StatisticsView_Previews: PreviewProvider {
  static var previews: some View {
    StatisticsView(dataController: DataController.preview)
  }
}
