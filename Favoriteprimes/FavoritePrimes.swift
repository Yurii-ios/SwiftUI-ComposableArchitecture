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
    case loadFavoritePrimes([Int])
    case saveButtonTapped
    case loadButtonTapped
    
}

public func favoritePrimesReducer(state: inout [Int], action: FavoritePrimeAction) -> [Effect<FavoritePrimeAction>] {
    switch action {
    case let .deleteFavoritePrimes(indexSet):
        for index in indexSet {
            state.remove(at: index)
        }
        return []
        
    case let .loadFavoritePrimes(favoritePrimes):
        state = favoritePrimes
        return []
        
    case .saveButtonTapped:
        return [saveEffect(state)]
        
    case .loadButtonTapped:
        return [loadEffect]
    }
}

private func saveEffect(_ favoritePrime: [Int]) -> Effect<FavoritePrimeAction> {
    return Effect { _ in
        let data = try? JSONEncoder().encode(favoritePrime)
        let documentPath =  NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let documentsUrl = URL(fileURLWithPath: documentPath)
        let fovoritePrimesURL = documentsUrl.appendingPathComponent("favorite-primes.json")
        try? data?.write(to: fovoritePrimesURL)
        print("data: \(String(describing: data)) was saved")
    }
}

private let loadEffect = Effect<FavoritePrimeAction> { callback in
    let documentPath =  NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    let documentsUrl = URL(fileURLWithPath: documentPath)
    let fovoritePrimesURL = documentsUrl.appendingPathComponent("favorite-primes.json")
    
    guard let data = try? Data(contentsOf: fovoritePrimesURL),
          let favoritePrimes = try? JSONDecoder().decode([Int].self, from: data) else { return }
    
    callback(.loadFavoritePrimes(favoritePrimes))
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
        .toolbar {
            ToolbarItem(id: "Favorite Primes", placement: .navigationBarTrailing, showsByDefault: true) {
                HStack {
                    Button(action: { store.send(.saveButtonTapped) }) {
                        Text("Save")
                    }
                    Button(action: { store.send(.loadButtonTapped) }) {
                        Text("Load")
                    }
                }
            }
        }
    }
}
