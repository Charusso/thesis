import SwiftUI

struct SettingsView: View {
  @EnvironmentObject var dataController: DataController
  @AppStorage("selectedColor") var selectedColor = "Dark Blue"
  @AppStorage("isReminderActive") var isReminderActive = false
  @AppStorage("isTestMode") var isTestMode = false
  
  @State private var showingNotificationError = false
  
  var body: some View {
    NavigationView {
      Form {
        Section(header: Text("Experience bar color")) {
          LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))]) {
            ForEach(Tag.colors, id: \.self) { item in
              ZStack {
                Color(item)
                  .aspectRatio(1, contentMode: .fit)
                  .cornerRadius(6)
                
                if item == selectedColor {
                  Image(systemName: "checkmark.circle")
                    .foregroundColor(.white)
                    .font(.largeTitle)
                }
              }
              .onTapGesture {
                selectedColor = item
              }
            }
          }
          .padding(.vertical)
        }
        
        Section(header: Text("Reminders"),
                footer: Text("Sends me a notification to switch on the "
                              + "Do Not Disturb mode when the app launch")) {
          Toggle("DND mode reminder",
                 isOn: $isReminderActive.animation().onChange(notify))
            .alert(isPresented: $showingNotificationError) {
              Alert(title: Text("Oops!"),
                    message: Text("There was a problem. Please check you have"
                                    + " notifications enabled."),
                    primaryButton: .default(Text("Check settings"),
                                            action: showAppSettings),
                    secondaryButton: .cancel())
            }
            .toggleStyle(SwitchToggleStyle(tint: Color.K.lightGreen))
            .accessibility(identifier: "DND mode")
        }
        
        Section(header: Text("Testing"),
                footer: Text("In test mode the timer is 60x faster.")) {
          Toggle(isOn: $isTestMode) {
            Text("Test mode")
          }
          .toggleStyle(SwitchToggleStyle(tint: Color.K.lightGreen))
          .accessibility(identifier: "test mode")
        }
      }
      .navigationTitle("Settings")
    }
  }
  
  func notify() {
    if isReminderActive {
      tryRequestNotifications { isSuccess in
        if !isSuccess {
          isReminderActive = false
          showingNotificationError = true
        }
      }
    } else {
      removeReminder()
    }
  }
  
  func tryRequestNotifications(completion: @escaping (Bool) -> Void) {
    UNUserNotificationCenter.current().getNotificationSettings { settings in
      switch settings.authorizationStatus {
        case .notDetermined:
          requestNotifications { isSuccess in
            DispatchQueue.main.async{completion(isSuccess)}
          }
        case .authorized:
          DispatchQueue.main.async{completion(true)}
        default:
          DispatchQueue.main.async{completion(false)}
      }
    }
  }
  
  private func requestNotifications(completion: @escaping (Bool) -> Void) {
    let center = UNUserNotificationCenter.current()
    
    center.requestAuthorization(options: [.alert, .sound]) { isGranted, _ in
      completion(isGranted)
    }
  }
  
  func removeReminder() {
    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
  }
  
  func showAppSettings() {
    guard let settingsURL = URL(string: UIApplication.openSettingsURLString)
    else { return }
    
    if UIApplication.shared.canOpenURL(settingsURL) {
      UIApplication.shared.open(settingsURL)
    }
  }
  
  static let tag: String? = "SettingsView"
}

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsView()
      .accentColor(Color.K.lightGreen)
  }
}
