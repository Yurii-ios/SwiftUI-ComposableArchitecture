//
//  PrimeSheetView.swift
//  Counter Demo
//
//  Created by Yurii.Sameliuk on 23/09/2022.
//

import SwiftUI
import ComposableArchitecture
import PrimeModel

struct PrimeSheetView: View {
    @ObservedObject var store: Store<PrimeModalState, AppAction>
    
    var body: some View {
        VStack {
            if isPrime(store.value.counter) {
                Text("\(store.value.counter) is prime")
                if store.value.favoritePrimes.contains(store.value.counter) {
                    Button(action: {
                        store.send(.primeModal(.removeFavoritePrimeTapped))
                        // store.value.removeFavoritePrime(store.value.counter)
                    }) {
                        Text("Remove from favorite primes")
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(.automatic)
                } else {
                    Button(action: {
                        store.send(.primeModal(.saveFavoritesPrimeTapped))
                        //store.value.addFavoritePrime(count: store.value.counter)
                    }) {
                        Text("Save to favorite primes")
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(.automatic)
                }
            } else {
                Text("\(store.value.counter) is not prime")
            }
        }
    }
    
    private func isPrime(_ number: Int) -> Bool {
        if number <= 1 { return false }
        if number <= 3 { return true }
        
        for i in 2...Int(sqrtf(Float(number))) {
            if number % i == 0 { return false }
        }
        return true
    }
}

struct PrimeSheetView_Previews: PreviewProvider {
    private static var store: Store<AppState, AppAction> = .init(initialValue: AppState.init(counter: 0, favoritePrimes: [], loggedInUser: nil, activityFeed: []), reducer: activityFeed(appReducer))
    static var previews: some View {
        PrimeSheetView(store: store.view({ appState in
            return (appState.primeModal)
        }))
    }
}
