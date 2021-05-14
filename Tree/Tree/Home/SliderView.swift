import SwiftUI

/// A UISlider which let the user to tap in arbitrary points to make faster decisions.
class TapSlider: UISlider {
  var step: Float = 1
  
  override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
    let touchLoc = touch.location(in: self)
    let offset = Float(touchLoc.x / bounds.width)
    var newValue = (maximumValue - minimumValue) * offset + minimumValue
    newValue = round(newValue / step) * step
    
    if newValue != value {
      value = newValue
      sendActions(for: .valueChanged)
    }
    
    return true
  }
  
  override func trackRect(forBounds bounds: CGRect) -> CGRect {
    var rect = super.trackRect(forBounds: bounds)
    rect.size.height = 10
    return rect
  }
}

/// The wrapper view for the TapSlider UISlider so that we can use it in SwiftUI.
struct Slider: UIViewRepresentable {
  @Binding var value: Float
  let `in`: ClosedRange<Float>
  let step: Float
  
  func makeUIView(context: Context) -> TapSlider {
    let slider = TapSlider(frame: .zero)
    slider.thumbTintColor = thumbColor
    slider.minimumTrackTintColor = minTrackColor
    slider.maximumTrackTintColor = maxTrackColor
    slider.value = Float(value)
    slider.minimumValue = `in`.lowerBound
    slider.maximumValue = `in`.upperBound
    slider.step = step
    
    slider.addTarget(
      context.coordinator,
      action: #selector(Coordinator.valueChanged(_:)),
      for: .valueChanged
    )
    
    return slider
  }
  
  func updateUIView(_ slider: TapSlider, context: Context) {
    slider.value = value
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  class Coordinator: NSObject {
    var parent: Slider
    
    init(_ parent: Slider) {
      self.parent = parent
    }
    
    @objc func valueChanged(_ sender: TapSlider) {
      let newValue = round(sender.value / sender.step) * sender.step
      let currentValue = round(parent.value / sender.step) * sender.step
      if newValue != currentValue {
        parent.value = newValue
        sender.setValue(newValue, animated: false)
      } else {
        sender.setValue(currentValue, animated: false)
      }
    }
  }
  
  var thumbColor: UIColor?
  var minTrackColor: UIColor?
  var maxTrackColor: UIColor?
}

struct ISlider_Previews: PreviewProvider {
  static var previews: some View {
    Slider(value: .constant(0),
           in: 0...30,
           step: 10,
           thumbColor: .white,
           minTrackColor: .blue,
           maxTrackColor: .gray)
  }
}
