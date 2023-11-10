//
//  CounterReducer.swift
//  Counter Demo
//
//  Created by Yurii.Sameliuk on 26/09/2022.
//

import SwiftUI
import ComposableArchitecture
import Favoriteprimes
import Counter

// higherOrderReducer
func activityFeed(
    _ reducer: @escaping Reducer<AppState, AppAction, AppEnvironment>
) -> Reducer<AppState, AppAction, AppEnvironment> {
    
    return { state, action, environment in
        // do some computations with state and action
        switch action {
        case .counterView(.counter),
                .offlineCounterView(.counter),
                .favoritePrimes(.loadFavoritePrimes(_)),
                .favoritePrimes(.saveButtonTapped),
                .favoritePrimes(.loadButtonTapped),
                .favoritePrimes(.primeButtonTapped(_)),
                .favoritePrimes(.nthResponce),
                .favoritePrimes(.alertDissmissButtonTapped):
            break
        case .counterView(.primeModal(.removeFavoritePrimeTapped)), .offlineCounterView(.primeModal(.removeFavoritePrimeTapped)):
            state.activityFeed.append(.init(timestamp: Date(), type: .removeFavoritePrime(state.counter)))
            
        case .counterView(.primeModal(.saveFavoritesPrimeTapped)), .offlineCounterView(.primeModal(.saveFavoritesPrimeTapped)):
            state.activityFeed.append(.init(timestamp: Date(), type: .addedFavoritePrime(state.counter)))
            
        case let .favoritePrimes(.deleteFavoritePrimes(indexSet)):
            for index in indexSet {
                let prime = state.favoritePrimes[index]
                state.activityFeed.append(.init(timestamp: Date(), type: .removeFavoritePrime(prime)))
            }
        }
       return reducer(&state, action, environment)
        // inspect what happened to state?
    }
}

//struct AppEnvironment {
//    var counter: CounterEnvironment
//    var favoritePrimes: FavoritePrimesEnvironment
//}

typealias AppEnvironment = (
    fileClient: FileClient,
    nthPrime: (Int) -> Effect<Int?>,
    offlineNthPrime: (Int) -> Effect<Int?>
)

let appReducer: Reducer<AppState, AppAction, AppEnvironment> = combine(
    pullback(
        counterViewReducer,
        value: \AppState.counterView,
        action: \AppAction.counterView,
        environment: { $0.nthPrime }
    ),
    pullback(
        counterViewReducer,
        value: \AppState.counterView,
        action: \AppAction.offlineCounterView,
        environment: { $0.offlineNthPrime }
    ),
    pullback(
        favoritePrimesReducer,
        value: \.favoritePrimeState,
        action: \.favoritePrimes,
        environment: { ($0.fileClient , $0.nthPrime) }
    )
)

//let appReducer = pullback(_appReducer, value: \.self, action: \.self)


