import SwiftUI
import CoreData

@main
struct TreeApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  
  @StateObject var dataController = DataController()
  @AppStorage("isReminderActive") var isReminderActive = false
  
  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(dataController)
        .environment(\.managedObjectContext,
                     dataController.container.viewContext)
        .onAppear(perform: tryNotify)
        
        // When the app is going to resign save the data.
        .onReceive(NotificationCenter.default.publisher(
                    for: UIApplication.willResignActiveNotification),
                   perform: {_ in dataController.save()})
    }
  }
  
  /// Tries to send a notification to switch on the DND mode.
  private func tryNotify() {
    if !isReminderActive {
      return
    }
    
    UNUserNotificationCenter.current().getNotificationSettings { settings in
      if settings.authorizationStatus == .authorized {
        notify()
      }
    }
  }
  
  /// Sends the notification to switch on the DND mode.
  private func notify() {
    let content = UNMutableNotificationContent()
    content.title = "Focus mode"
    content.subtitle = "Do not forget to switch on the DND mode."
    
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1,
                                                    repeats: false)
    
    let request = UNNotificationRequest(identifier: "id",
                                        content: content,
                                        trigger: trigger)
    
    UNUserNotificationCenter.current().add(request)
  }
}
