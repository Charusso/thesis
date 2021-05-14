import SwiftUI

fileprivate extension Int {
  static func /(lhs: Int, rhs: Int) -> Int { Int(Double(lhs) / Double(rhs)) }
}

struct Bar: Identifiable {
  let value: Int
  let label: String
  var id: String { label }
}

struct BarChart: View {
  @Binding var selectedBarIndex: Int?
  
  init(bars: [Bar], selectedBarIndex: Binding<Int?>,
       valueCount: Int, labelCount: Int) {
    self.valueCount = valueCount
    self.labelCount = labelCount
    _selectedBarIndex = selectedBarIndex
    let mayMaxValue = bars.max{$0.value < $1.value}?.value
    maxValue = mayMaxValue ?? 4
    self.bars = mayMaxValue != nil ? bars : []
  }
  
  var selectedBarLabel: some View {
    let isColored = selectedBarIndex != nil || bars.isEmpty
    return Group {
      if !bars.isEmpty {
        Text(selectedBarIndex == nil || (selectedBarIndex! - 1) >= bars.count
              ? "|"
              : "\(bars[selectedBarIndex!].label):"
              + " \(bars[selectedBarIndex!].value)")
      } else {
        Text("No data")
      }
    }
    .padding(EdgeInsets(top: 5, leading: 13, bottom: 5, trailing: 13))
    .background(
      RoundedRectangle(cornerRadius: 13)
        .stroke(isColored ? Color.K.green : .clear, lineWidth: 3)
    )
    .foregroundColor(isColored ? Color.K.foreground : .clear)
    .animation(nil)
  }
  
  var values: some View {
    VStack {
      VStack {
        ForEach((1...valueCount - 1).reversed(), id: \.self) { i in
          let value = Int(Double(maxValue) / Double(valueCount - 1) * Double(i))
          Divider()
            .opacity(0)
            .overlay(Text(String(value))
                      .fixedSize()
                      .foregroundColor(value > 0 ? Color.K.foreground : .clear))
          Spacer()
        }
        Divider()
          .opacity(0)
          .overlay(Text("0 M")
                    .fixedSize()
                    .foregroundColor(Color.K.foreground))
        
        // Fill the space on the bottom-left corner based on 'maxValue'.
        Text(String(repeating: "9", count: max(3, String(maxValue).count)))
          .foregroundColor(.clear)
      }.fixedSize(horizontal: true, vertical: false)
    }
  }
  
  var backgroundLines: some View {
    VStack {
      ForEach(1...valueCount - 1, id: \.self) { _ in
        Divider()
          .background(Color.K.foreground)
        Spacer()
      }
      Divider()
        .background(Color.K.foreground)
      
      Text("|")
        .foregroundColor(.clear)
    }
  }
  
  func barView(_ bar: Bar, index: Int, barsAreaWidth: CGFloat) -> some View {
    let isSelected = selectedBarIndex != nil && selectedBarIndex! == index
    return RoundedRectangle(cornerRadius: 3, style: .continuous)
      .fill(Color.K.green)
      .scaleEffect(x: 0.8,
                   y: max(0, CGFloat(Double(bar.value) / Double(maxValue))),
                   anchor: .bottom)
      .frame(width: CGFloat(barsAreaWidth / CGFloat(bars.count)))
      .overlay(isSelected
                ? Color.K.red.opacity(0.33)
                : Color.white.opacity(0.001))
  }
  
  func label(_ bar: Bar, index: Int) -> some View {
    let isLabeled = labelCount != 5
      || (index == 0 || index == bars.count - 1
            || index == Int(Double(bars.count - 1) * 0.25)
            || index == Int(Double(bars.count - 1) * 0.5)
            || index == Int(Double(bars.count - 1) * 0.75))
    return Text(isLabeled ? bar.label : "|")
      .fixedSize()
      .foregroundColor(isLabeled ? Color.K.foreground : Color.clear)
      .frame(width: 1)
  }
  
  var body: some View {
    VStack {
      selectedBarLabel
        .padding(.bottom, 5)
      
      HStack {
        values
        Spacer(minLength: 3)
        ZStack {
          backgroundLines
          GeometryReader { barsAreaGR in
            HStack(spacing: 0) {
              ForEach(Array(bars.enumerated()), id: \.0) { i, bar in
                VStack {
                  barView(bar, index: i, barsAreaWidth: barsAreaGR.size.width)
                  label(bar, index: i)
                }
              }
            }
            .gesture(drag(barsArea: barsAreaGR.frame(in: .global)))
          }
        }
      }
    }
  }
  
  func drag(barsArea: CGRect) -> some Gesture {
    DragGesture(minimumDistance: 0, coordinateSpace: .global)
      .onChanged { Value in
        withAnimation(.easeInOut(duration: 0.05)) {
          let dragPoint = Value.location
          let barWidth = CGFloat(Double(barsArea.width) / Double(bars.count))
          
          var I = Int((dragPoint.x - barsArea.minX) / barWidth)
          I = min(max(I, 0), bars.count - 1) // Clamp.
          
          if selectedBarIndex == nil || selectedBarIndex! != I {
            selectedBarIndex = I
          }
        }
      }
  }
  
  let bars: [Bar]
  let maxValue: Int /// The largest possible value in the chart.
  let valueCount: Int /// Count of visible vertical axis values.
  let labelCount: Int /// Count of horizontal axis labels.
}

struct BarChartView: View {
  var bars: [Bar]
  var labelCount: Int
  @Binding var selectedBarIndex: Int?
  
  var body: some View {
    GeometryReader { gr in
      BarChart(bars: bars, selectedBarIndex: $selectedBarIndex,
               valueCount: 5, labelCount: labelCount)
        .frame(height: gr.size.height > gr.size.width
                ? gr.size.width : gr.size.height)
        .padding(.horizontal)
    }
  }
}

struct BarChartView_Previews: PreviewProvider {
  @State static var selectedBarIndex: Int?
  
  static var previews: some View {
    BarChartView(bars: [],
                 labelCount: 7,
                 selectedBarIndex: $selectedBarIndex)
  }
  
  static func getWeeklyValues() -> [Bar] {
    [
      Bar(value: 2, label: "Mon"),
      Bar(value: 4, label: "Tue"),
      Bar(value: 13, label: "Wed"),
      Bar(value: 0, label: "Thu"),
      Bar(value: 2, label: "Fri"),
      Bar(value: 12, label: "Sat"),
      Bar(value: 1, label: "Sun")
    ]
  }
  
  static func getMonthlyValues() -> [Bar] {
    getRandomValues(valueBound: 2_000, countBound: 31)
  }
  
  static func getYearlyValues() -> [Bar] {
    getRandomValues(valueBound: 20_000, countBound: 12)
  }
  
  static func getRandomValues(valueBound: Int, countBound: Int) -> [Bar] {
    var bars = [Bar]()
    let range = (1...countBound)
    var randomInts = range.map{_ in Int.random(in: 0...valueBound)}
    randomInts[0] = valueBound
    randomInts[1] = 0
    randomInts[countBound - 1] = valueBound
    
    for i in range {
      bars.append(Bar(value: randomInts[i - 1], label: String(i)))
    }
    return bars
  }
}
