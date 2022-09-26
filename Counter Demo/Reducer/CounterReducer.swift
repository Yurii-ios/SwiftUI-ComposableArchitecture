//
//  CounterReducer.swift
//  Counter Demo
//
//  Created by Yurii.Semeliuk on 26/09/2022.
//

import Foundation
import CloudKit

func appReducer(state: inout AppState, action: AppAction) {
    switch action {
    case .counter(.decrTapped):
        state.counter -= 1
        
    case .counter(.incrTapped):
        state.counter += 1
        
    case .primeModal(.saveFavoritesPrimeTapped):
        state.favoritePrimes.append(state.counter)
        state.activityFeed.append(.init(timestamp: Date(), type: .addedFavoritePrime(state.counter)))
   
    case .primeModal(.removeFavoritePrimeTapped):
        state.favoritePrimes.removeAll(where: { $0 == state.counter })
        state.activityFeed.append(.init(timestamp: Date(), type: .removeFavoritePrime(state.counter)))
        
    case let .favoritePrimes(.deleteFavoritePrimes(indexSet)):
        for index in indexSet {
            let prime = state.favoritePrimes[index]
            state.favoritePrimes.remove(at: index)
            state.activityFeed.append(.init(timestamp: Date(), type: .removeFavoritePrime(prime)))
        }
    }
}

func counterReducer(state: inout AppState, action: AppAction) {
    switch action {
    case .counter(.decrTapped):
        state.counter -= 1
    case .counter(.incrTapped):
        state.counter += 1
    default:
        break
    }
}

func combine<Value, Action>(_ first: @escaping (inout Value, Action) -> Void, _ second: @escaping (inout Value, Action) -> Void) -> (inout Value, Action) -> Void {
    return { value, action in
        first(&value, action)
        second(&value, action)
    }
}
