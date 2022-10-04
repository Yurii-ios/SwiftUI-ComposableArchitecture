//
//  FavoriteView.swift
//  Counter Demo
//
//  Created by Yurii.Semeliuk on 23/09/2022.
//

import SwiftUI

struct FavoriteView: View {
    @ObservedObject var store: Store<AppState, AppAction>
    
    var body: some View {
        List {
            ForEach(store.value.favoritePrimes, id: \.self) { prime in
                Text(prime.formatted())
            }
            .onDelete { indexSet in
                store.send(.favoritePrimes(.deleteFavoritePrimes(indexSet)))
            }
        }
        .navigationTitle("Favorite Primes")
    }
}

struct FavoriteView_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteView(store: Store(initialValue: AppState(), reducer: activityFeed(appReducer)))
    }
}
