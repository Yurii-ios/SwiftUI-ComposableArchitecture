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
    @ObservedObject var store: Store<AppState, AppAction>
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: CounterView(store: store.view(
                    value: { $0.counterView }, action: { localAction in
                        AppAction.counterView(localAction)
                    }))) {
                        Text("Counter Demo")
                            .font(.body)
                            .foregroundColor(.black)
                        
                    }
                NavigationLink(destination: FavoriteView(store: store.view(value: { appState in
                    appState.favoritePrimes
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

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RootView(store: Store(initialValue: AppState(), reducer: activityFeed(appReducer)))
                .environmentObject(Store(initialValue: AppState(), reducer: activityFeed(appReducer)))
        }
    }
}
