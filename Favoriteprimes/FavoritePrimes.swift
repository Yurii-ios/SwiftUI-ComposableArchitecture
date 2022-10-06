//
//  FavoritePrimes.swift
//  Favoriteprimes
//
//  Created by Yurii Sameliuk on 05/10/2022.
//

import Foundation
import SwiftUI
import Combine
import ComposableArchitecture

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

public struct FavoriteView: View {
    @ObservedObject var store: Store<[Int], FavoritePrimeAction>
    
    public init(store: Store<[Int], FavoritePrimeAction>) {
        self.store = store
    }
    
    public var body: some View {
        List {
            ForEach(store.value, id: \.self) { prime in
                Text(prime.formatted())
            }
            .onDelete { indexSet in
                store.send(.deleteFavoritePrimes(indexSet))
                //self.store.send(.counter(.incrTapped))
            }
        }
        .navigationTitle("Favorite Primes")
    }
}
