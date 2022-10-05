//
//  PrimeModal.swift
//  PrimeModel
//
//  Created by Yurii Sameliuk on 05/10/2022.
//

import Foundation

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

public enum PrimeModalAction {
    case saveFavoritesPrimeTapped
    case removeFavoritePrimeTapped
}

public func primeModalReducer(state: inout PrimeModalState, action: PrimeModalAction) {
    switch action {
    case .saveFavoritesPrimeTapped:
        state.favoritePrimes.append(state.counter)
        
    case .removeFavoritePrimeTapped:
        state.favoritePrimes.removeAll(where: { $0 == state.counter })
    }
}
