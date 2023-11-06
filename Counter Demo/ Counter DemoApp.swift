import SwiftUI
import ComposableArchitecture

@main
struct Counter_DemoApp: App {
    var body: some Scene {
        WindowGroup {
            RootView(store: .init(initialValue: AppState(), reducer: logging(activityFeed(appReducer))))
        }
    }
}
