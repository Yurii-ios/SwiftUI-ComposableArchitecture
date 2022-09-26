//
//  CounterAction.swift
//  Counter Demo
//
//  Created by Yurii.Semeliuk on 26/09/2022.
//

import Foundation

enum AppAction {
    case counter(CounterAction)
    case primeModal(PrimeModalAction)
    case favoritePrimes(FavoritePrimeAction)
}

enum CounterAction {
    case decrTapped
    case incrTapped
}

enum PrimeModalAction {
    case saveFavoritesPrimeTapped
    case removeFavoritePrimeTapped
}

enum FavoritePrimeAction {
    case deleteFavoritePrimes(IndexSet)
}
