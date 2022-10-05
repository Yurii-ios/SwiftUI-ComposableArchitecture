//
//  FavoritePrimes.swift
//  Favoriteprimes
//
//  Created by Yurii Sameliuk on 05/10/2022.
//

import Foundation

public enum FavoritePrimeAction {
    case deleteFavoritePrimes(IndexSet)
}

public func favoritePrimesReducer(state: inout [Int], action: FavoritePrimeAction) {
    switch action {
    case let .deleteFavoritePrimes(indexSet):
        for index in indexSet {
            state.remove(at: index)
        }
    }
}
