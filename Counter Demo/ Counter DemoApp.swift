//
//  Counter_DemoApp.swift
//
//  Created by Yurii.Sameliuk on 23/09/2022.
//

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
