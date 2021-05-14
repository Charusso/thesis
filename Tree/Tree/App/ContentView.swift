import SwiftUI

struct ContentView: View {
  @EnvironmentObject var dataController: DataController
  @State var selectedTab: String?
  
  var body: some View {
    TabView(selection: $selectedTab) {
      HomeView(dataController: dataController).tabItem {
        tabImage(systemName: "house", kind: HomeView.tag)
        Text("Home")
      }.tag(HomeView.tag)
      
      StatisticsView(dataController: dataController).tabItem {
        tabImage(systemName: "chart.bar", kind: StatisticsView.tag)
        Text("Statistics")
      }.tag(StatisticsView.tag)
      
      TagsView(dataController: dataController).tabItem {
        tabImage(systemName: "tag", kind: TagsView.tag)
        Text("Tags")
      }.tag(TagsView.tag)
      
      SettingsView().tabItem {
        tabImage(systemName: "gearshape", kind: SettingsView.tag)
        Text("Settings")
      }.tag(SettingsView.tag)
    }
    .accentColor(Color.K.lightGreen)
  }
  
  /// Set the selected tab image to be the filled version of the SF Symbol.
  /// - Parameters:
  ///   - systemName: The system name of the SF Symbol.
  ///   - kind: The kind of the current tab to match with the selected tab.
  /// - Returns: The appropriate Image based on whether the tab is selected.
  func tabImage(systemName: String, kind: String?) -> some View {
    Image(systemName: (selectedTab == kind
                        || (selectedTab == nil && kind == HomeView.tag))
            ? systemName + ".fill" : systemName)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView().environmentObject(DataController.preview)
  }
}
