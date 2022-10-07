//
//  FavoriteView.swift
//  Counter Demo
//
//  Created by Yurii.Sameliuk on 23/09/2022.
//

//import SwiftUI
//import ComposableArchitecture
//import Favoriteprimes
//
//struct FavoriteView: View {
//    @ObservedObject var store: Store<[Int], FavoritePrimeAction>
//    
//    var body: some View {
//        List {
//            ForEach(store.value, id: \.self) { prime in
//                Text(prime.formatted())
//            }
//            .onDelete { indexSet in
//                store.send(.deleteFavoritePrimes(indexSet))
//                //self.store.send(.counter(.incrTapped))
//            }
//        }
//        .navigationTitle("Favorite Primes")
//    }
//}
//
//struct FavoriteView_Previews: PreviewProvider {
//   private static var store: Store<AppState, AppAction> = .init(initialValue: AppState.init(counter: 0, favoritePrimes: [], loggedInUser: nil, activityFeed: []), reducer: activityFeed(appReducer))
//    static var previews: some View {
//        FavoriteView(store:
//                        store.view(value: { appState in
//            return (appState.favoritePrimes)
//        }, action: { localAction in
//            AppAction.favoritePrimes(localAction)
//        }))
//    }
//}
