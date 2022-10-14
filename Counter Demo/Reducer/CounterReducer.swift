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
    _ reducer: @escaping Reducer<AppState, AppAction>
) -> Reducer<AppState, AppAction> {
    
    return { state, action in
        // do some computations with state and action
        switch action {
        case .counterView(.counter), .favoritePrimes(.loadFavoritePrimes(_)), .favoritePrimes(.saveButtonTapped), .favoritePrimes(.loadButtonTapped):
            break
        case .counterView(.primeModal(.removeFavoritePrimeTapped)):
            state.activityFeed.append(.init(timestamp: Date(), type: .removeFavoritePrime(state.counter)))
            
        case .counterView(.primeModal(.saveFavoritesPrimeTapped)):
            state.activityFeed.append(.init(timestamp: Date(), type: .addedFavoritePrime(state.counter)))
            
        case let .favoritePrimes(.deleteFavoritePrimes(indexSet)):
            for index in indexSet {
            let prime = state.favoritePrimes[index]
            state.activityFeed.append(.init(timestamp: Date(), type: .removeFavoritePrime(prime)))
            }
        }
       return reducer(&state, action)
        // inspect what happened to state?
    }
}

let appReducer: Reducer<AppState, AppAction> = combine(
    pullback(counterViewReducer, value: \AppState.counterView, action: \AppAction.counterView),
    pullback(favoritePrimesReducer, value: \.favoritePrimes, action: \.favoritePrimes)
)

//let appReducer = pullback(_appReducer, value: \.self, action: \.self)


