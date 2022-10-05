//
//  CounterReducer.swift
//  Counter Demo
//
//  Created by Yurii.Sameliuk on 26/09/2022.
//

import Foundation
import SwiftUI
import ComposableArchitecture
import Favoriteprimes
import Counter
import PrimeModel

// higherOrderReducer
func activityFeed(
    _ reducer: @escaping (inout AppState, AppAction) -> Void
) -> (inout AppState, AppAction) -> Void {
    
    return { state, action in
        // do some computations with state and action
        switch action {
        case .counter:
            break
        case .primeModal(.removeFavoritePrimeTapped):
            state.activityFeed.append(.init(timestamp: Date(), type: .removeFavoritePrime(state.counter)))
            
        case .primeModal(.saveFavoritesPrimeTapped):
            state.activityFeed.append(.init(timestamp: Date(), type: .addedFavoritePrime(state.counter)))
            
        case let .favoritePrimes(.deleteFavoritePrimes(indexSet)):
            for index in indexSet {
            let prime = state.favoritePrimes[index]
            state.activityFeed.append(.init(timestamp: Date(), type: .removeFavoritePrime(prime)))
            }
        }
        reducer(&state, action)
        // inspect what happened to state?
    }
}

let _appReducer: (inout AppState, AppAction) -> Void = combine(
    pullback(counterReducer, value: \.counter, action: \.counter),
    pullback(primeModalReducer, value: \.primeModal, action: \.primeModal),
    pullback(favoritePrimesReducer, value: \.favoritePrimes, action: \.favoritePrimes)
)

let appReducer = pullback(_appReducer, value: \.self, action: \.self)


