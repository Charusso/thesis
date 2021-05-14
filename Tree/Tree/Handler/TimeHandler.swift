import Foundation
#if DEBUG
import SwiftUI
#endif

class TimeHandler: ObservableObject {
  @Published var timerState = TimerState.None
  @Published var seconds = 0
  @Published var overflowSeconds = 0
  @Published var startTime = Date()
  
  #if DEBUG
  @AppStorage("isTestMode") private var isTestMode = false
  #endif
  
  enum TimerActiveState { case Normal, Overflow }
  enum TimerState: Equatable {
    case None, Active(TimerActiveState), Pause, Expired
  }
  
  private var endSeconds = 0
  private var extraSeconds = 0
  private var isIncreasing = true
  private var expireCallback = {}
  
  private var timer = Timer()
  
  func start(endSeconds: Int, extraSeconds: Int, isIncreasing: Bool,
             expireCallback: @escaping () -> Void) {
    timer.invalidate()
    
    self.endSeconds = endSeconds
    self.extraSeconds = extraSeconds
    self.isIncreasing = isIncreasing
    self.expireCallback = expireCallback
    
    startTime = Date()
    run()
  }
  
  func pause() {
    timer.invalidate()
    tryStateUpdate(.Pause)
  }
  
  func run() {
    tryStateUpdate(.Active(.Normal))
    
    timer =
      Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [self]_ in
        switch timerState {
          case .Pause:
            return
            
          case .Active(.Normal):
            seconds += 1
            #if DEBUG
            if isTestMode {
              seconds += 59
            }
            #endif
            if seconds >= endSeconds {
              tryStateUpdate(.Active(.Overflow))
            }
            
          case .Active(.Overflow):
            overflowSeconds += 1
            #if DEBUG
            if isTestMode {
              overflowSeconds += 59
            }
            #endif
            if overflowSeconds > extraSeconds {
              expired()
            }
            
          case .None, .Expired:
            fatalError("No TimerStateKind specified to run the timer")
        }
      }
  }
  
  func expired() {
    timer.invalidate()
    tryStateUpdate(.Expired)
    expireCallback()
  }
  
  func stop() {
    timer.invalidate()
    
    tryStateUpdate(.None)
    seconds = 0
    overflowSeconds = 0
  }
  
  var progress: Float {
    if timerState == .None {
      return 0
    }
    
    let progress = Float(seconds) / Float(endSeconds)
    return isIncreasing ? progress : 1 - progress
  }
  
  var isRunning: Bool {
    timerState != .None
  }
  
  var progressOverflow: Float {
    timerState != .Active(.Overflow)
      ? 0 : 1 - Float(overflowSeconds) / Float(extraSeconds)
  }
  
  var time: String {
    secondsToStr(seconds: isIncreasing ? seconds : endSeconds - seconds)
  }
  
  var timeOverflow: String {
    secondsToStr(seconds: extraSeconds - overflowSeconds)
  }
  
  func secondsToStr(seconds: Int) -> String {
    let hour = "\(seconds / 3600)"
    let minute = "\((seconds % 3600) / 60)"
    let second = "\((seconds % 3600) % 60)"
    
    var hourStr = ""
    if seconds / 3600 > 0 {
      hourStr = (hour.count > 1 ? hour : "0" + hour) + ":"
    }
    
    let minuteStr = (minute.count > 1 ? minute : "0" + minute) + ":"
    let secondStr = second.count > 1 ? second : "0" + second
    return hourStr + minuteStr + secondStr
  }
  
  private func tryStateUpdate(_ kind: TimerState) {
    if kind != timerState {
      timerState = kind
    }
  }
}
