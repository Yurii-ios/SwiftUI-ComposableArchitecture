//
//  CounterReducer.swift
//  Counter Demo
//
//  Created by Yurii.Semeliuk on 26/09/2022.
//

import Foundation
import CloudKit
import SwiftUI

//func appReducer(state: inout AppState, action: AppAction) {
//    switch action {
//
//    }
//}
// func counterReducer(state: inout AppState, action: AppAction)
func counterReducer(state: inout Int, action: AppAction) {
    switch action {
    case .counter(.decrTapped):
        state -= 1
        //state.counter -= 1
    case .counter(.incrTapped):
        state += 1
       // state.counter += 1
    default:
        break
    }
}

func primeModalReducer(state: inout AppState, action: AppAction) {
    switch action {
    case .primeModal(.saveFavoritesPrimeTapped):
        state.favoritePrimes.append(state.counter)
        state.activityFeed.append(.init(timestamp: Date(), type: .addedFavoritePrime(state.counter)))
        
    case .primeModal(.removeFavoritePrimeTapped):
        state.favoritePrimes.removeAll(where: { $0 == state.counter })
        state.activityFeed.append(.init(timestamp: Date(), type: .removeFavoritePrime(state.counter)))
    default:
        break
    }
}

func favoritePrimesReducer(state: inout FavoritePrimesState, action: AppAction) {
    switch action {
    case let .favoritePrimes(.deleteFavoritePrimes(indexSet)):
        for index in indexSet {
            let prime = state.favoritePrimes[index]
            state.favoritePrimes.remove(at: index)
            state.activityFeed.append(.init(timestamp: Date(), type: .removeFavoritePrime(prime)))
        }
    default:
        break
    }
}

//func combine<Value, Action>(
//    _ first: @escaping (inout Value, Action) -> Void,
//    _ second: @escaping (inout Value, Action) -> Void) -> (inout Value, Action) -> Void {
//        return { value, action in
//            first(&value, action)
//            second(&value, action)
//        }
//    }

//let appReducer = combine(combine(counterReducer, primeModalReducer), favoritePrimesReducer)

//let _appReducer = combine(
//    pullback(counterReducer, get: {  $0.count}, set: { $0.count == $1 }) if counterReducer (state: inout Int, action: AppAction)
//    pullback(counterReducer, value: \.count) // short version  get, set
//    counterReducer,
//    primeModalReducer,
//    favoritePrimesReducer
//)


func combine<Value, Action>(
  _ reducers: (inout Value, Action) -> Void...
) -> (inout Value, Action) -> Void {

  return { value, action in
    for reducer in reducers {
      reducer(&value, action)
    }
  }
}

let _appReducer = combine(
    pullback(counterReducer, value: \.counter),
    primeModalReducer,
    pullback(favoritePrimesReducer, value: \.favoritePrimesState)
)

let appReducer = pullback(_appReducer, value: \.self)

func pullback<LocalValue, GlobalValue, Action>(
    _ reducer: @escaping (inout LocalValue, Action) -> Void,
    value: WritableKeyPath<GlobalValue, LocalValue> // short version  get, set
//    get: @escaping (GlobalValue) -> LocalValue,
//    set: @escaping (inout GlobalValue, LocalValue) -> Void
) -> (inout GlobalValue, Action) -> Void {
    return { globalValue, action in
        reducer(&globalValue[keyPath: value], action)
//        var localValue = get(globalValue)
//        reducer(&localValue, action)
//        set(&globalValue, localValue)
    }
}
