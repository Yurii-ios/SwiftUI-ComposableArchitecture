//
//  RootView.swift
//  Counter_Demo
//
//  Created by Yurii.Sameliuk on 23/09/2022.
//

import SwiftUI
import ComposableArchitecture
import Favoriteprimes
import Counter

struct RootView: View {
   let store: Store<AppState, AppAction>
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: CounterView(store: store.scope(
                    value: { $0.counterView }, action: { localAction in
                        AppAction.counterView(localAction)
                    }))) {
                        Text("Counter Demo")
                            .font(.body)
                            .foregroundColor(.black)
                        
                    }
                NavigationLink(destination: CounterView(store: store.scope(
                    value: { $0.counterView }, action: { localAction in
                        AppAction.offlineCounterView(localAction)
                    }))) {
                        Text("Offline counter demo")
                            .font(.body)
                            .foregroundColor(.black)
                        
                    }
                NavigationLink(destination: FavoriteView(store: store.scope(value: { appState in
                    appState.favoritePrimeState
                }, action: { localAction in
                    AppAction.favoritePrimes(localAction)
                }))) {
                    Text("Favorite primes")
                        .font(.body)
                        .foregroundColor(.black)
                }
            }
            .navigationTitle("Counter Demo")
        }
    }
}

//struct RootView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            RootView(store: Store(initialValue: AppState(), reducer: activityFeed(appReducer), environment: AppEnvironment(counter: .live, favoritePrimes: .live)))
//                .environmentObject(Store(initialValue: AppState(), reducer: activityFeed(appReducer), environment: AppEnvironment(counter: .live, favoritePrimes: .live)))
//        }
//    }
//}
