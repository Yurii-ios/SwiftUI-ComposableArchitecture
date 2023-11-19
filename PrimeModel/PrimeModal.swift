//
//  PrimeModal.swift
//  PrimeModel
//
//  Created by Yurii Sameliuk on 05/10/2022.
//

import Foundation
import SwiftUI
import Combine
import ComposableArchitecture

//public struct PrimeModalState {
//    public var counter: Int
//    public var favoritePrimes: [Int]
//
//    public init(counter: Int, favoritePrimes: [Int]) {
//        self.counter = counter
//        self.favoritePrimes = favoritePrimes
//    }
//}
//       ↓
public typealias PrimeModalState = (counter: Int, favoritePrimes: [Int])

public enum PrimeModalAction: Equatable {
    case saveFavoritesPrimeTapped
    case removeFavoritePrimeTapped
}

public func primeModalReducer(
    state: inout PrimeModalState,
    action: PrimeModalAction,
    environment: Void
) -> [Effect<PrimeModalAction>] {
    switch action {
    case .saveFavoritesPrimeTapped:
        state.favoritePrimes.append(state.counter)
        return []
        
    case .removeFavoritePrimeTapped:
        state.favoritePrimes.removeAll(where: { $0 == state.counter })
        return []
    }
}

public func isPrime(_ number: Int) -> Bool {
    if number <= 1 { return false }
    if number <= 3 { return true }
    
    for i in 2...Int(sqrtf(Float(number))) {
        if number % i == 0 { return false }
    }
    return true
}

public struct PrimeSheetView: View {
    struct States: Equatable {
        let counter: Int
        let isFavorite: Bool
    }
    let store: Store<PrimeModalState, PrimeModalAction>
    @ObservedObject var viewStore: ViewStore<States>
    
    public init(store: Store<PrimeModalState, PrimeModalAction>) {
        self.store = store
        self.viewStore = self.store
            .scope(value: States.init(primeModelState: ), action: { $0 })
            .view
    }
    
    public var body: some View {
        VStack {
            if isPrime(viewStore.value.counter) {
                Text("\(viewStore.value.counter) is prime")
                if viewStore.value.isFavorite {
                    Button(action: {
                        store.send(.removeFavoritePrimeTapped)
                        // store.value.removeFavoritePrime(store.value.counter)
                    }) {
                        Text("Remove from favorite primes")
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(.automatic)
                } else {
                    Button(action: {
                        store.send(.saveFavoritesPrimeTapped)
                        //store.value.addFavoritePrime(count: store.value.counter)
                    }) {
                        Text("Save to favorite primes")
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(.automatic)
                }
            } else {
                Text("\(viewStore.value.counter) is not prime")
            }
        }
    }
}

extension PrimeSheetView.States {
    init(primeModelState state: PrimeModalState) {
        self.counter = state.counter
        self.isFavorite = state.favoritePrimes.contains(state.counter)
    }
}
