import SwiftUI

@main
struct AppDevConTCAApp: App {
    var body: some Scene {
        WindowGroup {
          ContentView(model: .init(factFetcher: .live))
        }
    }
}
