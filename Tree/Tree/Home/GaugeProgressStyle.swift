import SwiftUI

struct GaugeProgressStyle: ProgressViewStyle {
  var trimAmount = 0.7
  var strokeColor = Color.blue
  var strokeWidth = 25.0
  let formatter = NumberFormatter()
  
  let bgColor: Color
  let fgColor: Color
  
  var rotation: Angle {
    Angle(radians: .pi * (1 - trimAmount)) + Angle(radians: .pi / 2)
  }
  
  func makeBody(configuration: Configuration) -> some View {
    ZStack {
      Circle()
        .rotation(rotation)
        .trim(from: 0, to: CGFloat(trimAmount))
        .stroke(bgColor,
                style: StrokeStyle(lineWidth: CGFloat(strokeWidth),
                                   lineCap: .round))
      
      Circle()
        .rotation(rotation)
        .trim(from: 0,
              to: CGFloat(trimAmount * (configuration.fractionCompleted ?? 0)))
        .stroke(fgColor,
                style: StrokeStyle(lineWidth: CGFloat(strokeWidth),
                                   lineCap: .round))
    }
  }
}

struct GaugeProgressView_Previews: PreviewProvider {
  static var previews: some View {
    ProgressView(value: 0.69)
      .progressViewStyle(GaugeProgressStyle(bgColor: .secondary,
                                            fgColor: .blue))
      .frame(width: 200)
  }
}
