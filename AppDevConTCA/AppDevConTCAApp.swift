import SwiftUI
import ComposableArchitecture

@main
struct AppDevConTCAApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView(store: StoreOf<FactDomain>(
        initialState: .init(
          textFieldState: .init(title: "Please enter a number"),
          pickerState: .init()
        ),
        reducer: FactDomain()
      ))
    }
  }
}
