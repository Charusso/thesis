import SwiftUI

fileprivate extension NumberFormatter {
  static func percentile(_ Value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.minimumIntegerDigits = 1
    formatter.maximumIntegerDigits = 3
    formatter.maximumFractionDigits = 0
    formatter.numberStyle = .percent
    return formatter.string(from: NSNumber(value: Value))!
  }
}

/// Centering the column using the width of the column.
struct CenteringColumnPreference: Equatable {
  let width: CGFloat
}

/// Centering the column based on the updated width preferences of all the row objects.
struct CenteringColumnPreferenceKey: PreferenceKey {
  static var defaultValue: [CenteringColumnPreference] = []
  
  static func reduce(value: inout [CenteringColumnPreference],
                     nextValue: () -> [CenteringColumnPreference]) {
    value.append(contentsOf: nextValue())
  }
}

/// Centering the view based on the centering column widths.
struct CenteringView: View {
  var body: some View {
    GeometryReader { geometry in
      Rectangle()
        .fill(Color.clear)
        .preference(
          key: CenteringColumnPreferenceKey.self,
          value: [CenteringColumnPreference(
                    width: geometry.frame(in: CoordinateSpace.global).width)]
        )
    }
  }
}

struct Pie: Identifiable {
  let id = UUID()
  let value: Double
  let tag: String
  let color: Color
  
  init(value: Double, tag: String, color: Color) {
    self.value = value
    self.tag = tag
    self.color = color
  }
  
  init(value: Double, tag: String, color: String) {
    self.init(value: value, tag: tag, color: Color(color))
  }
}

struct PieSlice: Shape, Identifiable {
  func path(in rect: CGRect) -> Path {
    let radius = min(rect.width, rect.height) / 2
    let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
    
    var path = Path()
    path.move(to: center)
    path.addRelativeArc(center: center, radius: radius,
                        startAngle: Angle(radians: startAngle),
                        delta: Angle(radians: value))
    path.addLine(to: center)
    return path
  }
  
  var animatableData: AnimatablePair<Double, Double> {
    get { AnimatablePair(startAngle, value) }
    set {
      startAngle = newValue.first
      value = newValue.second
    }
  }
  
  let pie: Pie
  var startAngle: Double
  var value: Double
  let id = UUID()
}

struct PieChart: View {
  @Binding var selectedPieIndex: Int
  
  @State private var percentileWidth: CGFloat? = nil
  
  init(pies: [Pie], selectedPieIndex: Binding<Int>, lineWidth: Double) {
    _selectedPieIndex = selectedPieIndex
    self.lineWidth = lineWidth
    
    sum = pies.reduce(0) { $0 + $1.value }
    var startAngle = -Double.pi / 2
    
    var slices = [PieSlice]()
    for pie in pies.sorted(by: \.value, using: >) {
      let value = Double.pi * 2 * (pie.value / sum)
      let slice = PieSlice(pie: pie, startAngle: startAngle, value: value)
      slices.append(slice)
      startAngle += value
    }
    self.slices = slices
  }
  
  func sliceData(slice: PieSlice) -> some View {
    HStack {
      Text("   ")
        .background(slice.pie.color)
      
      Text(NumberFormatter.percentile(slice.pie.value / sum))
        .fixedSize()
        .frame(width: percentileWidth)
        .lineLimit(1)
        .background(CenteringView())
      
      Text(slice.pie.tag)
    }
    .onPreferenceChange(CenteringColumnPreferenceKey.self) { preferences in
      for preference in preferences {
        let oldWidth = percentileWidth ?? CGFloat.zero
        if preference.width > oldWidth {
          percentileWidth = preference.width
        }
      }
    }
  }
  
  var selectedBarLabel: some View {
    Group {
      if !slices.isEmpty {
        sliceData(slice: slices[selectedPieIndex])
      } else {
        Text("No data")
      }
    }
    .padding(EdgeInsets(top: 5, leading: 13, bottom: 5, trailing: 13))
    .background(
      RoundedRectangle(cornerRadius: 13)
        .stroke(Color.K.green, lineWidth: 3)
    )
    .foregroundColor(Color.K.foreground)
    .frame(maxWidth: .infinity, alignment: .center)
    .animation(nil)
  }
  
  var body: some View {
    GeometryReader { gr in
      VStack {
        selectedBarLabel
        
        HStack {
          ZStack {
            if !slices.isEmpty {
              ForEach(Array(slices.enumerated()), id: \.0) { i, slice in
                slice
                  .fill(slice.pie.color)
                  .onTapGesture() {
                    selectedPieIndex = i
                  }
              }
            } else {
              Circle()
                .foregroundColor(.gray)
            }
          }
          .mask(Circle()
                  .strokeBorder(Color.white, lineWidth: CGFloat(lineWidth)))
          .frame(width: gr.size.width * 0.4)
          
          VStack {
            Spacer()
            if !slices.isEmpty {
              withAnimation {
                ScrollView(showsIndicators: false) {
                  LazyVGrid(columns: [GridItem(.fixed(gr.size.width * 0.6))],
                            alignment: .leading) {
                    Spacer()
                    ForEach(slices) { Slice in
                      sliceData(slice: Slice)
                      Spacer()
                    }
                  }
                }
                .fixedSize(horizontal: false, vertical: true)
              }
            } else {
              Color.clear
                .frame(width: gr.size.width * 0.6)
            }
            Spacer()
          }
        }
      }
    }
  }
  
  let lineWidth: Double
  let sum: Double
  let slices: [PieSlice]
}

struct PieChartView: View {
  let pies: [Pie]
  @Binding var selectedPieIndex: Int
  
  var body: some View {
    GeometryReader { gr in
      PieChart(pies: pies,
               selectedPieIndex: $selectedPieIndex,
               lineWidth: Double(gr.size.width) * 0.13)
    }
  }
}

struct PieChart_Previews: PreviewProvider {
  @State static var selectedPieIndex = 0
  
  static var previews: some View {
    PieChartView(pies: pies, selectedPieIndex: $selectedPieIndex)
  }
  
  static var pies: [Pie] {
    [
      Pie(value: Double.random(in: 1...100), tag: "Study", color: .red),
      Pie(value: Double.random(in: 1...100), tag: "Work", color: .yellow),
      Pie(value: Double.random(in: 1...100), tag: "Entertainment",
          color: .green),
      Pie(value: Double.random(in: 1...100), tag: "Read", color: .blue),
      Pie(value: Double.random(in: 1...100), tag: "Draw", color: .purple)
    ]
  }
  
  static func onePie() -> [Pie] {
    [Pie(value: Double.random(in: 10...100), tag: "Study", color: .red)]
  }
}
