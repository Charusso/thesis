import UIKit

/// Using the old AppDelegate API we can show notifications in the foreground.
class AppDelegate: NSObject, UIApplicationDelegate,
                   UNUserNotificationCenterDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions:
                    [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    UNUserNotificationCenter.current().delegate = self
    return true
  }
  
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler:
      @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler([.banner, .sound])
  }
}
