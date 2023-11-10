import SwiftUI
import ComposableArchitecture
import Counter

@main
struct Counter_DemoApp: App {
    var body: some Scene {
        WindowGroup {
             RootView(store: .init(initialValue: AppState(), reducer: logging(activityFeed(appReducer), logger:  { environment in
                return { message in
                    print("environment: \(environment),\n message: \(message) ")
                }
                
             }), environment: AppEnvironment(fileClient: .userDefaults, nthPrime: Counter.nthPrime, offlineNthPrime: Counter.offlineNthPrime)))
        }
    }
}
