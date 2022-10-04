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
    
    var counter: CounterAction? {
        get {
            guard case let .counter(value) = self else { return nil }
            return value
        }
        set {
            guard case .counter = self, let newValue = newValue else { return }
            self = .counter(newValue)
        }
    }
    
    var primeModal: PrimeModalAction? {
        get {
            guard case let .primeModal(value) = self else { return nil }
            return value
        }
        set {
            guard case .primeModal = self, let newValue = newValue else { return }
            self = .primeModal(newValue)
        }
    }
    
    var favoritePrimes: FavoritePrimeAction? {
        get {
            guard case let .favoritePrimes(value) = self else { return nil }
            return value
        }
        set {
            guard case .favoritePrimes = self, let newValue = newValue else { return }
            self = .favoritePrimes(newValue)
        }
    }
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
