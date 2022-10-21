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

public func primeModalReducer(state: inout PrimeModalState, action: PrimeModalAction) -> [Effect<PrimeModalAction>] {
    switch action {
    case .saveFavoritesPrimeTapped:
        state.favoritePrimes.append(state.counter)
        return []
        
    case .removeFavoritePrimeTapped:
        state.favoritePrimes.removeAll(where: { $0 == state.counter })
        return []
    }
}

public struct PrimeSheetView: View {
    @ObservedObject var store: Store<PrimeModalState, PrimeModalAction>
    
    public init(store: Store<PrimeModalState, PrimeModalAction>) {
        self.store = store
    }
    
    public var body: some View {
        VStack {
            if isPrime(store.value.counter) {
                Text("\(store.value.counter) is prime")
                if store.value.favoritePrimes.contains(store.value.counter) {
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
