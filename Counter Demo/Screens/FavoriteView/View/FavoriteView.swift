//
//  FavoriteView.swift
//  Counter Demo
//
//  Created by Yurii.Semeliuk on 23/09/2022.
//

import SwiftUI

struct FavoriteView: View {
    @ObservedObject var favoritePrimesState: FavoritePrimesState
    
    var body: some View {
        List {
            ForEach(favoritePrimesState.favoritePrimes, id: \.self) { prime in
                Text(prime.formatted())
            }
            .onDelete { indexSet in
                for index in indexSet {
                    favoritePrimesState.favoritePrimes.remove(at: index)
                }
            }
        }
        .navigationTitle("Favorite Primes")
    }
}

struct FavoriteView_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteView(favoritePrimesState: FavoritePrimesState(state: AppState()))
    }
}
